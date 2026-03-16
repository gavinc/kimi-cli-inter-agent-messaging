# Inter-Agent Messaging for Kimi CLI

**v3.0** - Deterministic inter-agent messaging with global queues and config-driven project discovery.

Coordinate multiple AI agents with a simple, reliable pattern. Same output from any directory.

## What's New in v3.0

- ✅ **Deterministic**: `cm` shows all queues from any directory
- 🌍 **Global Queue**: Cross-project tasks in `~/.local/share/kimi/queue/`
- 📁 **Project Queues**: Project-specific tasks in project `.agents/queue/`
- ⚙️ **Config-Driven**: Register projects once, tools discover automatically
- 🔍 **Universal Search**: `claim` and `complete` find tasks in any queue

## Quick Start

```bash
# Check messages from ANYWHERE (shows global + all projects)
cm

# Register your project (one time)
agent-task register-project /path/to/your/project

# Create a global task
agent-task create "Research auth libraries" lead

# Create a project task
agent-task create --project /path/to/project "Fix login bug" tester

# Claim a task (searches all queues)
agent-task claim task-id-1234567890 tester

# Complete a task
agent-task complete task-id-1234567890
```

## Architecture

```
~/.local/bin/                          # Tools (symlinked)
├── cm -> /path/to/skill/scripts/cm
└── agent-task -> /path/to/skill/scripts/agent-task

~/.local/share/kimi/queue/             # Global task queue
├── todo/
├── doing/
└── done/

~/.config/kimi/inter-agent-messaging/
└── projects                           # Registered project paths

project-root/                          # Project-specific queue
└── .agents/queue/
    ├── todo/
    ├── doing/
    └── done/
```

## Installation

### 1. Clone the Skill

```bash
git clone https://github.com/gavinc/kimi-cli-inter-agent-messaging.git \
  ~/.agents/skills/inter-agent-messaging
```

### 2. Create Symlinks

```bash
# Create symlinks (recommended - single source of truth)
ln -s ~/.agents/skills/inter-agent-messaging/scripts/cm ~/.local/bin/cm
ln -s ~/.agents/skills/inter-agent-messaging/scripts/agent-task ~/.local/bin/agent-task
```

Or add to PATH:
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.agents/skills/inter-agent-messaging/scripts:$PATH"
```

### 3. Setup Directories

```bash
# Create global queue
mkdir -p ~/.local/share/kimi/queue/{todo,doing,done}

# Create config directory
mkdir -p ~/.config/kimi/inter-agent-comms
```

### 4. Register Projects

```bash
# Register your projects for automatic discovery
agent-task register-project /path/to/project1
agent-task register-project /path/to/project2

# Verify
agent-task projects
```

## The Pattern

**Task queue in three states:**
- `todo/` - New tasks waiting
- `doing/` - Tasks in progress  
- `done/` - Tasks completed

### Send a Message

```bash
# Create task file = Send message
agent-task create "Test new feature" testing-agent

# Optional: notify them (appears in their context)
dm testing-agent
```

### Receive Messages

```bash
# Run cm = Check ALL tasks (global + all projects)
cm

# Output:
# ╔══════════════════════════════════════════════════════════════╗
# ║  🌐 GLOBAL QUEUE                                             ║
# ╚══════════════════════════════════════════════════════════════╝
# 📬 TODO:
#    • global-task-id.md
#
# ╔══════════════════════════════════════════════════════════════╗
# ║  📁 PROJECT QUEUES                                           ║
# ╚══════════════════════════════════════════════════════════════╝
# 📂 project-name [/full/path]
# 📬 TODO:
#    • project-task-id.md
#      From: @agent-name 🔴 HIGH
# 🔨 DOING:
#    • task-in-progress.md
```

### Manage Tasks

```bash
# Claim a task (searches all queues, moves todo → doing)
agent-task claim task-id-1234567890 tester

# Complete a task (searches all queues, moves doing → done)
agent-task complete task-id-1234567890
```

## Commands

| Command | Purpose |
|---------|---------|
| `cm` | Check all tasks (global + all projects) |
| `dm <agent>` | Notify agent to check tasks |
| `agent-task create <title> [agent]` | Create global task |
| `agent-task create --project <path> <title>` | Create project task |
| `agent-task claim <id> <agent>` | Claim task (searches all queues) |
| `agent-task complete <id>` | Complete task (searches all queues) |
| `agent-task list` | List all queues (summary) |
| `agent-task register-project <path>` | Register project queue |
| `agent-task unregister-project <path>` | Remove project queue |
| `agent-task projects` | List registered projects |

## Key Points

- **Deterministic**: Same `cm` output from any directory
- **Global + Projects**: Cross-project work in global, project work in projects
- **Config-driven**: Register projects once, tools handle the rest
- **Universal search**: `claim` and `complete` find tasks anywhere
- **`dm` is optional** - Just a notification that appears in context
- **`dm` doesn't interrupt** - Message appears without breaking agent's flow

## Config File

**Location:** `~/.config/kimi/inter-agent-messaging/projects`

Format:
```
# One absolute path per line
/home/user/projects/myapp
/home/user/projects/api-service
~/coding/another-project
```

Managed via commands:
```bash
agent-task register-project /path      # Add
agent-task unregister-project /path    # Remove
agent-task projects                     # List
```

## Documentation

- **SKILL.md** - Complete skill documentation for kimi
- **Full guide** - See SKILL.md for detailed workflow examples

## License

MIT
