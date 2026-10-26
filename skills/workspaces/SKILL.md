---
description: List the goomnet workspaces the user belongs to, with their projects and boards.
argument-hint: "[workspace name]"
disable-model-invocation: true
---

List the user's goomnet workspaces. Arguments: `$ARGUMENTS`

1. Run `goomnet tree`. It returns every workspace the user belongs to, each with
   `projects[].channels[]` (boards: `channel_id`, `channel_name`, `type`).
2. If an argument is given, keep only workspaces whose name contains it, ignoring case.
3. Reply with a table: workspace ID, workspace name, and the user's role in it (from
   `goomnet workspaces`). Under the table, list each workspace's boards as
   `channel_name (id, type)`, grouped by project. Say "no projects yet" for an empty workspace.
