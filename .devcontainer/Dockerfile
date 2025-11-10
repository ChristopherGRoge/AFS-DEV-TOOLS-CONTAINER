# Claude Code Dev Container
# Ubuntu LTS with VS Code, Claude Code, and essential development tools

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone (change as needed)
ENV TZ=America/New_York

# Install system dependencies and common utilities
RUN apt-get update && apt-get install -y \
    # Essential tools
    curl \
    wget \
    git \
    vim \
    nano \
    less \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release \
    # Build tools (needed for some npm packages)
    build-essential \
    # Python 3 and pip
    python3 \
    python3-pip \
    python3-venv \
    # Useful utilities
    jq \
    tree \
    htop \
    man-db \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (required for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create a non-root user for development
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up Python alias (python -> python3)
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Switch to non-root user
USER $USERNAME

# Set working directory
WORKDIR /home/$USERNAME

# Set default shell
ENV SHELL=/bin/bash

# Display versions on container start
RUN echo '#!/bin/bash' > /home/$USERNAME/.bashrc && \
    echo 'echo "=== Dev Container Ready ==="' >> /home/$USERNAME/.bashrc && \
    echo 'echo "Node.js: $(node --version)"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "Python: $(python --version)"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "AWS CLI: $(aws --version)"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "Claude Code: $(claude --version 2>/dev/null || echo \"not authenticated yet\")"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "=========================="' >> /home/$USERNAME/.bashrc && \
    echo 'echo ""' >> /home/$USERNAME/.bashrc

CMD ["/bin/bash"]
