# Adding a Cloud Provider

This repository is a **Claude Code marketplace** (`.claude-plugin/marketplace.json`) that hosts one independently-installable **plugin per cloud provider** under `plugins/`. Each plugin wraps a provider's official CLI and gives Claude:

- a **setup/auth skill** — install + authenticate the CLI, select project/region,
- a **core-compute skill** — create/list/start/stop/delete instances,
- a **status slash command** — summarize resources,
- a **safety hook** — warn before destructive operations on that provider's binary.

Adding a provider is: copy the template, fill it in, register one entry in the marketplace.

## 1. Copy the template

```bash
cp -r templates/provider-template plugins/<provider>
```

Use a short, lowercase, kebab-case `<provider>` id (e.g. `aws`, `azure`, `gcp`, `scaleway`, `digitalocean`, `oci`). It is both the plugin name and the prefix for every skill/command/hook.

## 2. Rename the placeholder paths

The template uses `__PROVIDER__` in directory and file names. Rename them to your provider id:

```
plugins/<provider>/skills/__PROVIDER__-setup     -> skills/<provider>-setup
plugins/<provider>/skills/__PROVIDER__-compute   -> skills/<provider>-compute
plugins/<provider>/commands/__PROVIDER__-status.md       -> commands/<provider>-status.md
plugins/<provider>/hooks/scripts/__PROVIDER__-safety.sh  -> hooks/scripts/<provider>-safety.sh
```

## 3. Replace the placeholder tokens

Substitute these tokens everywhere inside the copied files:

| Token | Replace with | Example |
|-------|--------------|---------|
| `__PROVIDER__` | plugin id / name prefix | `digitalocean` |
| `__PROVIDER_DISPLAY__` | human-readable name | `DigitalOcean` |
| `__CLI__` | the CLI binary name | `doctl` |

Files to edit:
- `.claude-plugin/plugin.json` — name, description, keywords
- `skills/<provider>-setup/SKILL.md` — real install + auth + scoping + output
- `skills/<provider>-compute/SKILL.md` — real compute verbs and flags
- `commands/<provider>-status.md` — real list commands
- `hooks/hooks.json` — points at `scripts/<provider>-safety.sh`
- `hooks/scripts/<provider>-safety.sh` — the binary name and the provider's destructive verbs

## 4. Fill in real CLI content

- **Skill frontmatter `description`** must start with "Use when the user needs to…" — this is what Claude matches on to auto-load the skill. Keep names kebab-case and **provider-prefixed** so they never collide with other installed providers.
- **Core compute** should at minimum cover: create, list/describe, start, stop, reboot, delete, get-IP/ssh, and how to look up images and instance types.
- **Safety hook** must early-exit unless the command targets your CLI binary (so installing several providers never cross-fires warnings), and stay **advisory** (always `exit 0`). List the provider's real destructive verbs (`delete`, `terminate`, `stop`, `rm`, …).

## 5. Register the plugin in the marketplace

Add one entry to the `plugins` array in `.claude-plugin/marketplace.json` (the `source` is the directory name under `plugins/`, because `metadata.pluginRoot` is `./plugins`):

```json
{
  "name": "<provider>",
  "source": "<provider>",
  "description": "<Provider> CLI skills and safety hooks — auth and core compute",
  "version": "0.1.0",
  "keywords": ["<provider>", "<cli>", "cloud", "infrastructure", "devops"]
}
```

## 6. Validate

```bash
jq . .claude-plugin/marketplace.json
jq . plugins/<provider>/.claude-plugin/plugin.json
bash -n plugins/<provider>/hooks/scripts/<provider>-safety.sh
```

Confirm each `SKILL.md` and the status command have YAML frontmatter with `name` + `description`, and that any `${CLAUDE_PLUGIN_ROOT}` path you reference exists.

## 7. Try it

```text
/plugin marketplace add <owner>/cloud-skills      # or a local path while developing
/plugin install <provider>@cloud-skills
```

Then confirm the `<provider>-setup` / `<provider>-compute` skills auto-activate on a relevant request and that `/<provider>-status` is available.

## Going deeper

The template ships the **skeleton + core compute** only. To add networking, storage, DNS, IAM, etc., create more skills in the same plugin (`skills/<provider>-networking/SKILL.md`, …) following the same naming and frontmatter conventions — exactly how the bundled `hcloud` plugin is organized (`plugins/hcloud/skills/`).
