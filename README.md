# kimi-cli-inter-agent-messaging

Kimi CLI skill for coordinating multiple AI agents in tmux panes with task queues, file locking, and direct messaging.

## Features

- **Task Queue** with atomic file locking
- **Direct Messaging** via tmux interrupt or popup
- **Auto-Detection** of agent state
- **Session-Based** agents

## Install

```bash
git clone https://github.com/gavinc/kimi-cli-inter-agent-messaging.git \
  ~/.agents/skills/kimi-cli-inter-agent-messaging
```

## Usage

In Kimi:
```
/skill:kimi-cli-inter-agent-messaging
agent-onboard
```

## License

MIT

## Agent Identity in DMs

When sending direct messages, agents must be properly identified. Set the `AGENT_HANDLE` environment variable:

```bash
# For testing-agent (Tessa)
export AGENT_HANDLE="@testing-agent"

# For coding-agent (Chad)  
export AGENT_HANDLE="@coding-agent"
```

Then messages will correctly show:
```
📨 DM FROM @testing-agent: Message text
```

Instead of:
```
📨 DM FROM heavygee: Message text  ❌ Wrong!
```

Add this to your shell profile or set at session start.
