FROM ubuntu:24.04

# Set environment variables

# Force Python to print output immediately (don't buffer).
ENV PYTHONUNBUFFERED=1
ENV VENV_PATH="/venv"
ENV PATH="$VENV_PATH/bin:$PATH"

# Install system dependencies
RUN apt-get update
RUN apt-get install -y \
    sudo \
    less \
    curl \
    wget \
    git \
    jq \
    build-essential \
    ncdu

RUN apt-get install -y \
    nodejs \
    npm

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Create dev user that can sudo.
RUN useradd -m -s /bin/bash -G sudo dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to dev user
USER dev
WORKDIR /home/dev

# Install OpenVSCode Server.
ENV OPENVSCODE_SERVER_ROOT="/home/dev/openvscode-server"
RUN curl -fsSL https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v1.103.1/openvscode-server-v1.103.1-linux-arm64.tar.gz | tar xzv
RUN mv openvscode-server-* ${OPENVSCODE_SERVER_ROOT}
ENV PATH="${OPENVSCODE_SERVER_ROOT}/bin:$PATH"
RUN openvscode-server --install-extension ms-python.python
RUN openvscode-server --install-extension ms-toolsai.jupyter
RUN openvscode-server --install-extension charliermarsh.ruff
RUN openvscode-server --install-extension openai.chatgpt
RUN openvscode-server --install-extension cab404.vscode-direnv
# These don't seem to be published in the place where openvscode-server looks.
# RUN openvscode-server --install-extension letmaik.git-tree-compare
# RUN openvscode-server --install-extension ms-toolsai.datawrangler

# Make some python venv with some useful things.  Won't necessarily be the venv for our project, though.
# Might pre-warm uv's cache, but version pins are likely different across projects.
RUN uv venv /home/dev/venv
ENV VIRTUAL_ENV="/home/dev/venv"
ENV PATH="/${VIRTUAL_ENV}/bin:$PATH"
COPY --chown=dev:dev pyproject.toml uv.lock /home/dev/dummy_project/
RUN cd /home/dev/dummy_project/ && uv sync --all-packages --active

# Install Claude Code.
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/dev/.local/bin:$PATH"
COPY --chown=dev:dev .claude_anthropic_key.sh /home/dev/.claude/anthropic_key.sh
COPY --chown=dev:dev .claude_settings.json /home/dev/.claude/settings.json
RUN chmod +x /home/dev/.claude/anthropic_key.sh

# Install OpenAI Codex.
RUN sudo npm install -g @openai/codex
# Set the preferred auth method to apikey.
COPY --chown=dev:dev codex_config.toml /home/dev/.codex/config.toml


# Give ourselves some tools.
COPY --chown=dev:dev docker/bin /home/dev/bin
RUN chmod +x /home/dev/bin/*
ENV PATH="/home/dev/bin:$PATH"

# Install direnv.
RUN curl -sfL https://direnv.net/install.sh | bash
RUN echo 'eval "$(direnv hook bash)"' >> /home/dev/.bashrc

USER dev
# Check that we have the right tools.
RUN which python
RUN which codex
RUN which openvscode-server

# Default working directory when container is run.
WORKDIR /workspace
# Default command when container is run.
CMD ["bash"]
