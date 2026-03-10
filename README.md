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
