# AFS Dev Container

A fully portable Docker development environment with VS Code and essential development tools including Claude Code, Python, AWS CLI, and more. This container allows developers to "parachute in" with a complete, reproducible AFS development setup.

## What's Included

### Core Tools
- **Ubuntu 22.04 LTS** - Stable, long-term support base
- **Node.js 20.x** - Latest LTS version
- **Python 3** - With pip and venv
- **git** - Version control
- **AWS CLI v2** - Amazon Web Services command-line interface
- **Claude Code** - AI-powered development assistant

### Development Utilities
- **Editors**: vim, nano
- **Utilities**: curl, wget, jq, tree, htop, less
- **Build tools**: gcc, g++, make (for native npm packages)

### VS Code Extensions (Auto-installed)
- Anthropic Claude Code
- GitLens
- ESLint
- Prettier
- Python + Pylance
- YAML support
- Code Spell Checker
- AFS Code Cred (Windows hosts only)

## Quick Start

### Prerequisites
- [VS Code](https://code.visualstudio.com/) installed
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code

### Getting Started

1. **Clone this repository**
   ```bash
   git clone https://github.com/ChristopherGRoge/AFS-DEV-TOOLS-CONTAINER.git
   cd AFS-DEV-TOOLS-CONTAINER
   ```

2. **Open in VS Code**
   ```bash
   code .
   ```

3. **Reopen in Container**
   - VS Code will detect the `.devcontainer` configuration
   - Click "Reopen in Container" when prompted (or use Command Palette: `Dev Containers: Reopen in Container`)
   - First build takes 3-5 minutes; subsequent starts are instant

4. **Authenticate Claude Code** (First time only)
   ```bash
   claude auth login
   ```
   - Follow the prompts to authenticate with your Anthropic account
   - Your credentials are saved in a persistent Docker volume

5. **Start coding!**
   ```bash
   claude
   ```

## Features

### Persistent Storage
The following directories are mounted as persistent Docker volumes (survive container rebuilds):
- `~/.claude` - Claude Code authentication and configuration (volume: `afs-dev-config`)
- `~/.bash_history` - Command history (volume: `afs-dev-bash-history`)
- `~/.aws` - AWS CLI credentials and configuration (volume: `afs-dev-aws-config`)

### SSH Key Forwarding
Your host machine's SSH keys are automatically mounted (read-only) for git operations.

### Version Check
When you open a terminal, you'll see the installed versions:
```
=== Dev Container Ready ===
Node.js: v20.x.x
Python: 3.10.x
AWS CLI: aws-cli/2.x.x
Claude Code: x.x.x
==========================
```

## Common Tasks

### Python Development
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install packages
pip install -r requirements.txt
```

### AWS Configuration
```bash
# Configure AWS credentials (persists in volume)
aws configure

# Test AWS access
aws s3 ls
```

### Git Configuration
```bash
# Set your git identity (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Using Claude Code
```bash
# Start Claude Code interactive mode
claude

# Run Claude Code on a specific task
claude "explain this codebase structure"

# Check Claude Code status
claude --version
```

## Customization

### Adding More Tools
Edit `.devcontainer/Dockerfile` to add additional tools:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*
```

### Adding VS Code Extensions
Edit `.devcontainer/devcontainer.json` under `customizations.vscode.extensions`:
```json
"extensions": [
  "existing.extension",
  "your.new.extension"
]
```

### Changing Timezone
Edit the `TZ` environment variable in `.devcontainer/Dockerfile`:
```dockerfile
ENV TZ=America/Los_Angeles
```

### Port Forwarding
If you need to expose ports (e.g., for web servers), add them to `devcontainer.json`:
```json
"forwardPorts": [3000, 8080]
```

## Troubleshooting

### Container won't build
- Ensure Docker Desktop is running
- Check you have sufficient disk space (container ~2-3 GB)
- Try: `Dev Containers: Rebuild Container` from Command Palette

### Claude Code authentication fails
```bash
# Re-authenticate
claude auth logout
claude auth login
```

### Can't access AWS services
```bash
# Verify AWS configuration
aws configure list

# Test connectivity
aws sts get-caller-identity
```

### Python packages not found
```bash
# Ensure virtual environment is activated
source venv/bin/activate

# Reinstall packages
pip install -r requirements.txt
```

### SSH keys not working
- Ensure your SSH keys exist in `~/.ssh/` on your host machine
- Check permissions: `chmod 600 ~/.ssh/id_rsa`

### Updating the Container

When updates are pushed to the repository (new configuration, scripts, or container changes), you need to pull the changes and rebuild:

**⚠️ Important:** This process preserves your persistent data (Claude auth, AWS config, bash history) stored in Docker volumes.

```bash
# 1. Navigate to your local repository directory
cd /path/to/LOCAL-SERVICES/AFS-DEV-TOOLS-CONTAINER

# 2. Pull latest changes from GitHub
git reset --hard
git pull
```

**3. Rebuild the container** using one of these methods:

- **Option A (Standard Rebuild)**: In VS Code, press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac), then select:
  - `Dev Containers: Rebuild Container`

- **Option B (Clean Rebuild)**: If you want to ensure a completely fresh build without using cached layers:
  - `Dev Containers: Rebuild Container Without Cache`

**What gets preserved:**
- ✅ Claude Code authentication (`~/.claude`)
- ✅ AWS CLI credentials (`~/.aws`)
- ✅ Bash command history (`~/.bash_history`)
- ✅ Your workspace files and git repositories

**What gets updated:**
- Container configuration (`.devcontainer/devcontainer.json`)
- Installed tools and packages (`.devcontainer/Dockerfile`)
- Scripts and automation (`.devcontainer/*.sh`)
- VS Code extensions

**Note:** Most updates only require a standard rebuild. Use "Rebuild Without Cache" only if you're experiencing issues with cached layers.

### Full Container Reset

If you need to completely reset your dev container (e.g., after pulling major updates or troubleshooting persistent issues), follow these steps:

```bash
# 1. Navigate to your local repository
cd /path/to/AFS-DEV-TOOLS-CONTAINER

# 2. Close VS Code if it's open with the container

# 3. Pull latest changes from GitHub
git reset --hard origin/main
git pull origin main

# 4. Remove old Docker volumes (this deletes any saved credentials/config)
docker volume rm afs-dev-config afs-dev-bash-history afs-dev-aws-config 2>/dev/null || true

# Also remove legacy volume names if upgrading from older version
docker volume rm claude-config bash-history aws-config 2>/dev/null || true

# 5. Remove old container images related to this project
docker container prune -f
docker image prune -f

# 6. Optional: Remove specific devcontainer images (more aggressive)
docker images | grep "afs-dev-tools-container" | awk '{print $3}' | xargs docker rmi -f 2>/dev/null || true

# 7. Reopen in VS Code and rebuild
code .
# Then click "Reopen in Container" or run: Dev Containers: Rebuild Container
```

**Note:** After a full reset, you'll need to:
- Re-authenticate Claude Code: `claude auth login`
- Reconfigure AWS CLI: `aws configure`
- Reset any other tool configurations

**When to use a full reset:**
- After major repository updates (volume name changes, Dockerfile updates, etc.)
- Persistent permission errors
- Container won't start or build
- Corrupted Docker volumes

## Architecture

```
AFS-DEV-TOOLS-CONTAINER/
├── .devcontainer/
│   ├── Dockerfile           # Container image definition
│   └── devcontainer.json    # VS Code configuration
└── README.md                # This file

Docker Volumes (persistent):
- afs-dev-config        -> ~/.claude
- afs-dev-bash-history  -> ~/.bash_history
- afs-dev-aws-config    -> ~/.aws
```

## Technical Details

- **Base Image**: Ubuntu 22.04 LTS
- **User**: Non-root user `vscode` (UID 1000)
- **Shell**: bash
- **Node.js**: Installed via NodeSource official repository
- **AWS CLI**: Official AWS v2 binary installation
- **Claude Code**: Installed globally via npm

## Security Notes

- Container runs as non-root user (`vscode`)
- SSH keys are mounted read-only
- No firewall restrictions (open for maximum flexibility)
- Credentials stored in isolated Docker volumes

## Contributing

To share this setup with your team:
1. Commit the `.devcontainer/` directory to version control
2. Team members clone and open in VS Code
3. Everyone gets an identical development environment

## License

This configuration is provided as-is for development purposes.

---

**Need help?**
- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Claude Code Documentation](https://docs.claude.com/)
- [Docker Documentation](https://docs.docker.com/)
