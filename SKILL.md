---
name: inter-agent-messaging
description: Coordinate work between multiple AI agents using deterministic task queues. Global and project-specific queues with automatic discovery.
compatibility: Requires agents to run in separate tmux panes. Tools must be in PATH.
metadata:
  author: gavinc
  version: "3.0.0"
  tools:
    - cm
    - agent-task
---

# Inter-Agent Messaging

Coordinate work between multiple AI agents with deterministic task queues that work identically from any directory.

## When to Use This Skill

Use this skill when:
- Multiple agents need to coordinate on shared work
- One agent needs to assign tasks to another
- Agents need to track work state (todo/doing/done)
- You need deterministic message visibility regardless of current directory

## Architecture

This skill provides a **three-state task queue**:
- `todo/` - New tasks waiting
- `doing/` - Tasks in progress
- `done/` - Tasks completed

**Two queue types:**
1. **Global queue** (`~/.local/share/kimi/queue/`) - Cross-project tasks
2. **Project queues** (`.agents/queue/`) - Project-specific tasks

**Deterministic:** Running `scripts/cm` shows ALL queues from any directory.

## Quick Start

### Check Messages (from anywhere)

```bash
scripts/cm
```

Shows:
- 🌐 Global queue (cross-project tasks)
- 📁 All registered project queues
- Tasks in todo/doing/done states
- Priority badges (🔴 HIGH, 🔴 CRITICAL, 🟡 MEDIUM, 🟢 LOW)

### Create a Task

```bash
# Global task (cross-project)
scripts/agent-task create "Research auth libraries" lead

# Project-specific task
scripts/agent-task create --project /path/to/project "Fix login bug" tester
```

### Claim and Complete

```bash
# Claim a task (searches all queues automatically)
scripts/agent-task claim task-id-1234567890 tester

# Complete a task
scripts/agent-task complete task-id-1234567890
```

## Commands Reference

| Command | Purpose |
|---------|---------|
| `scripts/cm` | Check ALL tasks (global + projects) |
| `scripts/agent-task create <title> [agent]` | Create global task |
| `scripts/agent-task create --project <path> <title>` | Create project task |
| `scripts/agent-task claim <id> <agent>` | Claim task (searches all) |
| `scripts/agent-task complete <id>` | Complete task (searches all) |
| `scripts/agent-task list` | List all queues (summary) |
| `scripts/agent-task register-project <path>` | Register project |
| `scripts/agent-task unregister-project <path>` | Remove project |
| `scripts/agent-task projects` | List registered projects |

## Complete Workflow Example

### Chad (coding-agent) assigns work to Tessa (testing-agent)

```bash
# Chad creates a test task
scripts/agent-task create --project /path/to/project "Test new auth flow" testing-agent

# Chad notifies Tessa (appears in her context without interrupting)
scripts/dm testing-agent
```

### Tessa receives and completes work

```bash
# Tessa checks messages from anywhere
scripts/cm

# Sees in output:
# 📂 project-name [/path/to/project]
# 📬 TODO:
#    • test-new-auth-flow-1234567890.md
#      From: @coding-agent 🔴 HIGH

# Tessa claims the task
scripts/agent-task claim test-new-auth-flow-1234567890 testing-agent

# After testing, Tessa completes it
scripts/agent-task complete test-new-auth-flow-1234567890
```

## Project Registration

Projects must be registered for automatic discovery:

```bash
# Register a project (one time)
scripts/agent-task register-project /path/to/your/project

# View registered projects
scripts/agent-task projects

# Config file location
~/.config/kimi/inter-agent-messaging/projects
```

## Task File Format

Tasks are Markdown files with YAML frontmatter:

```markdown
# Task: Test new auth flow

**ID:** test-new-auth-flow-1234567890
**Created:** 2025-03-16T13:00:00+00:00
**Status:** pending
**Assignee:** testing-agent

## Description
Test the new authentication flow.

## Acceptance Criteria
- [ ] Login with valid credentials
- [ ] Login with invalid credentials shows error

## Notes
---
Claimed by: testing-agent at 2025-03-16T13:05:00+00:00
---
Completed at: 2025-03-16T13:30:00+00:00
```

## Directory Structure

```
~/.local/share/kimi/queue/             # Global queue
├── todo/
├── doing/
└── done/

~/.config/kimi/inter-agent-messaging/
└── projects                           # Registered project paths

project-root/                          # Project queue
└── .agents/queue/
    ├── todo/
    ├── doing/
    └── done/
```

## Critical Rules

1. **Always run `scripts/cm` at session start** - Shows all queues deterministically
2. **Register projects before use** - `scripts/agent-task register-project /path`
3. **Create task file FIRST** - This IS the message
4. **Use `scripts/dm` for notifications** - Optional, non-interrupting
5. **Task IDs are unique** - Across all queues, no collisions
6. **Claim before working** - Moves todo → doing with file locking
7. **Complete when done** - Moves doing → done

## Troubleshooting

### "scripts/cm: command not found"
```bash
# Ensure tools are in PATH or call with relative path
export PATH="$HOME/.local/bin:$PATH"
# or
~/.config/agents/skills/inter-agent-messaging/scripts/cm
```

### "No project queues registered"
```bash
scripts/agent-task register-project /path/to/your/project
```

### "Task not found"
- Task IDs are unique across all queues
- `scripts/agent-task claim` searches ALL registered queues
- Run `scripts/agent-task list` to see all tasks

### "Permission denied"
```bash
chmod +x scripts/cm scripts/agent-task
```

## Why This Works

| Mechanism | Purpose | Reliability |
|-----------|---------|-------------|
| **Files on disk** | Message persistence | ✅ 100% reliable |
| **Deterministic `scripts/cm`** | Same output anywhere | ✅ No context confusion |
| **Config-driven projects** | Queue discovery | ✅ No code changes needed |
| **File locking** | Coordination | ✅ Atomic mkdir |
| **Task IDs** | Unique identification | ✅ Timestamp-based |

## Version

v3.0.0 - Deterministic inter-agent messaging with global queues and config-driven project discovery
