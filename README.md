# goomnet plugin for Claude Code

Lets Claude read and update your tasks on [goomnet](https://goomnet.tanasoft.mn): what's assigned
to you, boards, comments, creating and closing tasks. Ask in plain language ("what's on my plate
in goomnet?", "mark 3683 done") or run `/goomnet:goomnet`.

## Install

You need read access to this repository, `curl`, and `jq` (`brew install jq` on macOS).

In Claude Code, run:

```
/plugin install goomnet --marketplace tanasoft1/goomnet-plugin
```

Pick **Install for you (user scope)**. Claude Code then asks for your goomnet email and password.
The password goes to your system keychain, never to a file in this repo or to `settings.json`.
Start a new session (or `/reload-plugins`) and ask "what are my goomnet tasks?".

From a shell instead of a session:

```bash
claude plugin install goomnet --marketplace tanasoft1/goomnet-plugin
```

The shell install has no dialog, so open `/plugin` in Claude Code afterwards and use
**Configure options** (below).

The repository is private. Claude Code clones it with your existing git credentials and never
prompts, so `gh auth login` (or a working SSH key for github.com) must already be set up.

## Change your credentials

`/plugin` > **Installed** > goomnet > **Configure options**, then start a new session.

## Updates

Third-party marketplaces don't auto-update by default. Either turn it on once
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

You can also use the CLI directly: `~/.claude/plugins/cache/.../bin/goomnet help`, or set
`GOOMNET_HOME` to keep the config somewhere other than `~/.claude/goomnet`.
