---
name: __PROVIDER__-deploy
description: Guided interactive deployment of a __PROVIDER_DISPLAY__ compute instance with smart defaults
---

Guide the user through deploying a __PROVIDER_DISPLAY__ compute instance, asking only for what's needed and filling sensible defaults.

## Steps

1. Confirm authentication works (see the `__PROVIDER__-setup` skill); if not, stop and help them authenticate.

2. Gather choices, offering defaults and listing options when useful:
   - **Region/zone** — show `# __CLI__ <regions list>` if the user is unsure
   - **Size/plan/type** — show `# __CLI__ <sizes/types list>`; default to a small/cheap option
   - **Image/OS** — show `# __CLI__ <images list>`; default to current Ubuntu LTS
   - **SSH key** — list existing keys; offer to create/import one (see `__PROVIDER__-security`)
   - **Name/label** and any tags

3. Show the exact `__CLI__ <compute> create ...` command you will run and ask for confirmation before executing.

4. Create the instance, wait for it to become ready, then report the public IP and the ready-to-use SSH command.

5. Offer logical follow-ups: attach a volume (`__PROVIDER__-storage`), open firewall ports (`__PROVIDER__-networking`), or set a DNS record (`__PROVIDER__-dns`).

Keep it conversational — never destroy or overwrite anything as part of "deploy".
