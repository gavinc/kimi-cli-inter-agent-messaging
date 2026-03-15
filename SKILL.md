---
name: inter-agent-messaging
description: Deterministic inter-agent messaging for AI agents. Simple task queue pattern - create task files, notify via dm, receive via cm.
compatibility: Requires tmux and kimi-cli. Agents run in separate tmux panes.
metadata:
  author: gavinc
  version: "2.0.0"
---

# Inter-Agent Messaging Skill

**Purpose:** Coordinate work between multiple AI agents with deterministic messaging.

**Core Principle:** Files on disk are the source of truth. Tmux notifications are ephemeral hints.

---

## The Pattern

**ONE place for messages:** `.agents/queue/todo/`

### Send a Message

```bash
# 1. Create task file = Send message
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

# 2. Optional: Notify them to check
dm testing-agent
```

### Receive a Message

```bash
# Run cm = Check messages
cm

# Output:
# ╔══════════════════════════════════════════════════════════════╗
# ║  📬 NEW TASKS                                                ║
# ╚══════════════════════════════════════════════════════════════╝
# 
# --- 2025-03-15-brief-desc.md ---
# # Task Title
# ...
```

---

## Commands

| Command | Purpose | Use When |
|---------|---------|----------|
| `cm` | **Check messages** (reads todo/) | Session start, before going idle |
| `dm <agent>` | **Notify** agent to run cm | After creating task file |
| `agent-task create <title>` | Create task file | Scripting task creation |
| `agent-task claim <id>` | Move task to doing/ | Starting work |
| `agent-task complete <id>` | Move task to done/ | Finishing work |

---

## Directory Structure

```
.agents/
├── queue/
│   ├── todo/       # Tasks waiting (cm reads from here)
│   ├── doing/      # Tasks in progress (optional)
│   └── done/       # Tasks completed (optional)
├── handoffs/       # Detailed context documents
│   ├── coding-agent/
│   └── testing-agent/
└── bin/            # This skill's scripts
```

---

## Critical Rules

1. **Create task file FIRST** - This IS the message
2. **`dm` is optional** - Just a ping saying "run cm"
3. **Run `cm` to receive** - Only way to see messages
4. **AGENT_NAME is optional** - Used by dm to identify sender

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

This helps `dm` identify who is sending the notification.

### Send a Task

```bash
# Create task file
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

# Notify recipient
dm testing-agent
```

### Receive Tasks

```bash
# Check for new tasks
cm

# Claim a task
agent-task claim 2025-03-15-test-feature.md

# Do the work...

# Complete it
agent-task complete 2025-03-15-test-feature.md
```

---

## Complete Workflow Example

```bash
# Chad (coding-agent) finishes implementation
cd ~/project

# 1. Create task for Tessa
cat > .agents/queue/todo/2025-03-15-auth-tests.md << 'EOF'
# Test Task: Auth System

**From:** @coding-agent
**To:** @testing-agent
**Priority:** high

## Context
Auth system implemented and deployed.

## Acceptance Criteria
- [ ] Login works with valid credentials
- [ ] Login fails with invalid credentials
- [ ] Password reset flow works

## Handoff
See detailed notes: .agents/handoffs/coding-agent/2025-03-15-auth.md
EOF

# 2. Create detailed handoff
cat > .agents/handoffs/coding-agent/2025-03-15-auth.md << 'EOF'
# Auth Implementation Details

## Files Changed
- src/auth/login.ts
- src/auth/reset.ts

## Test URLs
- https://example.com/login
EOF

# 3. Notify Tessa
dm testing-agent

# Tessa (testing-agent) receives notification
# → Runs 'cm'
# → Sees the task
# → Claims it: agent-task claim 2025-03-15-auth-tests.md
# → Does the testing
# → Reports back with her own task file
```

---

## Why This Works

| Mechanism | Purpose | Persistence |
|-----------|---------|-------------|
| **Task files** | Actual message content | ✅ Disk (100% reliable) |
| **`cm`** | Read messages | ✅ Reads disk |
| **`dm`** | Notification ping | ❌ Ephemeral (best effort) |

**Deterministic:** Even if `dm` fails, the task file exists. Recipient runs `cm` → sees message.

---

## Troubleshooting

### "dm: command not found"
```bash
# Check PATH
export PATH="$HOME/.agents/skills/kimi-cli-inter-agent-messaging/scripts:$PATH"
```

### "Agent not found"
```bash
# Check pane titles
tmux list-panes -a -F '#{pane_id}: #{pane_title}'
# Use exact name from title (after the colon)
```

### "Sent dm but no response"
`dm` is just a notification. The recipient must run `cm` to see the actual message. They may be busy or missed the notification. The task file is waiting in `todo/`.

---

## Session Naming

Agents are named: `<agent-name>`

Examples:
- `testing-agent`
- `coding-agent`
- `docs-agent`

Use these exact names with `dm`:
```bash
dm testing-agent
dm coding-agent
```

---

## Version

v2.0.0 - Simplified deterministic messaging
