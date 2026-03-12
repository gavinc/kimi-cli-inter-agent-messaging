# Queue Location - CRITICAL

## ONE QUEUE ONLY

All tasks MUST be placed in:
```
/home/heavygee/coding/vercel-chat/.agents/queue/
```

## Structure

```
.agents/queue/
├── todo/           # New tasks waiting
├── doing/          # Tasks in progress
├── done/           # Completed tasks
└── TEMPLATE.md     # Task template
```

## WRONG Locations (NEVER USE)

❌ ~/monorepo/.agents/queue/  
❌ ~/apps/portal/.agents/queue/  
❌ Any other subdirectory

## Why This Matters

The `cm` (check messages) command ONLY searches:
- `/home/heavygee/coding/vercel-chat/.agents/queue/todo/`
- `/home/heavygee/coding/vercel-chat/.agents/queue/doing/`

Tasks in other locations are INVISIBLE to agents.

## Creating Tasks

```bash
# Correct:
cp .agents/queue/TEMPLATE.md .agents/queue/todo/my-task.md

# Wrong - will not be seen:
cp .agents/queue/TEMPLATE.md monorepo/.agents/queue/todo/my-task.md
```

## Verification

Always run `cm` after creating a task to confirm it's visible.

