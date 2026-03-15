---
name: inter-agent-messaging
description: Deterministic inter-agent messaging for AI agents. Three-state task queue (todo/doing/done) with non-interrupting notifications.
compatibility: Requires tmux and kimi-cli. Agents run in separate tmux panes.
metadata:
  author: gavinc
  version: "2.1.0"
---

# Inter-Agent Messaging Skill

**Purpose:** Coordinate work between multiple AI agents with deterministic messaging.

**Core Principle:** Files on disk are the source of truth. Tmux notifications appear in context without interrupting flow.

---

## The Pattern

**Task queue has three states:**
- `.agents/queue/todo/` - New tasks waiting
- `.agents/queue/doing/` - Tasks in progress
- `.agents/queue/done/` - Tasks completed

### Send a Message

```bash
# 1. Create task file in todo/
cat > .agents/queue/todo/$(date +%Y-%m-%d)-brief-desc.md << 'EOF'
# Task Title

**From:** @coding-agent
**To:** @testing-agent
**Priority:** high

## What
Description of what needs to be done.

## Acceptance Criteria
- [ ] Thing 1
- [ ] Thing 2
EOF

# 2. Optional: Notify recipient (appears in their context without interrupting)
dm testing-agent
```

### Receive Messages

```bash
# Run cm to see all tasks in all states
cm

# Output:
# ╔══════════════════════════════════════════════════════════════╗
# ║  📬 NEW TASKS (todo/)                                        ║
# ╚══════════════════════════════════════════════════════════════╝
#   • 2025-03-15-brief-desc.md
#     # Task Title
#     ...
# 
# ╔══════════════════════════════════════════════════════════════╗
# ║  🔨 IN PROGRESS (doing/)                                     ║
# ╚══════════════════════════════════════════════════════════════╝
#   • 2025-03-14-other-task.md
#
# ╔══════════════════════════════════════════════════════════════╗
# ║  ✅ RECENTLY DONE (done/)                                    ║
# ╚══════════════════════════════════════════════════════════════╝
#   ✓ 2025-03-13-completed-task.md
```

### Manage Task State

```bash
# Claim a task (todo → doing)
agent-task claim 2025-03-15-brief-desc.md

# Complete a task (doing → done)
agent-task complete 2025-03-15-brief-desc.md
```

---

## Commands

| Command | Purpose | Use When |
|---------|---------|----------|
| `cm` | **Check all tasks** | Session start, before going idle |
| `dm <agent>` | **Notify** agent to check | After creating task file |
| `agent-task claim <file>` | **Start** a task | Beginning work |
| `agent-task complete <file>` | **Finish** a task | Work done |

---

## Critical Rules

1. **Create task file FIRST** - This IS the message
2. **`dm` is optional** - Appears in recipient's context without interrupting
3. **Run `cm` to receive** - Shows todo, doing, and recently done
4. **Use agent-task to move state** - Claim when starting, complete when done
5. **AGENT_NAME is optional** - Used by dm to identify sender

---

## Prerequisites

- **tmux** installed
- **kimi CLI** installed
- **PATH setup**: Add skill scripts to PATH

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.agents/skills/kimi-cli-inter-agent-messaging/scripts:$PATH"
```

---

## Quick Start

### Set Agent Name (Optional)

```bash
export AGENT_NAME="testing-agent"
```

### Complete Workflow

```bash
# Chad creates task for Tessa
cat > .agents/queue/todo/2025-03-15-test-feature.md << 'EOF'
# Test: New Feature

**From:** @coding-agent
**To:** @testing-agent

## Context
New feature implemented...

## Tests Needed
- [ ] Test case 1
- [ ] Test case 2
EOF

dm testing-agent

# Tessa checks messages
cm
# Sees task in NEW TASKS section

# Tessa claims the task
agent-task claim 2025-03-15-test-feature.md
# Now appears in IN PROGRESS section

# Tessa does the work...

# Tessa completes the task
agent-task complete 2025-03-15-test-feature.md
# Now appears in RECENTLY DONE section
```

---

## Why This Works

| Mechanism | Purpose | Persistence |
|-----------|---------|-------------|
| **Task files** | Actual message content | ✅ Disk (100% reliable) |
| **`cm`** | Read all tasks | ✅ Reads disk |
| **`dm`** | Notification | ⚠️ Appears in context (non-interrupting) |
| **agent-task** | State management | ✅ Moves files between directories |

**Deterministic:** Even if `dm` fails, the task file exists in `todo/`. Recipient runs `cm` → sees message in NEW TASKS.

---

## Troubleshooting

### "dm: command not found"
```bash
export PATH="$HOME/.agents/skills/kimi-cli-inter-agent-messaging/scripts:$PATH"
```

### "Agent not found"
```bash
tmux list-panes -a -F '#{pane_id}: #{pane_title}'
# Use exact name from title (after the colon)
```

### "Where are my completed tasks?"
`cm` shows the last 5 completed tasks from `done/`. Older tasks are still in the directory but not displayed to keep output manageable.

---

## Version

v2.1.0 - Three-state task queue with non-interrupting notifications
