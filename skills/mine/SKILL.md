---
description: Show the user's open goomnet tasks (assigned to them, TODO or IN_PROGRESS) grouped by workspace.
argument-hint: "[created | all | workspace name]"
disable-model-invocation: true
---

Show the user's goomnet tasks grouped by workspace. Arguments: `$ARGUMENTS`

1. Run `goomnet mine --status TODO --status IN_PROGRESS --by-workspace`. Adjust for the arguments:
   - `created`: add `--own created` (tasks they created instead of tasks assigned to them)
   - `all`: drop both `--status` flags to include DONE and CANCELLED
   - anything else is a workspace name: keep only the workspace whose name contains it, ignoring case
2. Output is a JSON array of `{workspace_id, workspace_name, count, tasks}`. Task rows use
   `content_id`, `content_title`, `content_status`, `content_priority`, `channel_id`, `channel_name`,
   `end_date`, `is_expired` (not `title`/`status`/`priority`).
3. Reply with one heading per workspace, then a table per workspace: ID, title, board, status,
   priority, due date. Sort URGENT and HIGH first, and mark overdue rows. Quote titles as-is,
   Mongolian included.
4. If nothing matches, say so in one line. If tasks have no due dates, don't call them on schedule.

If the CLI reports `not configured`, follow the setup note in the goomnet skill.
