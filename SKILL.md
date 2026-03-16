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
- `agent-task` - Task management with file locking
- `agent-setup` - Installation script

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
