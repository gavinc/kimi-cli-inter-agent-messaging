#!/bin/bash
# Agent Hooks - Part of inter-agent-messaging skill
# Source this in your shell to enable session review on exit
#
# Add to .bashrc:
#   export AGENT_NAME=coding-agent
#   source ~/.config/agents/skills/inter-agent-messaging/agent-hooks.sh

# Only run if AGENT_NAME is set
if [ -z "$AGENT_NAME" ]; then
    return 0 2>/dev/null || exit 0
fi

# Ensure skill scripts are in PATH
SKILL_SCRIPTS="$HOME/.config/agents/skills/inter-agent-messaging/scripts"
if [[ ":$PATH:" != *":$SKILL_SCRIPTS:"* ]]; then
    export PATH="$SKILL_SCRIPTS:$PATH"
fi

# Cooldown: only show review every 5 minutes
AGENT_REVIEW_COOLDOWN=180  # seconds

agent_exit_review() {
    local last_review_file="/tmp/.agent-review-${AGENT_NAME}-$(whoami)"
    local current_time=$(date +%s)
    local last_review=0
    
    # Read last review time if exists
    if [ -f "$last_review_file" ]; then
        last_review=$(cat "$last_review_file" 2>/dev/null || echo 0)
    fi
    
    local time_since=$((current_time - last_review))
    
    # Only show if cooldown has passed
    if [ "$time_since" -ge "$AGENT_REVIEW_COOLDOWN" ]; then
        if command -v agent-session-review >/dev/null 2>&1; then
            agent-session-review 2>/dev/null
            # Update last review time
            echo "$current_time" > "$last_review_file"
        fi
    fi
}

# Set up trap (only once)
if [ -z "$AGENT_HOOKS_SET" ]; then
    trap 'agent_exit_review' EXIT
    export AGENT_HOOKS_SET=1
fi

# Optional: Show review on demand with 'ar' alias
alias ar='agent-session-review'

