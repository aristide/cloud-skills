---
name: ovh-deploy
description: Guided interactive deployment of an OVHcloud Public Cloud instance with smart defaults
---

Guide the user through deploying an OVHcloud Public Cloud instance via the OpenStack client, asking only for what's needed and filling sensible defaults.

## Steps

1. Confirm authentication works (see the `ovh-setup` skill). Check with:
   ```bash
   openstack token issue -f value -c project_id
   echo "region: $OS_REGION_NAME"
   ```
   If unauthenticated, stop and help them source the OpenStack RC file before continuing.

2. Gather the following choices, offering defaults and showing available options:

   - **Region** — already in `$OS_REGION_NAME`; confirm or list options from the OVH control panel. Each region is an independent OpenStack endpoint.
   - **Flavor (instance size)** — list available flavors and default to a small general-purpose option (e.g. `b3-8`):
     ```bash
     openstack flavor list --sort-column Name
     ```
   - **Image (OS)** — default to current Ubuntu LTS:
     ```bash
     openstack image list --status active --sort-column Name
     ```
   - **SSH keypair** — list existing keypairs; offer to import one if none exist:
     ```bash
     openstack keypair list
     # Import if needed:
     openstack keypair create --public-key ~/.ssh/id_ed25519.pub my-key
     ```
   - **Network** — default to `Ext-Net` for a public IP; offer private network if one exists:
     ```bash
     openstack network list
     ```
   - **Security group** — default to `default`; suggest creating a dedicated one for SSH/HTTP if appropriate (see `ovh-networking`):
     ```bash
     openstack security group list
     ```
   - **Instance name** — prompt for a meaningful name; default to `my-server`.

3. Show the exact command that will be run and ask for confirmation before executing:
   ```bash
   openstack server create <name> \
     --flavor <flavor> \
     --image "<image>" \
     --key-name <keypair> \
     --network <network> \
     --security-group <sg> \
     --wait
   ```

4. Create the instance and wait for `ACTIVE` status (`--wait` blocks until ready). Then report:
   ```bash
   openstack server show <name> -c status -c addresses -c id
   ```
   Present the public IP and the ready-to-use SSH command, e.g.:
   ```bash
   ssh ubuntu@<public-ip>   # default user: ubuntu (Ubuntu), debian (Debian), centos (CentOS)
   ```

5. Offer logical follow-ups:
   - **Attach a volume** for persistent data (`ovh-storage`)
   - **Adjust firewall rules** to open additional ports (`ovh-networking`)
   - **Assign a floating IP** if using a private network (`ovh-networking`)
   - **Set a DNS record** pointing to the instance IP (`ovh-dns`)

Keep it conversational. Never destroy or overwrite existing resources as part of "deploy". Remind the user that a `SHUTOFF` (stopped) instance still bills on OVH Public Cloud — only deleting it stops charges.
