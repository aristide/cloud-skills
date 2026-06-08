---
name: digitalocean-deploy
description: Guided interactive deployment of a DigitalOcean Droplet with smart defaults
---

Guide the user through deploying a DigitalOcean Droplet, asking only for what's needed and filling in sensible defaults.

## Steps

1. Confirm authentication works:
   ```bash
   doctl account get
   ```
   If this fails, stop and point the user to the `digitalocean-setup` skill (`doctl auth init`).

2. Gather choices, offering defaults and listing options when the user is unsure:

   - **Region** — default `nyc3`; show options if asked:
     ```bash
     doctl compute region list
     ```

   - **Size/plan** — default `s-1vcpu-1gb` (cheapest general-purpose); show options:
     ```bash
     doctl compute size list
     ```

   - **Image/OS** — default `ubuntu-24-04-x64`; show available distros:
     ```bash
     doctl compute image list-distribution --public
     ```

   - **SSH key** — list keys already in the account; offer to import one if none exist (see the `digitalocean-security` skill):
     ```bash
     doctl compute ssh-key list --format ID,Name,FingerPrint --no-header
     ```

   - **Name** — ask the user; suggest a kebab-case slug like `app-01`

   - **VPC** (optional) — default is the region's default VPC; list with `doctl vpcs list` if the user wants a specific one

   - **Tags** (optional) — comma-separated, e.g. `env:prod,team:backend`

   - **Cloud-init / user data** (optional) — ask only if the user mentions it

3. Show the exact command you will run and ask for confirmation before executing:
   ```bash
   doctl compute droplet create <name> \
     --size <size-slug> \
     --image <image-slug> \
     --region <region-slug> \
     --ssh-keys <key-id-or-fingerprint> \
     --tag-names <tags> \
     --wait
   ```

4. Run the command. When it completes, report:
   - The Droplet ID and public IPv4 address:
     ```bash
     doctl compute droplet get <id> --format ID,Name,PublicIPv4,Status --no-header
     ```
   - The ready-to-use SSH command:
     ```bash
     doctl compute ssh <name>
     # or: ssh root@<public-ip>
     ```

5. Offer logical follow-ups:
   - Attach a block volume (`digitalocean-storage`)
   - Open or restrict firewall ports (`digitalocean-networking`)
   - Set a DNS A record pointing to the new IP (`digitalocean-dns`)
   - Place it behind a load balancer (`digitalocean-networking`)

Keep it conversational — never destroy or overwrite anything as part of "deploy". Note: a powered-off Droplet **still incurs the full hourly charge** — see the `digitalocean-cleanup` command to remove idle resources.
