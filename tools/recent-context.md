# recent-context Tool

## Purpose
Retrieve recent scrollback from an agent's tmux pane to see their current activity and context.

## Usage
```bash
recent-context <agent-id> [lines]
```

### Arguments
- `agent-id` - The agent to retrieve context from:
  - `testing-agent` or `tessa` - Tessa (testing-agent)
  - `coding-agent` or `chad` - Chad (coding-agent)
- `lines` - Number of lines to retrieve (default: 500)

## Examples
```bash
# Get last 500 lines from Tessa
recent-context testing-agent

# Get last 100 lines from Chad
recent-context coding-agent 100

# Using aliases
recent-context tessa
recent-context chad 50
```

## How It Works
The tool captures the tmux buffer from the agent's dedicated pane:
- Tessa: `workin:k-tessa.0`
- Chad: `workin:k-chad.0`

## Use Cases
- Check what another agent is currently working on
- See recent errors or output without interrupting
- Review context before sending a message
- Monitor agent activity for coordination

## Requirements
- tmux session named "workin" must be running
- Agent panes must be active (k-tessa, k-chad)
- Tool must be run from a tmux session or terminal with tmux access
