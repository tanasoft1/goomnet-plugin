---
name: goomnet
description: Read and write the goomnet project tracker at goomnet.tanasoft.mn — the user's team task board. Use whenever the user asks about their goomnet tasks, tickets, boards, channels, assignments, deadlines, what's on their plate, team workload, or asks to create/update a task or post a comment there. Triggers on "goomnet", "my tasks", "my tickets", "the board", "what am I assigned", "task 3683", "channel 33".
---

# goomnet

CLI: `goomnet` — on PATH while this plugin is enabled (bash, needs `curl` + `jq`).
Always outputs **raw JSON on stdout** — pipe through `jq`. Run `goomnet help` for the full flag list.

If it fails with `not configured`, the user hasn't entered credentials yet: tell them to run
`/plugin configure goomnet@tanasoft`, enter their goomnet email and password, then start a new
session. Never ask for the password in chat.

## Domain model

The API's vocabulary differs from everyday usage — translate before searching:

| User says | API calls it | Notes |
|---|---|---|
| project, board | **channel** | hierarchical (`parent_channel_id`); typed `TASK` or `TICKET` |
| task, ticket, item | **contents** | lives inside a channel; `content_id` is the identifier |
| comment | comments | hangs off a `content_id` |
| person | members / assignee | `assignee_id` is a user id (`goomnet me` gives the user's own) |

Enums:
- `status`: `TODO` `IN_PROGRESS` `DONE` `CANCELLED`
- `priority`: `LOW` `MEDIUM` `HIGH` `URGENT`

## The commands you'll actually reach for

```bash
goomnet mine                          # cross-channel: everything assigned to the user
goomnet mine --own created            # things they created instead
goomnet mine --status TODO --status IN_PROGRESS   # open work only
goomnet mine --expired                # overdue
goomnet mine --due-to 2026-08-31      # due before a date

goomnet channels                      # the boards the user belongs to
goomnet tasks <channel-id> --status TODO --priority URGENT
goomnet task <channel-id> <content-id>
goomnet comments <content-id>
goomnet stats                         # dashboard counters
goomnet search "<text>"
```

**Start with `goomnet mine`** for any "what should I work on / what's on my plate" question — it
spans every channel. `goomnet tasks <id>` is for drilling into one board.

## Writing

```bash
goomnet create-task <channel-id> "<title>" --desc "..." --priority HIGH --status TODO --assignee <user-id>
goomnet update-task <channel-id> <content-id> --status DONE
goomnet comment <channel-id> <content-id> "<text>"
```

Writes hit the user's real team board and are visible to colleagues. **Confirm before writing**
unless the user's request is unambiguously an instruction to write. There is no undo; the closest
thing is `--status CANCELLED`.

`DELETE` on channels/contents is deliberately blocked by the CLI (label deletes are allowed).
Deleting is a web-UI action. `delete-comment` refuses to delete a comment the user didn't write.

## Gotchas that will bite you

1. **Response envelopes are inconsistent.** Different endpoints return different shapes:
   - `{Data, RowCount}` — capital D (create-task, update-task, comment, tree, mine)
   - `{data, row_count}` — lowercase (notifs, search)
   - `{channel_contents, row_count}` / `{channel_comments, ...}` / `{channel_members, ...}`
   - bare array (channels, labels)

   Always probe with `jq 'if type=="object" then keys else "array" end'` before assuming a path.
   A robust accessor: `jq '.Data // .data // .channel_contents // .'`

2. **Singular vs plural filter params.** `goomnet tasks` (→ `/contents/`) sends `status=` and
   `priority=`; `goomnet mine` (→ `/dashboard/`) sends `statuses=` and `priorities=`. The CLI
   normalizes this — you pass `--status`/`--priority` to both — but it matters if you use `raw`.

3. **`/contents/ticket-done` is not a generic "mark done".** It requires a `notif_id` and is part
   of a notification approval flow. To close a task use `update-task --status DONE`.

4. **`mine`/`/dashboard/` rows name their fields differently** from `/contents/` rows: they carry
   `content_title`, `content_status` and `content_priority`, *not* `title`/`status`/`priority`.
   Reading `.status` off a dashboard row silently yields `null` — it does not error. Channel
   context comes as `channel_name` + `parent_channel_name` on the same row, so you rarely need a
   second call.

5. **"How many channels" has two right answers.** `goomnet channels` (`/channel/all`) returns the
   boards the user belongs to; `goomnet stats` counts more because it also includes the root
   client workspaces those boards hang under. State which you mean.

6. **Duplicate channel names are structural, not a bug** — each client workspace can have its own
   board with the same name (for example `TS - Ажлууд` or `Төлөвлөгөө` under several workspaces).
   Always disambiguate by id, and when reporting to the user include the parent workspace so the
   board is identifiable.

7. **Due dates are mostly absent.** Most items carry no `end_date`, so `--expired` and any
   deadline reasoning cover only the small minority that have one. Don't present "nothing is
   overdue" as if it meant "everything is on schedule".

8. **Much of the data is in Mongolian (Cyrillic).** Titles, channel names, and error messages come
   back in Mongolian — quote them as-is rather than translating unless asked.

## Escape hatch

Anything the CLI doesn't wrap:

```bash
goomnet raw GET  /report/task-channel
goomnet raw POST /some/path '{"json":"body"}'
```

Path is everything after `/api/web/private`. Auth, token refresh, and error handling still apply.
Endpoint groups not yet wrapped: `/report`, `/pdf`, `/chat`, `/evaluation`, `/reaction`,
`/themes`, `/user-report`, `/notif` mutations. The real API contract is the goomnet-backend repo's
`internal/http/routes/wroutes.go` plus the `Rq*` structs in `internal/http/models/`; its checked-in
Swagger spec is stale and should not be trusted.

## Auth

Credentials come from the plugin's config dialog (`/plugin configure goomnet@tanasoft`): the password lives in the system
keychain, and a SessionStart hook copies the values into `~/.claude/goomnet/.env` (chmod 600) for
the CLI. `.token` next to it caches the JWT and refresh token; the CLI auto-refreshes on 401 and
falls back to a full re-login, so you should never need `goomnet login` explicitly. JWT is RS256,
`aud: web`, ~12h expiry.
