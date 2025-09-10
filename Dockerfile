FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive  # Prevent apt-get from showing interactive prompts during build
ENV PYTHONUNBUFFERED=1              # Force Python to print output immediately (don't buffer)
ENV VENV_PATH="/venv"
ENV PATH="$VENV_PATH/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    git \
    build-essential \
    sudo \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip3 install uv

# Create dev user
RUN useradd -m -s /bin/bash -G sudo dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create virtual environment
RUN python3 -m venv $VENV_PATH && \
    chown -R dev:dev $VENV_PATH

# Switch to dev user
USER dev
WORKDIR /home/dev

# Install OpenAI Codex
RUN sudo npm install -g @openai/codex

# Copy project files
COPY --chown=dev:dev pyproject.toml uv.lock ./

# Install Python dependencies using uv
RUN uv sync --all-packages

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]