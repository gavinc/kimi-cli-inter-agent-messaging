# kimi-cli-inter-agent-messaging

Deterministic inter-agent messaging for Kimi CLI. Coordinate multiple AI agents with a simple, reliable pattern.

## The Pattern

**ONE place for messages:** `.agents/queue/todo/`

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

# Optional: Notify them to check
dm testing-agent
```

### Receive Messages

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

## Commands

| Command | Purpose | Use When |
|---------|---------|----------|
| `cm` | **Receive** messages | Session start, before going idle |
| `dm <agent>` | **Notify** to run cm | After creating task file |

## Critical Rules

1. **Create task file FIRST** - This IS the message
2. **`dm` is optional** - Just a ping to run `cm`
3. **Run `cm` to receive** - Only way to see messages

## Why This Works

- **Deterministic:** Files on disk don't disappear
- **Single source:** One place to check
- **Simple:** No .notifications, no complexity

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
