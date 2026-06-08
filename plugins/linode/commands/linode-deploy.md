---
name: linode-deploy
description: Guided interactive deployment of a Linode compute instance with smart defaults
---

Guide the user through deploying a Linode compute instance, asking only for what's needed and filling sensible defaults.

## Steps

1. Confirm authentication works (see the `linode-setup` skill); if not, stop and help them authenticate:
   ```bash
   linode-cli account view
   ```

2. Gather choices, offering defaults and listing options when useful:
   - **Region** — show options if the user is unsure:
     ```bash
     linode-cli regions list --text --format "id,label,country" --no-headers
     ```
     Default: `us-east` (Newark).
   - **Plan/type** — show a filtered list of common plans:
     ```bash
     linode-cli linodes types --text --format "id,label,vcpus,memory,disk,price.monthly" --no-headers
     ```
     Default: `g6-nanode-1` (1 vCPU, 1 GB RAM, ~$5/month) for light workloads; suggest `g6-standard-2` for anything production-facing.
   - **Image/OS** — show available images:
     ```bash
     linode-cli images list --text --format "id,label,type" --no-headers | grep "^linode/"
     ```
     Default: `linode/ubuntu24.04` (Ubuntu 24.04 LTS).
   - **SSH key** — list existing account keys and offer to add one (see `linode-security`):
     ```bash
     linode-cli sshkeys list --text --format "id,label" --no-headers
     ```
     Strongly encourage an SSH key over a root password.
   - **Label** — ask for a name; suggest a descriptive slug (e.g. `web-prod-1`).
   - **Tags** — optional; useful for cost tracking and `linode-cleanup` later.
   - **Backups** — ask if they want managed backups enabled (+20% cost).
   - **Private IP** — ask if the instance needs to communicate privately with other Linodes in the same region.

3. Show the exact command you will run and ask for confirmation before executing:
   ```bash
   linode-cli linodes create \
     --label <label> \
     --type <type> \
     --region <region> \
     --image <image> \
     --root_pass '<root-password>' \
     --authorized_keys "$(cat ~/.ssh/id_ed25519.pub)" \
     --backups_enabled <true|false> \
     --private_ip <true|false> \
     --tags <tag>
   ```

4. Create the instance, then poll until it is `running`:
   ```bash
   linode-cli linodes view <linode-id> --text --format "status" --no-headers
   ```
   Report the public IPv4 and the ready-to-use SSH command:
   ```bash
   ssh root@<public-ip>
   # or, using the linode-cli SSH plugin:
   linode-cli ssh root@<label>
   ```

5. Offer logical follow-ups:
   - Attach a Block Storage volume — see the `linode-storage` skill.
   - Open firewall ports (Cloud Firewall) — see the `linode-networking` skill.
   - Set a DNS A record pointing at the new IP — see the `linode-dns` skill.
   - Add this Linode to a NodeBalancer backend — see the `linode-networking` skill.

Keep it conversational — never destroy or overwrite anything as part of "deploy".
