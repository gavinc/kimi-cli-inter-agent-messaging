---
name: inter-agent-messaging
description: Coordinate multiple AI agents in tmux panes with task queues, file locking, and direct messaging. Enables parallel agent workflows with async task coordination and urgent interrupt capabilities.
compatibility: Requires tmux and kimi-cli (or compatible AI CLI). Agents must run in separate tmux panes within the same session.
metadata:
  author: gavinc
  version: "1.0.0"
---

# Inter-Agent Messaging Skill

**Purpose:** Coordinate work between multiple AI agents in the same project.

---

## Prerequisites

- **tmux** installed
- **kimi CLI** installed  
- Multiple agents need to coordinate on a project

---

## Quick Start

### Option 1: Already in tmux?

If you're already in a tmux session, run:

```bash
agent-onboard
```

This will:
1. Detect current tmux session
2. Guide you to create/add agent panes
3. Set up messaging infrastructure

### Option 2: Not in tmux?

**You must exit your current agent and start from shell.** 

From your **shell** (not inside kimi), run:

```bash
# Navigate to your project
cd /path/to/your/project

# Run the multi-agent setup
.agent-setup-multi
```

This creates:
- tmux session named after your project
- Main pane: Your original agent
- Additional panes: Named agents you define

**To rejoin later:**
```bash
tmux attach -t <project-name>
```

---

## Onboarding Wizard

When you run `agent-onboard`, you'll be prompted:

```
=== Multi-Agent Onboarding ===

Project directory: /current/working/dir

Current panes in this tmux session:
  0: bash (current)

Create additional agent panes?

How many agents? [2]: 2

Agent 1 name [agent-1]: architect
Agent 1 scope [general]: System design and architecture decisions

Agent 2 name [agent-2]: tester  
Agent 2 scope [general]: Testing and quality assurance

Creating panes...
  - Created pane 1: architect
  - Created pane 2: tester

Starting agents in new panes...
  - Started kimi --session architect-<project>
  - Started kimi --session tester-<project>

Setup complete! Available commands:
  dm <agent> <message>  - Direct message
  agent-task create ... - Create task
  cm                    - Check messages

Test: dm architect "Hello from main"
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `cm` | Check messages (polls todo/, doing/, done/, .notifications) |
| `dm <agent> <message>` | Direct message via tmux interrupt |
| `agent-task create <title> [agent]` | Create new task |
| `agent-task claim <id> <agent>` | Claim task (atomic lock) |
| `agent-task complete <id>` | Mark task done |
| `agent-task list` | Show all tasks |
| `agent-title <name>` | Set current pane title |

---

## Directory Structure

```
.agents/
├── queue/
│   ├── todo/       # New tasks waiting
│   ├── doing/      # Tasks being worked on (with locks)
│   ├── done/       # Tasks completed
│   ├── completed/  # Archived
│   └── .locks/     # File locks (mkdir-based)
├── handoffs/       # Detailed reports/context
└── bin/            # Helper scripts
```

---

## Session Naming Convention

Agents are named: `<agent-name>-<project>`

Examples:
- `architect-myapp`
- `tester-myapp`
- `docs-myapp`

This allows:
- `/import architect-myapp` (bring their context into your session)
- Multiple projects with same agent roles

---

## Workflow Example

```bash
# Main agent creates task for architect
agent-task create "Design auth system" architect

# Direct message
 dm architect "Need auth design by EOD"

# Architect (in their pane) claims task
agent-task claim design-auth-system-1234567890 architect

# Architect completes, marks done
agent-task complete design-auth-system-1234567890

# Main agent imports architect's session for handoff
/import architect-myapp
```

---

## Migration: Single Agent → Multi-Agent

If you have an existing agent session you want to preserve:

1. **Note your session ID** (from status bar or run `/debug`)
2. **Export context** (optional): `/export my-work.md`
3. **Exit agent** (Ctrl-D)
4. **Run setup from shell:**
   ```bash
   cd your-project
   .agent-setup-multi
   ```
5. **Resume your session** in main pane:
   ```bash
   kimi --session <your-session-id> -w .
   ```

---

## Troubleshooting

### "Not in tmux"
You must run from within a tmux session, or use the shell setup script.

### "Agent pane not found"
Check pane titles:
```bash
tmux list-panes -F '#{pane_index}: #{pane_title}'
```

Set title if missing:
```bash
agent-title <name>
```

### "dm fails silently"
Check agent state:
```bash
tmux capture-pane -t <pane> -p | tail -1
```
- `agent` = idle, should receive
- `context:` = busy, will receive after interrupt
- `shell` = shell mode, popup used

---

## Technical Details

### State Detection

The `dm` script automatically detects target agent state:

| Status Bar | State | Delivery |
|------------|-------|----------|
| `agent` | Agent mode, idle | Direct interrupt |
| `context:` | Agent mode, busy | Interrupt + message |
| `shell` | Shell mode | Popup overlay |

### File Locking

Task claiming uses atomic `mkdir` locks:
- Prevents race conditions
- Auto-detects stale locks (agent died)
- Lock metadata: owner, timestamp, PID
