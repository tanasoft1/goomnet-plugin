# goomnet plugin for Claude Code

Lets Claude read and update your tasks on [goomnet](https://goomnet.tanasoft.mn): what's assigned
to you, boards, comments, creating and closing tasks. Ask in plain language ("what's on my plate
in goomnet?", "mark 3683 done") or use a slash command:

| Command | What it shows |
|---|---|
| `/goomnet:mine [status] [created] [workspace]` | Your tasks grouped by workspace; filter by status (`todo`, `in_progress`, `done`, `cancelled`) |
| `/goomnet:workspaces [name]` | Your workspaces with their projects and boards |
| `/goomnet:people [workspace]` | Members of each workspace with their role; filter by workspace name |
| `/goomnet:goomnet <request>` | Anything else, in plain language |

## Install

You need `curl` and `jq` (`brew install jq` on macOS).

In Claude Code, run:

```
/plugin install goomnet --marketplace tanasoft1/goomnet-plugin
```

Pick **Install for you (user scope)**. Claude Code then asks for your goomnet email and password.
The password goes to your system keychain, never to a file in this repo or to `settings.json`.
Start a new session and ask "what are my goomnet tasks?".

## No email/password dialog?

Claude Code only shows the dialog for `/plugin install` run inside a session. A shell
`claude plugin install` never prompts, and the VS Code extension before v2.1.285 doesn't either.
In any of those cases, run this in a Claude Code session, then start a new session:

```
/plugin configure goomnet@tanasoft
```

The same command changes your credentials later.

## Updates

The plugin has no pinned version, so every pushed commit is a new release. Third-party
marketplaces don't auto-update by default. Either turn it on once
(`/plugin` > **Marketplaces** > tanasoft > **Enable auto-update**) or update by hand:

```bash
claude plugin update goomnet@tanasoft
```

## How it works

| Part | What it does |
|---|---|
| `skills/goomnet/SKILL.md` | Tells Claude how goomnet's API vocabulary and quirks work |
| `bin/goomnet` | Bash CLI over the goomnet API; Claude Code puts it on PATH while the plugin is enabled |
| `hooks/hooks.json` + `scripts/sync-config.sh` | At session start, copies your configured credentials to `~/.claude/goomnet/.env` (chmod 600), where the CLI reads them |

The CLI needs the copy because Claude Code exposes plugin options only to hooks, not to the
commands Claude runs. The trade-off: your password also sits in that one local file with owner-only
permissions, as it did with the standalone CLI.

Writes are visible to your whole team, so Claude confirms before writing unless you clearly asked
it to. Deleting tasks and channels is blocked; do that in the web UI.

The server URL defaults to `https://goomnet.tanasoft.mn`; set `GOOMNET_URL` in your environment
to point at another server. Set `GOOMNET_HOME` to keep the config somewhere other than
`~/.claude/goomnet`.
