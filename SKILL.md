---
name: inter-agent-messaging
description: Deterministic inter-agent messaging with global queues and config-driven project discovery. Includes optional flow skills for enforced agent compliance.
metadata:
  author: gavinc
  version: "3.0.0"
---

# Inter-Agent Messaging

This skill provides deterministic task queue management for coordinating multiple AI agents.

## Components

### Tools
- `cm` - Check messages (shows all queues from any directory)
- `agent-task` - Task management with file locking (legacy)
- `task-create` - **Enforced** task creation (standard markdown format, @agent)
  - Requires `AGENT_NAME` environment variable
- `dm-send` - **Enforced** direct messages (📬 From @agent: format)
  - Requires `AGENT_NAME` environment variable
- `agent-session-review` - Shows queue status before idle/exit
  - Observation only, no enforcement
  - Auto-runs on shell exit when hooks enabled
- `agent-setup` - Installation script

### Session Hooks (Optional)

Source the hooks for automatic session review on exit:

```bash
# Add to .bashrc
source ~/.config/agents/skills/inter-agent-messaging/agent-hooks.sh
```

This enables:
- **Exit review**: Shows tasks in progress when shell exits
- **`ar` alias**: Run `ar` anytime to see current queue state
- Non-blocking observation - just visibility, no enforcement

### Flow Skills (Enforced Workflows)

For automatic compliance enforcement, use these flow skills:

- **`/flow:chad-flow`** - Enforced workflow for coding agent
  - Auto-runs cm at start
  - Mandates testing task creation
  - Requires handoff documentation
  
- **`/flow:tessa-flow`** - Enforced workflow for testing agent  
  - Auto-runs cm at start
  - Mandates test documentation
  - Requires DM to coding agent

### Standard Usage

If not using flow skills, agents should manually:
1. Run `cm` at session start
2. Check for tasks in todo/doing
3. Create testing tasks for partner agent
4. Document handoffs
5. Update pane status

See README.md for detailed documentation.
