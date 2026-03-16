---
name: chad-flow
description: Enforced workflow for Chad (coding-agent). Automatically runs queue checks at start and end of every session. Use /flow:chad-flow to invoke Chad with compliance enforcement.
type: flow
metadata:
  author: gavinc
  version: "3.0.0"
---

# Chad Flow - Enforced Coding Agent Workflow

This flow skill enforces Chad's work protocol by automating queue checks at the beginning and end of every session.

## When to Use

Use `/flow:chad-flow` instead of `kimi-chad` when you want:
- Automatic queue status check on start
- Mandatory compliance verification on completion
- Guaranteed testing task creation
- Proper handoff documentation

## Usage

```bash
# Start enforced workflow
/flow:chad-flow write the authentication middleware

# Or just start the flow, then tell me what to do
/flow:chad-flow
> write the authentication middleware
```

## Flow Diagram

```mermaid
flowchart TD
    A([BEGIN]) --> B[Run cm and report queue status]
    B --> C{Tasks waiting?}
    C -->|Yes| D[Ask user: Pick up existing task or start new?]
    C -->|No| E[Wait for user's instruction]
    D --> F[User provides instruction]
    E --> F
    F --> G[Execute work following all coding protocols]
    G --> H{Work complete?}
    H -->|Yes| I[Run cm - check current state]
    I --> J[Verify: Task moved to done?]
    J -->|No| K[Move task to done/ or ask user about incomplete work]
    J -->|Yes| L[Verify: Testing task created for Tessa?]
    L -->|No| M[Create testing task: agent-task create --project /path "Test: [Feature]" testing-agent]
    L -->|Yes| N[Verify: Handoff documented?]
    M --> N
    K --> N
    N -->|No| O[Create handoff in .agents/handoffs/]
    N -->|Yes| P[Update pane title to chad | idle | 📬N]
    O --> P
    P --> Q{User has more work?}
    Q -->|Yes| F
    Q -->|No| R([END])
```

## Alternative D2 Format

```d2
BEGIN -> check_queue -> has_work -> get_instruction -> do_work -> check_complete
BEGIN: |md
  # BEGIN
  
  Run `cm` and report queue status to user.
  Check for tasks in todo/ and doing/.
|

check_queue: Run `cm` and report queue status

has_work: |md
  # Check for Work
  
  Are there tasks in the queue?
  - If yes: Ask user whether to pick up existing task or start new
  - If no: Wait for user's instruction
|

get_instruction: Receive user's instruction

do_work: |md
  # Execute Work
  
  Follow all coding protocols:
  - Read relevant code and specs
  - Consider testing implications
  - Implement following project patterns
  - Run npm run build to verify
  - Document decisions
|

check_complete: |md
  # Work Complete Verification
  
  Before completing, verify:
  1. Task moved to done/?
  2. Testing task created for Tessa?
  3. Handoff documented?
  4. Pane title updated?
  
  If any check fails, complete it now.
|

check_complete -> more_work: All checks passed
more_work: User has more work?
more_work -> get_instruction: Yes
more_work -> END: No

END: |md
  # END
  
  Run `cm` final check.
  Update pane title to "chad | idle | 📬N".
  Session complete.
|
```

## Decision Points

At decision nodes, I will output my choice:

```
<choice>begin_work</choice>
<choice>create_testing_task</choice>
<choice>end_session</choice>
```

## Commands Used

| Command | When | Purpose |
|---------|------|---------|
| `cm` | Start, End | Check all queues |
| `agent-task claim <id> chad` | Beginning | Claim task from todo |
| `agent-task create --project /path "Test: [Feature]" testing-agent` | End | Create testing task |
| `agent-task complete <id>` | End | Mark task done |
| `tmux select-pane -T "chad | busy"` | Start | Set pane title |
| `tmux select-pane -T "chad | idle | 📬N"` | End | Set idle title |

## Why Use This Flow?

Without this flow:
- I might forget to check messages
- I might not create testing tasks
- I might leave tasks in doing/
- Inconsistent handoffs

With this flow:
- ✅ Queue check is **mandatory** at start
- ✅ Testing task creation is **mandatory** at end
- ✅ Handoff documentation is **enforced**
- ✅ Pane title updates are **automated**
- ✅ I **cannot** end the session without completing all steps

## Comparison

| | Regular `kimi-chad` | `/flow:chad-flow` |
|-|---------------------|-------------------|
| Queue check | Optional (I often forget) | **Mandatory** |
| Testing tasks | Often skipped | **Enforced** |
| Handoffs | Inconsistent | **Required** |
| Pane title | Rarely updated | **Automated** |
| End ritual | None | **Structured** |

## Example Session

**User:** `/flow:chad-flow implement user authentication`

**Me (step 1 - BEGIN):** Running `cm`...
[cm output]
📬 1 task waiting: test-v3-deployment
Do you want me to:
1. Pick up existing task: test-v3-deployment
2. Start new task: implement user authentication

**User:** `2`

**Me (step 2 - do_work):** [Implements authentication...]

**Me (step 3 - check_complete):** Work complete. Running verification:
- ✅ Code implemented
- ✅ Build passes
- ⚠️  Testing task not created yet
- Creating testing task: `agent-task create --project ~/coding/vercel-chat/monorepo "Test: User authentication" testing-agent`
- ✅ Testing task created
- ⚠️  Handoff not documented
- Creating handoff in `.agents/handoffs/2025-03-16-user-authentication.md`
- ✅ Handoff created
- Updating pane title to "chad | idle | 📬1"

**Me (step 4 - END or more_work):** Session complete. Task in done/, testing task queued, handoff documented. More work? (yes/no)

**User:** `no`

**Me:** [END] Session ended. Run `/flow:chad-flow` for next session.
