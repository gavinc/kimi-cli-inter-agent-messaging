---
name: tessa-flow
description: Enforced workflow for Chad (coding-agent). Automatically runs queue checks at start and end of every session. Use /flow:chad-flow to invoke Chad with compliance enforcement.
type: flow
metadata:
  author: gavinc
  version: "3.0.0"
---

# Tessa Flow - Enforced Testing Agent Workflow

This flow skill enforces Tessa's work protocol by automating queue checks and mandating documentation at the beginning and end of every testing session.

## When to Use

Use /flow:tessa-flow instead of kimi-tessa when you want:
- Automatic queue status check on start
- Mandatory test documentation
- Enforced handoff to Chad
- Proper DM notification on completion

## Usage

```bash
# Start enforced testing workflow
/flow:tessa-flow test the new authentication flow

# Or just start the flow
/flow:tessa-flow
> test the new authentication flow
```

## Flow Diagram

```mermaid
flowchart TD
    A([BEGIN]) --> B[Run cm and report queue status]
    B --> C{Testing tasks waiting?}
    C -->|Yes| D[Claim task: agent-task claim <id> tessa]
    C -->|No| E[Wait for user's test instruction]
    D --> F[Read task details and context]
    E --> F
    F --> G[Execute tests: npm run test:e2e]
    G --> H{Tests complete?}
    H -->|Pass| I[Document results in handoffs/testing-agent/]
    H -->|Fail| J[Record screenshots/videos of failures]
    J --> I
    I --> K[Complete task: agent-task complete <id>]
    K --> L[DM Chad: ~/.config/agents/skills/inter-agent-messaging/scripts/dm coding-agent "📬 Test complete. Handoff ready. /flow:chad-flow review test results"]
    L --> M[Verify all 4 requirements met]
    M --> N{User has more tests?}
    N -->|Yes| C
    N -->|No| O[Update pane title to tessa | idle | 📬N]
    O --> P([END])
```

## Commands Used

| Command | When | Purpose |
|---------|------|---------|
| `cm` | Start, End | Check all queues |
| `agent-task claim <id> tessa` | Beginning | Claim task from todo |
| `agent-task complete <id>` | End | Mark task done |
| `~/.config/agents/skills/inter-agent-messaging/scripts/dm coding-agent "message"` | End | **DM Chad with test results and next flow command** |
| `npm run test:e2e` | During | Execute tests |
| `tmux select-pane -T "tessa | busy"` | Start | Set pane title |
| `tmux select-pane -T "tessa | idle | 📬N"` | End | Set idle title |

## Mandatory Verification (End of Session)

Before ending, Tessa MUST verify:

1. ✅ Task file moved to done/ (via agent-task complete)
2. ✅ Handoff file exists at handoffs/testing-agent/YYYY-MM-DD-[task-name].md
3. ✅ DM sent to @coding-agent
4. ✅ Pane title updated to "tessa | idle"

**If ANY check fails, the flow loops back until complete.**

## Decision Points

```
<choice>claim_task</choice>
<choice>tests_passed</choice>
<choice>tests_failed</choice>
<choice>documentation_complete</choice>
<choice>end_session</choice>
```

## Why Use This Flow?

Without this flow:
- Tests run but not documented
- Handoffs incomplete or missing
- Chad not notified of results
- No verification of completion

With this flow:
- ✅ Queue check is **mandatory** at start
- ✅ Test documentation is **enforced**
- ✅ Handoff to Chad is **required**
- ✅ DM notification is **automated**
- ✅ I **cannot** end without completing all 4 verification steps

## Example Session

**User:** /flow:tessa-flow

**Me (step 1 - BEGIN):** Running cm...
[cm output]
📂 monorepo
📬 TODO: test-v3-inter-agent-messaging
🔨 DOING: (none)

Claiming task: agent-task claim test-v3-inter-agent-messaging-1773671002 tessa
✅ Task claimed.

**Me (step 2 - execute):** Running tests: npm run test:e2e
[test output]
✅ 5 passed, 0 failed

**Me (step 3 - document):** Creating handoff in handoffs/testing-agent/2025-03-16-test-v3-inter-agent-messaging.md
[handoff content]
✅ Handoff created.

Completing task: agent-task complete test-v3-inter-agent-messaging-1773671002
✅ Task complete.

**Me (step 4 - notify):** Sending DM to Chad:
```bash
**Me (step 4 - notify):** Sending DM to Chad:
```bash
~/.config/agents/skills/inter-agent-messaging/scripts/dm coding-agent "📬 Test complete: v3.0 deterministic behavior. Handoff ready in monorepo/.agents/handoffs/testing-agent/"
```
```

Verifying completion:
- ✅ Task in done/
- ✅ Handoff documented
- ✅ DM sent
- ✅ Pane title updated

**Me (step 5 - END):** Testing session complete. More work? (yes/no)

**User:** no

**Me:** [END] Session ended. Run /flow:tessa-flow for next testing session.
