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
cm

# Register your project (one time)
agent-task register-project /path/to/your/project

# Create task with ENFORCED format (recommended)
task-create --to testing-agent --priority high "Test: authentication flow"

# Send DM with ENFORCED format
dm-send testing-agent "Task ready. Run tests."

# Claim a task (searches all queues)
agent-task claim task-id-1234567890 coding-agent

# Complete a task
agent-task complete task-id-1234567890
```

## 🔒 Enforced Workflows (Optional but Recommended)

**Problem:** Agents sometimes forget to check messages, create testing tasks, or document handoffs.

**Solution:** Use **Flow Skills** for automatic enforcement.

### Chad with Enforcement

```bash
# Instead of: kimi-chad
# Use: /flow:chad-flow

/flow:chad-flow implement the authentication middleware
```

**What happens:**
1. ✅ **Auto-runs `cm`** at start (can't forget)
2. ✅ **Auto-creates testing tasks** at end (can't skip)
3. ✅ **Auto-documents handoffs** (must complete)
4. ✅ **Auto-updates pane title** (tracks status)

### Tessa with Enforcement

```bash
# Instead of: kimi-tessa  
# Use: /flow:tessa-flow

/flow:tessa-flow test the new authentication flow
```

**What happens:**
1. ✅ **Auto-runs `cm`** at start
2. ✅ **Auto-claims tasks** from queue
3. ✅ **Auto-documents test results** in handoffs/
4. ✅ **Auto-DMs Chad** when complete
5. ✅ **Verifies 4 completion requirements** before ending

### Why Flow Skills Work

| Without Flow | With Flow |
|--------------|-----------|
| `cm` check optional | `cm` check **mandatory** |
| Testing tasks often skipped | Testing tasks **enforced** |
| Handoffs inconsistent | Handoffs **required** |
| No completion verification | **4-step verification** |
| Agent decides when done | **Flow decides when done** |

**Flow skills bind me to the workflow.** I cannot skip steps because the flow controls the conversation.

## Installation

There are **two separate installations**:

1. **Skill Installation** - Lets Kimi read the skill documentation
2. **Tools Installation** - Makes `cm` and `agent-task` available in PATH

### Option A: Automated Setup (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/gavinc/kimi-cli-inter-agent-messaging.git \
  ~/coding/skills/kimi-cli-inter-agent-messaging

# 2. Run the setup script (does both skill + tools installation)
cd ~/coding/skills/kimi-cli-inter-agent-messaging
./scripts/agent-setup /path/to/your/project

# 3. Symlink skill for Kimi discovery (manual step)
mkdir -p ~/.config/agents/skills
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging \
  ~/.config/agents/skills/inter-agent-messaging
```

### Option B: Manual Setup

```bash
# 1. Clone the repository
git clone https://github.com/gavinc/kimi-cli-inter-agent-messaging.git \
  ~/coding/skills/kimi-cli-inter-agent-messaging

# 2. INSTALL SKILL (for Kimi to discover)
mkdir -p ~/.config/agents/skills
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging \
  ~/.config/agents/skills/inter-agent-messaging

# 3. INSTALL TOOLS (for execution)
mkdir -p ~/.local/bin
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging/scripts/cm ~/.local/bin/cm
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging/scripts/agent-task ~/.local/bin/agent-task
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging/scripts/task-create ~/.local/bin/task-create
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging/scripts/dm-send ~/.local/bin/dm-send

# 4. SETUP DIRECTORIES
mkdir -p ~/.local/share/kimi/queue/{todo,doing,done,.locks}
mkdir -p ~/.config/kimi/inter-agent-messaging

# 5. ENSURE PATH
export PATH="$HOME/.local/bin:$PATH"  # Add to ~/.bashrc or ~/.zshrc

# 6. REGISTER PROJECTS
agent-task register-project /path/to/your/project
```

## Architecture

The skill has **two separate installation locations**:

```
┌─────────────────────────────────────────────────────────────┐
│  1. SKILL INSTALLATION (for Kimi to discover)               │
├─────────────────────────────────────────────────────────────┤
│  ~/.config/agents/skills/                                   │
│  └── inter-agent-messaging -> ~/coding/skills/...           │
│       ├── SKILL.md          ← Kimi reads this               │
│       ├── scripts/                                          │
│       │   ├── cm                                            │
│       │   ├── agent-task                                    │
│       │   ├── task-create                                   │
│       │   ├── dm-send                                       │
│       │   └── agent-setup                                   │
│       └── README.md                                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  2. TOOLS INSTALLATION (for execution)                      │
├─────────────────────────────────────────────────────────────┤
│  ~/.local/bin/              ← Must be in PATH               │
│  ├── cm -> ~/coding/skills/.../scripts/cm                   │
│  ├── agent-task -> ~/coding/skills/.../scripts/agent-task   │
│  ├── task-create -> ~/coding/skills/.../scripts/task-create │
│  └── dm-send -> ~/coding/skills/.../scripts/dm-send         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  DATA & CONFIG                                              │
├─────────────────────────────────────────────────────────────┤
│  ~/.local/share/kimi/queue/     ← Global task queue         │
│  ~/.config/kimi/inter-agent-messaging/projects              │
│                                 ← Registered projects       │
└─────────────────────────────────────────────────────────────┘
```

### Why Two Installations?

| Aspect | Skill Installation | Tools Installation |
|--------|-------------------|-------------------|
| **Purpose** | Kimi reads `SKILL.md` for guidance | Agents execute `cm` and `agent-task` |
| **Location** | `~/.config/agents/skills/` | `~/.local/bin/` |
| **Discovered by** | Kimi at startup | Shell PATH lookup |
| **Required for** | Kimi to know about the skill | Agents to call tools |

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

- **SKILL.md** - Complete skill documentation for Kimi (read by Kimi)
- **This README** - Installation and quick reference (for humans)

## Troubleshooting

### "cm: command not found"
```bash
# Tools not in PATH. Either:
export PATH="$HOME/.local/bin:$PATH"
# or run directly:
~/.config/agents/skills/inter-agent-messaging/scripts/cm
```

### "Kimi doesn't know about the skill"
```bash
# Skill not installed for Kimi discovery. Run:
mkdir -p ~/.config/agents/skills
ln -s ~/coding/skills/kimi-cli-inter-agent-messaging \
  ~/.config/agents/skills/inter-agent-messaging
```

### "No project queues registered"
```bash
agent-task register-project /path/to/your/project
```

## License

MIT
