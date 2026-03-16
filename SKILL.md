---
name: inter-agent-messaging
description: Deterministic inter-agent messaging for AI agents. Global and project-specific task queues with config-driven project discovery. Version 3.0.
compatibility: Requires tmux and kimi-cli. Agents run in separate tmux panes.
metadata:
  author: gavinc
  version: "3.0.0"
---

# Inter-Agent Messaging Skill v3.0

**Purpose:** Coordinate work between multiple AI agents with **deterministic** messaging that works the same from any directory.

**Core Principle:** Files on disk are the source of truth. Config-driven project discovery. Same output regardless of current directory.

---

## What's New in v3.0

### Deterministic Output
- `cm` shows **ALL queues** (global + all registered projects) from any directory
- No more "where am I?" confusion - same output everywhere

### Config-Driven Projects
- Register projects once: `agent-task register-project /path`
- Tools read from `~/.config/kimi/inter-agent-comms/projects`
- No tool updates needed to add new projects

### Global Queue
- Cross-project tasks go in `~/.local/share/kimi/queue/`
- Project-specific tasks stay in project `.agents/queue/`
- Task IDs are unique across all queues

---

## Architecture

```
~/.local/bin/                          # Tools (symlinked from skill)
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

---

## Quick Start

### 1. Check Your Messages (Anywhere)

```bash
# Same output from ANY directory
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

### 2. Register Your Project

```bash
# One-time registration
agent-task register-project /path/to/your/project

# Verify
agent-task projects
```

### 3. Create Tasks

```bash
# Global task (cross-project)
agent-task create "Research auth libraries" lead

# Project-specific task
agent-task create --project /path/to/project "Fix login bug" tester

# Or create in project queue if you're in the project:
# (cd /path/to/project && agent-task create "Fix bug" tester)
```

### 4. Claim and Complete

```bash
# Claim searches ALL queues automatically
agent-task claim task-id-1234567890 tester

# Complete also searches ALL queues
agent-task complete task-id-1234567890
```

---

## Commands Reference

### `cm` - Check Messages

Shows **all** queues: global + all registered projects.

**Deterministic:** Same output from any directory.

### `agent-task` - Task Management

| Command | Purpose | Default Queue |
|---------|---------|---------------|
| `create <title> [agent]` | Create global task | Global |
| `create --project <path> <title>` | Create project task | Specified project |
| `claim <id> <agent>` | Claim task (searches all) | Finds automatically |
| `complete <id>` | Complete task (searches all) | Finds automatically |
| `list` | List all queues | Shows all |
| `register-project <path>` | Register project | - |
| `unregister-project <path>` | Remove project | - |
| `projects` | List registered projects | - |

---

## Complete Workflow Example

### Chad (coding-agent) Creates Task for Tessa (testing-agent)

```bash
# Chad is in the project directory
cd /home/user/projects/myapp

# Chad creates a test task in the project queue
agent-task create --project /home/user/projects/myapp "Test new auth flow" testing-agent

# Output: [CREATED] Task: test-new-auth-flow-1234567890

# Chad notifies Tessa (optional - appears in her context)
dm testing-agent
```

### Tessa Checks Messages

```bash
# Tessa runs cm from ANYWHERE
cd /tmp  # anywhere
cm

# Sees in output:
# 📂 myapp [/home/user/projects/myapp]
# 📬 TODO:
#    • test-new-auth-flow-1234567890.md
#      From: testing-agent 🔴 HIGH

# Tessa claims it (searches all queues automatically)
agent-task claim test-new-auth-flow-1234567890 testing-agent

# Output:
# [OK] Task claimed: test-new-auth-flow-1234567890
#    Agent: testing-agent
#    Queue: /home/user/projects/myapp/.agents/queue
```

### Tessa Completes Work

```bash
# After testing...
agent-task complete test-new-auth-flow-1234567890

# Task moves to done/ and appears in cm under ✅ DONE
```

---

## Config File Format

**Location:** `~/.config/kimi/inter-agent-comms/projects`

```
# One absolute path per line
/home/user/projects/myapp
/home/user/projects/api-service
~/coding/another-project
```

Lines starting with `#` are comments.

**Managed via commands:**
```bash
agent-task register-project /path/to/project    # Add
agent-task unregister-project /path/to/project  # Remove
agent-task projects                              # View
```

---

## Task File Format

```markdown
# Task: Test new auth flow

**ID:** test-new-auth-flow-1234567890
**Created:** 2025-03-16T13:00:00+00:00
**Status:** pending
**Assignee:** testing-agent

## Description
Test the new authentication flow implemented in PR #42.

## Acceptance Criteria
- [ ] Login with valid credentials
- [ ] Login with invalid credentials shows error
- [ ] Password reset works

## Notes
---
Claimed by: testing-agent at 2025-03-16T13:05:00+00:00
---
Completed at: 2025-03-16T13:30:00+00:00
```

---

## Why This Works

| Mechanism | Purpose | Persistence |
|-----------|---------|-------------|
| **Task files** | Message content | ✅ Disk (100% reliable) |
| **`cm`** | Read all tasks | ✅ Deterministic output |
| **`agent-task`** | State management | ✅ Config-driven |
| **Project registry** | Queue discovery | ✅ Config file |
| **File locking** | Coordination | ✅ Atomic mkdir |

**Deterministic:** `cm` shows all queues from any directory. No context-dependent behavior.

---

## Installation

### Prerequisites

- **tmux** installed
- **kimi CLI** installed
- **Git repo cloned** (this skill)

### Setup

```bash
# 1. Clone the skill repo (or ensure it exists)
git clone <repo-url> ~/.agents/skills/inter-agent-messaging
# or use existing location

# 2. Create symlinks to tools
ln -s ~/.agents/skills/inter-agent-messaging/scripts/cm ~/.local/bin/cm
ln -s ~/.agents/skills/inter-agent-messaging/scripts/agent-task ~/.local/bin/agent-task

# 3. Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"

# 4. Create global queue directory
mkdir -p ~/.local/share/kimi/queue/{todo,doing,done}

# 5. Create config directory
mkdir -p ~/.config/kimi/inter-agent-comms

# 6. Register your projects
agent-task register-project /path/to/project1
agent-task register-project /path/to/project2
```

---

## Troubleshooting

### "cm: command not found"
```bash
# Check symlink exists
ls -la ~/.local/bin/cm

# If not, create it:
ln -s /path/to/skill/scripts/cm ~/.local/bin/cm
```

### "No project queues registered"
```bash
# Register your projects
agent-task register-project /path/to/your/project
```

### "Task not found"
- Task IDs are unique across all queues
- `agent-task claim` and `complete` search ALL registered queues
- Run `agent-task list` to see all tasks

### "Permission denied"
```bash
# Make scripts executable
chmod +x ~/.agents/skills/inter-agent-messaging/scripts/cm
chmod +x ~/.agents/skills/inter-agent-messaging/scripts/agent-task
```

---

## Migration from v2.x

### What's Different

| v2.x | v3.0 |
|------|------|
| Context-dependent (`cm` showed current dir's queue) | Deterministic (`cm` shows all queues) |
| Only project queues | Global + project queues |
| Projects discovered by directory | Projects registered in config file |
| `agent-task claim <filename>` | `agent-task claim <task-id>` (searches all) |

### Migration Steps

1. **Update tools:** Pull latest skill repo
2. **Create symlinks:** Replace old files with symlinks (see Installation)
3. **Register projects:** Run `agent-task register-project` for each project
4. **Update workflows:** Use task IDs instead of filenames for claim/complete

---

## Version

v3.0.0 - Deterministic inter-agent messaging with global queues and config-driven project discovery
