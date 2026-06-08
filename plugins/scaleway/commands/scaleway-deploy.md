---
name: scaleway-deploy
description: Guided interactive deployment of a Scaleway compute Instance with smart defaults
---

Guide the user through deploying a Scaleway Instance, asking only for what's needed and filling sensible defaults.

## Steps

1. Confirm authentication works and show the active config:
   ```bash
   scw config info
   ```
   If not configured, point the user to the `scaleway-setup` skill (`scw init`).

2. Gather choices, offering defaults and listing options when useful:

   - **Zone** — Show available zones if the user is unsure. Common choices: `fr-par-1`, `fr-par-2`, `nl-ams-1`, `nl-ams-2`, `pl-waw-1`, `pl-waw-2`. Default: `fr-par-1`.

   - **Instance type** — List types so the user can pick:
     ```bash
     scw instance server-type list zone=fr-par-1 -o table=Name,Vcpus,RAM,PerHourCost
     ```
     Good entry-level defaults: `DEV1-S` (2 vCPU, 2 GB RAM) or `PLAY2-MICRO` (1 vCPU, 1 GB RAM).

   - **Image/OS** — List marketplace images:
     ```bash
     scw marketplace image list
     ```
     Default: `ubuntu_jammy` (Ubuntu 22.04 LTS).

   - **SSH key** — List existing keys and offer to add one if none exist:
     ```bash
     scw iam ssh-key list
     ```
     If no keys are configured, offer to create one (see the `scaleway-security` skill):
     ```bash
     scw iam ssh-key create name=my-key public-key="$(cat ~/.ssh/id_ed25519.pub)"
     ```

   - **Name** — A short, descriptive server name (e.g. `web-prod-1`).

   - **Tags** — Optional. Recommended: `env:prod` or `env:dev`, `project:<name>`.

   - **Public IP** — Default is to allocate one (`ip=new`). If the server will be on a Private Network only, use `ip=none`.

3. Show the exact command that will be run and ask for confirmation before executing:

   ```bash
   scw instance server create \
     type=DEV1-S \
     image=ubuntu_jammy \
     name=<chosen-name> \
     zone=fr-par-1 \
     ip=new \
     tags.0=env:dev \
     start=true
   ```

4. Create the Instance and wait for it to be `running`:

   ```bash
   scw instance server create \
     type=<type> \
     image=<image> \
     name=<name> \
     zone=<zone> \
     ip=new \
     tags.0=<tag> \
     start=true
   ```

   Then poll until ready (the CLI waits by default). Retrieve the public IP and print the SSH command:

   ```bash
   scw instance server get <server-id> zone=<zone> -o json | jq -r '.public_ip.address'
   # → ssh root@<public-ip>
   ```

5. Offer logical next steps:
   - **Attach a volume** for extra storage (`scaleway-storage`)
   - **Open firewall ports** for your application (`scaleway-networking` — security groups)
   - **Set a DNS record** pointing to the new IP (`scaleway-dns`)
   - **Place the server on a Private Network** for internal connectivity (`scaleway-networking`)

Keep the conversation friendly — never destroy or overwrite anything as part of "deploy". If anything goes wrong during creation, show the error and suggest running `scw instance server list zone=<zone>` to confirm the current state.
