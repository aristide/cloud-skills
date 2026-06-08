---
name: vultr-deploy
description: Guided interactive deployment of a Vultr compute instance with smart defaults
---

Guide the user through deploying a Vultr compute instance, asking only for what's needed and filling in sensible defaults.

## Steps

1. Confirm authentication works:
   ```bash
   vultr-cli account info
   ```
   If this fails, stop and help the user set `VULTR_API_KEY` (or `~/.vultr-cli.yaml`) and verify their IP is on the API access control list. See the `vultr-setup` skill.

2. Gather the required choices, offering defaults and running list commands if the user is unsure:

   - **Region** — default `ewr` (New Jersey); show options with:
     ```bash
     vultr-cli regions list
     ```
   - **Plan** — default `vc2-1c-1gb` ($6/mo); show options with:
     ```bash
     vultr-cli plans list
     ```
   - **OS** — default Ubuntu 22.04 LTS (OS id `1743`); show options with:
     ```bash
     vultr-cli os list
     ```
     Alternatively, use `--snapshot <id>`, `--app <id>`, or `--image <id>` instead of `--os`.
   - **SSH key** — list existing keys; if none, offer to import one:
     ```bash
     vultr-cli ssh-key list
     vultr-cli ssh-key create --name "my-key" --key "$(cat ~/.ssh/id_ed25519.pub)"
     ```
   - **Hostname / label** — ask for a name; use the label as both `--host` and `--label` if the user doesn't distinguish.
   - **Tags** — optional; skip if the user doesn't need them.
   - **Firewall group** — optional; if the user wants to open specific ports, create a group first (see `vultr-networking`).

3. Show the exact command you will run and ask for confirmation before executing:
   ```bash
   vultr-cli instance create \
     --region    <region-id> \
     --plan      <plan-id> \
     --os        <os-id> \
     --host      <hostname> \
     --label     <label> \
     --ssh-keys  <key-id>,... \
     --tags      <tag>,...
   ```

4. Run the command, then poll until the instance is `active`:
   ```bash
   vultr-cli instance get <instance-id>
   # Repeat until status == "active" and power_status == "running"
   ```
   Report the public IP and the ready-to-use SSH command:
   ```bash
   ssh root@<main-ip>
   ```

5. Offer logical follow-ups:
   - Attach a block storage volume (`vultr-storage` skill)
   - Open firewall ports or attach a firewall group (`vultr-networking` skill)
   - Point a DNS record at the new IP (`vultr-dns` skill)
   - Take a baseline snapshot before making changes (`vultr-storage` skill)

Keep it conversational. Never destroy or overwrite anything as part of this "deploy" flow. Note that a **stopped** instance still bills — only deleting it stops charges.
