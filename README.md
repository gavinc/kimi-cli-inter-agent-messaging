# kimi-cli-inter-agent-messaging

Deterministic inter-agent messaging for Kimi CLI. Coordinate multiple AI agents with a simple, reliable pattern.

## The Pattern

**Task queue in three states:**
- `todo/` - New tasks waiting
- `doing/` - Tasks in progress  
- `done/` - Tasks completed

### Send a Message

```bash
# Create task file = Send message
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

# Notify them (appears in their context without interrupting)
dm testing-agent
```

### Receive Messages

```bash
# Run cm = Check all tasks
cm

# Output shows all three states:
# ╔══════════════════════════════════════════════════════════════╗
# ║  📬 NEW TASKS (todo/)                                        ║
# ╚══════════════════════════════════════════════════════════════╝
# 
# ╔══════════════════════════════════════════════════════════════╗
# ║  🔨 IN PROGRESS (doing/)                                     ║
# ╚══════════════════════════════════════════════════════════════╝
#
# ╔══════════════════════════════════════════════════════════════╗
# ║  ✅ RECENTLY DONE (done/)                                    ║
# ╚══════════════════════════════════════════════════════════════╝
```

### Manage Tasks

```bash
# Claim a task (move todo → doing)
agent-task claim 2025-03-15-brief-desc.md

# Complete a task (move doing → done)
agent-task complete 2025-03-15-brief-desc.md
```

## Commands

| Command | Purpose |
|---------|---------|
| `cm` | Check all tasks (todo, doing, done) |
| `dm <agent>` | Notify agent to check tasks |
| `agent-task claim <file>` | Move task from todo to doing |
| `agent-task complete <file>` | Move task from doing to done |

## Key Points

- **Create task file FIRST** - This IS the message
- **`dm` is optional** - Just a notification that appears in context
- **`dm` doesn't interrupt** - Message appears without breaking agent's flow
- **Run `cm` to see all tasks** - Shows todo, doing, and recently done
- **AGENT_NAME is optional** - Used by dm to identify sender

## Install

```bash
git clone https://github.com/gavinc/kimi-cli-inter-agent-messaging.git \
  ~/.agents/skills/kimi-cli-inter-agent-messaging
```

Add to PATH in `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/.agents/skills/kimi-cli-inter-agent-messaging/scripts:$PATH"
```

## License

MIT
