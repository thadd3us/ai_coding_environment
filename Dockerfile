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

# Create dev user
RUN useradd -m -s /bin/bash -G sudo dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# # Create virtual environment
# RUN python3 -m venv $VENV_PATH && \
#     chown -R dev:dev $VENV_PATH

# Switch to dev user
USER dev
WORKDIR /home/dev

# Install OpenAI Codex.
RUN sudo npm install -g @openai/codex

# Copy project files and set up workspace.
WORKDIR /home/dev/workspace
COPY --chown=dev:dev pyproject.toml uv.lock ./
RUN uv sync --all-packages

# Set working directory.
WORKDIR /home/dev/workspace

# Give ourselves some tools.
COPY --chown=dev:dev docker/bin /home/dev/bin
RUN chmod +x /home/dev/bin/*
ENV PATH="/home/dev/bin:/home/dev/workspace/.venv/bin:$PATH"

# Check that we have the right tools.
RUN which python
RUN which jupyter
RUN which run_jupyter.sh

# Default command when container is run.
CMD ["bash"]