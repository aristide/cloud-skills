---
name: contabo-deploy
description: Guided interactive deployment of a Contabo VPS/VDS instance with smart defaults
---

Guide the user through deploying a Contabo VPS or VDS instance, asking only for what's needed and filling sensible defaults.

> **Important:** Contabo instances are **subscriptions**. Running `cntb create instance` opens a billing contract immediately. The user will be billed from creation until they run `cntb cancel instance <id>`. Make this clear before executing.

## Steps

1. Confirm authentication works by listing instances:
   ```bash
   cntb get instances -o json
   ```
   If this errors, stop and help the user authenticate (`cntb config set-credentials`).

2. Gather choices, offering defaults and listing options when useful:

   **Region** — ask or show available region codes:
   ```bash
   # Contabo regions (as of writing): EU, US-central, US-east, US-west, SIN, JPN, AUS, IND
   # Confirm current list with: cntb create instance --help
   ```
   Default: `EU`

   **Image / OS** — list available images and default to the current Ubuntu LTS:
   ```bash
   cntb get images -o json
   # Look for Ubuntu LTS in the output; note the imageId UUID
   ```

   **Product / Plan** — Contabo uses product codes (e.g. VPS `V`-prefixed codes, VDS `D`-prefixed). Direct the user to the Contabo website or control panel to choose a product; product IDs are not enumerable via `cntb` alone.
   ```bash
   cntb create instance --help   # shows --productId usage and any listed examples
   ```

   **Billing period** — `1`, `3`, `6`, or `12` months. Default: `1`

   **SSH key** — list existing key secrets; offer to create one if none exist:
   ```bash
   cntb get secrets -o json
   # filter for type == "ssh"
   ```
   If creating a new key:
   ```bash
   cntb create secret --type ssh --name "<key-name>" --value "ssh-ed25519 AAAA..."
   # note the returned secret ID
   ```
   See `contabo-security` for full secret management.

   **Display name** — friendly name for the instance.

3. Show the exact command that will be run and **ask for explicit confirmation** before executing. Remind the user this opens a billing contract:

   ```bash
   cntb create instance \
     --imageId <image-uuid> \
     --productId <product-id> \
     --region <region> \
     --period <months> \
     --displayName "<name>" \
     --sshKeys <secret-id>
   ```

4. After the user confirms, create the instance:
   ```bash
   cntb create instance \
     --imageId <image-uuid> \
     --productId <product-id> \
     --region <region> \
     --period <months> \
     --displayName "<name>" \
     --sshKeys <secret-id>
   ```
   Note the returned instance ID, then poll until it is ready:
   ```bash
   cntb get instance <instance-id> -o json
   # wait until status is "running"
   ```

5. Report the public IP and ready-to-use SSH command:
   ```bash
   ip=$(cntb get instance <instance-id> -o json | jq -r '.[0].ipConfig.v4.ip')
   echo "Instance ready. Connect with: ssh root@$ip"
   ```
   (Inspect `cntb get instance <id> -o json` to confirm the exact IP field path for your API version.)

6. Offer logical follow-ups:
   - Attach to a private network (`contabo-networking`)
   - Upload object storage for the instance (`contabo-storage`)
   - Add more SSH keys or tag the instance (`contabo-security`)
   - Open firewall ports (on-instance: `ufw allow 80/tcp`)

Keep it conversational — never destroy or overwrite anything as part of "deploy".
