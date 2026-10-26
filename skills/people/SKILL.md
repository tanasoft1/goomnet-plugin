---
description: List the members of the user's goomnet workspaces, optionally filtered by workspace name.
argument-hint: "[workspace name or id]"
disable-model-invocation: true
---

List the people in the user's goomnet workspaces. Arguments: `$ARGUMENTS`

1. Run `goomnet people $ARGUMENTS`. With no argument it covers every workspace; an argument keeps
   workspaces whose name contains it (ignoring case) or whose id equals it.
2. Output is a JSON array of `{workspace_id, workspace_name, members}`; each member has `user_id`,
   `first_name`, `last_name`, `email`, `role` (OWNER, ADMIN, EDITOR, ...), `is_scoped` and
   `granted_channel_count` (scoped members only see the boards granted to them).
3. Reply with one table per workspace: user ID, name, email, role. List OWNER and ADMIN first, then
   the rest alphabetically. Mark the current user with "(you)"; `goomnet me` gives their user_id.
4. If no workspace matches the filter, say so and list the workspace names that do exist.

Mention that the user IDs are what `--assignee` takes when assigning tasks.
