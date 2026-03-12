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
- **PATH setup**: `.agents/bin` must be in your PATH for `cm`, `dm` commands to work

### PATH Setup (Important!)

The skill installs binaries to `.agents/bin/` which must be in your PATH. The `agent-onboard` script will attempt to add this automatically, but if commands like `cm` or `dm` are not found, manually add to your shell profile:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="/path/to/your/project/.agents/bin:$PATH"
```

Or for current session only:
```bash
export PATH="$PWD/.agents/bin:$PATH"
```

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

### "cm: command not found" or "dm: command not found"
The `.agents/bin` directory is not in your PATH. Fix:

```bash
# For current session
export PATH="$PWD/.agents/bin:$PATH"

# For permanent fix, add to ~/.bashrc or ~/.zshrc:
echo 'export PATH="/path/to/project/.agents/bin:$PATH"' >> ~/.bashrc
```

Then reload your shell or run `source ~/.bashrc`.

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
Check agent state by looking at the FIRST word of the status bar:
```bash
tmux capture-pane -t <pane> -p | tail -1 | awk '{print $1}'
```
- `agent` = idle (full status bar showing), should receive
- `context:` = busy (ONLY context showing, short status), will receive after interrupt  
- `shell` = shell mode, popup used

### How Messages Actually Work

**Important:** The target pane is running kimi-cli (an AI agent), not a shell.

When you run `dm @agent-name "message"`:
1. The script detects the target agent's state
2. If interruptive: sends Ctrl-C, then sends the raw text
3. If passive: sends the raw text directly
4. The AI receives the text as input and processes it

**There are no color codes or formatting** - the AI reads plain text. The emoji prefixes (🚨, 📨) are just text characters that help distinguish message types.

---

## Technical Details

### State Detection

The `dm` script automatically detects target agent state:

| First Word | Meaning | Status Bar Appearance | Delivery |
|------------|---------|----------------------|----------|
| `agent` | Agent mode, idle | Full line: `agent (kimi...) @: mention files...` | Direct interrupt |
| `context:` | Agent mode, busy | **ONLY** `context: 41.5%...` (short) | Interrupt + message |
| `shell` | Shell mode | `shell ctrl-x...` | Popup overlay |

### File Locking

Task claiming uses atomic `mkdir` locks:
- Prevents race conditions
- Auto-detects stale locks (agent died)
- Lock metadata: owner, timestamp, PID

---

## Notification Protocol: Notify Idle Agents

**Rule:** When you create a task for another agent, you MUST notify them if they are idle.

### Why?

Agents only check their queue:
1. At session start (via `cm`)
2. When manually prompted

If an agent is idle and you queue work, they won't know unless you tell them.

### The Protocol

**Step 1: Create the task**
```bash
agent-task create "Test new feature" @testing-agent
# Task created: 2026-03-10-test-new-feature.md
```

**Step 2: Check if target agent is idle**
```bash
# Check status bar first word
tmux capture-pane -t <target-pane> -p | tail -1 | awk '{print $1}'
```

**Step 3: Notify if idle**

| Status | Action |
|--------|--------|
| `agent` | **IDLE** - Send DM with `dm -c` |
| `context:` | **BUSY** - Silent (they'll check when done) |
| `shell` | **SHELL** - Use popup with `dm -i` |

**Step 4: Send appropriate message**

```bash
# For idle agents (dm -c checks idle first)
dm -c @testing-agent "📬 New task from @coding-agent: Test new feature. Run 'cm' to check."

# For urgent matters (interrupts even if busy)
dm -i @testing-agent "🚨 URGENT: Production bug fix needed"
```

### Automated Solution

Add to your shell profile:

```bash
# Create task AND notify if idle
agent-task-notify() {
    local task_name="$1"
    local target_agent="$2"
    
    # Create the task
    agent-task create "$task_name" "$target_agent"
    
    # Extract agent name from handle (remove @)
    local agent_name="${target_agent#@}"
    
    # Map agent to pane (customize for your setup)
    local pane=""
    case "$agent_name" in
        testing-agent) pane="0:1.2" ;;
        coding-agent) pane="0:1.3" ;;
        *) echo "Unknown agent: $target_agent"; return 1 ;;
    esac
    
    # Check if idle
    local status=$(tmux capture-pane -t "$pane" -p 2>/dev/null | tail -1 | awk '{print $1}')
    
    if [ "$status" = "agent" ]; then
        # Idle - send notification
        dm -c "$target_agent" "📬 New task from $(whoami): $task_name. Run 'cm' to check."
        echo "✅ Task created and $target_agent notified (idle)"
    elif [ "$status" = "context:" ]; then
        # Busy - silent
        echo "✅ Task created ($target_agent busy, will see when done)"
    else
        # Unknown state - still notify
        dm "$target_agent" "📬 New task: $task_name. Run 'cm' to check."
        echo "✅ Task created and $target_agent notified"
    fi
}
```

Usage:
```bash
agent-task-notify "Test auth fix" @testing-agent
```

### Agent Responsibility: Check Mail at Session End

**All agents should run `cm` at the end of every session/context run.**

Add to agent system prompts:
```
Before ending session, run `cm` to check for queued tasks.
If tasks exist: Report to user and ask if they should be picked up.
```

This ensures no tasks are missed when agents become idle.

---

## Complete Workflow Example

```bash
# Chad (coding-agent) finishes feature implementation
cd ~/coding/vercel-chat

# 1. Create testing task for Tessa
agent-task create "Test auth system" @testing-agent
# → Created: 2026-03-10-test-auth-system.md

# 2. Create detailed handoff
cat > .agents/handoffs/2026-03-10-auth-system.md << 'EOF'
# Handoff: Auth System Implementation
...
EOF

# 3. Notify Tessa if idle
dm -c @testing-agent "📬 New testing task: Auth System. Run 'cm' for details."
# → Checks if 0:1.2 shows "agent" (idle), sends message if so

# 4. Update own status
.agent-status @coding-agent "done | Task queued for Tessa"

# Tessa (testing-agent) receives message
# → Runs 'cm' to check queue
# → Sees task, claims it, starts testing
```

---

## Important Notes

### Don't Send Echo Commands

**WRONG:**
```bash
# Don't do this - echo is unnecessary
tmux send-keys -t 0:1.2 "echo 'message'" Enter
```

**RIGHT:**
```bash
# Send raw message, agent will see it
tmux send-keys -t 0:1.2 "message" Enter
# Or use the dm script:
dm @testing-agent "message"
```

### Agent Self-Boot Check

**Every agent should run `cm` at:**
1. Session start
2. After completing work (before going idle)
3. When explicitly asked by user

This ensures the queue is always checked when transitioning to idle state.

---

## Troubleshooting

### "I sent a task but they didn't respond"

Check:
1. Was the task created? `agent-queue status`
2. Was the agent notified? Check their pane history
3. Is the agent idle? `tmux capture-pane -t <pane> -p | tail -1`
4. Did they run `cm`? Ask them to check messages

### "dm says agent is busy but they look idle"

The status bar detection looks at the FIRST word:
- `agent` = full status bar showing = IDLE
- `context:` = only context showing = BUSY (agent is thinking)

If the status bar is truncated or blank, the detection may fail.

### "Task was claimed but work wasn't started"

Agent may not have run `cm` after claiming. Remind them:
```bash
dm -c @agent-name "You claimed a task but haven't started. Run 'cm' to see details."
```
