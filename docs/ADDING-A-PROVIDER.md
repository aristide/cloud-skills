# Adding a Cloud Provider

This repository is a **Claude Code marketplace** (`.claude-plugin/marketplace.json`) that hosts one independently-installable **plugin per cloud provider** under `plugins/`. Each plugin wraps a provider's official CLI and gives Claude a consistent set of skills and commands:

**Skills** (auto-activating reference, one resource domain each):
- `setup` — install + authenticate the CLI, select project/region, output format
- `compute` — create/list/start/stop/delete instances, SSH, images, sizes
- `networking` — networks/VPCs, firewalls/security groups, IPs, load balancers
- `storage` — block volumes/disks, snapshots, object storage
- `security` — SSH keys, TLS certificates, identity/roles, tags
- `dns` — managed DNS zones and records
- `kubernetes` — managed Kubernetes clusters and node pools
- `containers` — serverless containers / container apps + registry
- `serverless` — functions (FaaS)

**Commands** (slash commands):
- `status` — summarize all resources
- `deploy` — guided interactive instance deployment
- `cleanup` — find orphaned/idle resources that still bill

**Hook:**
- `safety` — advisory warning before destructive operations on that provider's binary

Not every provider offers every domain (e.g. a bare-VPS provider may have no managed Kubernetes, serverless, or DNS). **Include a skill only for the domains the provider actually offers, and delete the rest** — don't ship a stub skill whose body just says "not offered", and never invent commands that don't exist. A service the provider offers through a *different* tool than the plugin's main CLI still counts as offered and keeps its skill (document the real path). `setup`, `compute`, and the `status`/`deploy`/`cleanup` commands are always present.

Adding a provider is: copy the template, fill it in, register one entry in the marketplace.

## 1. Copy the template

```bash
cp -r templates/provider-template plugins/<provider>
```

Use a short, lowercase, kebab-case `<provider>` id (e.g. `aws`, `azure`, `gcp`, `scaleway`, `digitalocean`, `oci`). It is both the plugin name and the prefix for every skill/command/hook.

## 2. Rename the placeholder paths

The template uses `__PROVIDER__` in directory and file names. Rename every one to your provider id. On macOS/Linux this one-liner does it:

```bash
cd plugins/<provider>
find . -depth -name '*__PROVIDER__*' -execdir bash -c 'mv "$1" "${1//__PROVIDER__/<provider>}"' _ {} \;
```

The renamed layout (skills are directories, each with a `SKILL.md`):

```
skills/<provider>-setup       skills/<provider>-networking   skills/<provider>-kubernetes
skills/<provider>-compute     skills/<provider>-storage      skills/<provider>-containers
                              skills/<provider>-security     skills/<provider>-serverless
                              skills/<provider>-dns
commands/<provider>-status.md   commands/<provider>-deploy.md   commands/<provider>-cleanup.md
hooks/scripts/<provider>-safety.sh
```

## 3. Replace the placeholder tokens

Substitute these tokens everywhere inside the copied files:

| Token | Replace with | Example |
|-------|--------------|---------|
| `__PROVIDER__` | plugin id / name prefix | `digitalocean` |
| `__PROVIDER_DISPLAY__` | human-readable name | `DigitalOcean` |
| `__CLI__` | the CLI binary name | `doctl` |

Then fill every file with real CLI content: `.claude-plugin/plugin.json` (name/description/keywords), each `skills/<provider>-*/SKILL.md`, each `commands/<provider>-*.md`, `hooks/hooks.json` (points at `scripts/<provider>-safety.sh`), and `hooks/scripts/<provider>-safety.sh` (the binary name + that provider's destructive verbs).

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
/plugin marketplace add aristide/cloud-skills      # or a local path while developing
/plugin install <provider>@cloud-skills
```

Then confirm the `<provider>-setup` / `<provider>-compute` skills auto-activate on a relevant request and that `/<provider>-status` is available.

## Going deeper

The template now ships the **full element set** (setup, compute, networking, storage, security, dns, kubernetes, containers, serverless skills + status/deploy/cleanup commands). Fill in only the domains the provider actually offers. To go further still, add more domain skills in the same plugin (`skills/<provider>-databases/SKILL.md`, …) following the same naming and frontmatter conventions — exactly how the bundled `hcloud` plugin is organized (`plugins/hcloud/skills/`).
