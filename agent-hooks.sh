#!/bin/bash
# Agent Hooks - Part of inter-agent-messaging skill
# Source this in your shell to enable session review on exit
#
# Add to .bashrc:
#   source ~/.config/agents/skills/inter-agent-messaging/agent-hooks.sh

# Only run if AGENT_NAME is set
if [ -z "$AGENT_NAME" ]; then
    # Silently skip if not in agent context
    return 0 2>/dev/null || exit 0
fi

# Ensure skill scripts are in PATH
SKILL_SCRIPTS="$HOME/.config/agents/skills/inter-agent-messaging/scripts"
if [[ ":$PATH:" != *":$SKILL_SCRIPTS:"* ]]; then
    export PATH="$SKILL_SCRIPTS:$PATH"
fi

# Run session review on shell exit
# This is OBSERVATION ONLY - shows queue state, doesn't block
agent_exit_review() {
    # Check if agent-session-review exists
    if command -v agent-session-review >/dev/null 2>&1; then
        agent-session-review 2>/dev/null
    fi
}

# Set up trap (only once)
if [ -z "$AGENT_HOOKS_SET" ]; then
    trap 'agent_exit_review' EXIT
    export AGENT_HOOKS_SET=1
fi

# Optional: Show review on demand with 'ar' alias
alias ar='agent-session-review'

