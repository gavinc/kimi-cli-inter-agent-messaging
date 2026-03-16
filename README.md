# Inter-Agent Messaging for Kimi CLI

**v3.0** - Deterministic inter-agent messaging with global queues and config-driven project discovery.

Coordinate multiple AI agents with task queues that work identically from any directory.

## Features

- ✅ **Deterministic**: `cm` shows ALL queues (global + projects) from any directory
- 🌍 **Global Queue**: Cross-project tasks in `~/.local/share/kimi/queue/`
- 📁 **Project Queues**: Project-specific tasks in `.agents/queue/`
- ⚙️ **Config-Driven**: Register projects once, tools handle the rest
- 🔍 **Universal Search**: `claim` and `complete` find tasks in any queue

## Quick Start

```bash
# Check messages from ANYWHERE (shows global + all projects)
./scripts/cm

# Register your project (one time)
./scripts/agent-task register-project /path/to/your/project

# Create a global task
./scripts/agent-task create "Research auth libraries" lead

# Create a project task
./scripts/agent-task create --project /path/to/project "Fix login bug" tester

# Claim a task (searches all queues)
./scripts/agent-task claim task-id-1234567890 tester

# Complete a task
./scripts/agent-task complete task-id-1234567890
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/gavinc/kimi-cli-inter-agent-messaging.git \
  ~/coding/skills/kimi-cli-inter-agent-messaging
```

### 2. Install for Kimi Skill System (Kimi reads SKILL.md)

```bash
# Create user skills directory
mkdir -p ~/.config/agents/skills

# Symlink skill for Kimi to discover
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging \
  ~/.config/agents/skills/inter-agent-messaging
```

Kimi will now discover this skill and can read `SKILL.md` for guidance.

### 3. Install Tools for Execution (add to PATH)

```bash
# Create symlinks in ~/.local/bin
mkdir -p ~/.local/bin
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging/scripts/cm ~/.local/bin/cm
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging/scripts/agent-task ~/.local/bin/agent-task

# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"
```

Or use the setup script:
```bash
./scripts/agent-setup-v3 /path/to/project1 /path/to/project2
```

### 4. Setup Directories

```bash
# Create global queue
mkdir -p ~/.local/share/kimi/queue/{todo,doing,done,.locks}

# Create config directory
mkdir -p ~/.config/kimi/inter-agent-messaging
```

### 5. Register Projects

```bash
# Register your projects for automatic discovery
agent-task register-project /path/to/project1
agent-task register-project /path/to/project2

# Verify
agent-task projects
```

## Architecture

```
~/.config/agents/skills/             # Kimi skill discovery
└── inter-agent-messaging -> /path/to/repo
    ├── SKILL.md                      # Skill documentation
    ├── scripts/                      # Executable tools
    │   ├── cm
    │   ├── agent-task
    │   └── agent-setup-v3
    └── README.md

~/.local/bin/                        # PATH executables (symlinks)
├── cm -> /path/to/repo/scripts/cm
└── agent-task -> /path/to/repo/scripts/agent-task

~/.local/share/kimi/queue/           # Global task queue
├── todo/
├── doing/
└── done/

~/.config/kimi/inter-agent-messaging/
└── projects                          # Registered project paths

project-root/                         # Project-specific queue
└── .agents/queue/
    ├── todo/
    ├── doing/
    └── done/
```

## Commands

| Command | Purpose |
|---------|---------|
| `cm` | Check all tasks (global + all projects) |
| `agent-task create <title> [agent]` | Create global task |
| `agent-task create --project <path> <title>` | Create project task |
| `agent-task claim <id> <agent>` | Claim task (searches all queues) |
| `agent-task complete <id>` | Complete task (searches all queues) |
| `agent-task list` | List all queues (summary) |
| `agent-task register-project <path>` | Register project queue |
| `agent-task unregister-project <path>` | Remove project queue |
| `agent-task projects` | List registered projects |

## How It Works

**Task queue in three states:**
- `todo/` - New tasks waiting
- `doing/` - Tasks in progress  
- `done/` - Tasks completed

**Sending a message:**
```bash
# Create task file = Send message
agent-task create "Test new feature" testing-agent

# Optional: notify recipient
./scripts/dm testing-agent
```

**Receiving messages:**
```bash
# Run cm = Check ALL tasks (deterministic from anywhere)
cm

# Shows:
# 🌐 GLOBAL QUEUE
# 📁 PROJECT QUEUES
#   📂 project-name
#   📬 TODO:
#   🔨 DOING:
#   ✅ DONE:
```

## Documentation

- **SKILL.md** - Complete skill documentation for Kimi
- **This README** - Quick reference and installation

## License

MIT
