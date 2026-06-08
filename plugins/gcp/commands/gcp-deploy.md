---
name: gcp-deploy
description: Guided interactive deployment of a Google Cloud compute instance with smart defaults
---

Guide the user through deploying a Google Cloud Compute Engine instance, asking only for what's needed and filling sensible defaults.

## Steps

1. Confirm authentication works (see the `gcp-setup` skill); if not, stop and help them authenticate:
   ```bash
   gcloud auth list
   gcloud config list --format='table(core.account,core.project,compute.zone)'
   ```

2. Gather choices, offering defaults and listing options when useful:
   - **Project** — confirm the active project or let the user pick one:
     ```bash
     gcloud projects list --format='table(projectId,name,projectNumber)'
     ```
   - **Region/zone** — default to `us-central1-a`; list if the user is unsure:
     ```bash
     gcloud compute zones list --filter='status=UP' \
       --format='table(name,region.basename(),status)'
     ```
   - **Machine type** — default to `e2-micro` (free-tier eligible); list common options:
     ```bash
     gcloud compute machine-types list --zones us-central1-a \
       --filter='name~^e2 OR name~^n2' \
       --format='table(name,guestCpus,memoryMb)'
     ```
   - **Image/OS** — default to latest Debian LTS; list to confirm:
     ```bash
     gcloud compute images list \
       --filter='family~debian AND NOT deprecated.state:*' \
       --format='table(name,family,creationTimestamp)' \
       --sort-by=~creationTimestamp --limit 5
     ```
   - **Boot disk size** — default to `20GB`; suggest `--boot-disk-type pd-balanced`
   - **SSH access** — ask whether to use OS Login or a metadata key:
     - OS Login (recommended): `gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa.pub`
     - Metadata key: add via `--metadata ssh-keys=...` flag at create time (see `gcp-security`)
   - **Name** — ask for a name; default suggestion: `my-instance`
   - **External IP** — default yes; offer `--no-address` if the user wants a private-only instance

3. Show the exact command you will run and ask for confirmation before executing:
   ```bash
   gcloud compute instances create my-instance \
     --zone us-central1-a \
     --machine-type e2-micro \
     --image-family debian-12 \
     --image-project debian-cloud \
     --boot-disk-size 20GB \
     --boot-disk-type pd-balanced \
     --tags http-server
   ```

4. Create the instance, then wait for it to become RUNNING and report the result:
   ```bash
   gcloud compute instances describe my-instance \
     --zone us-central1-a \
     --format='table(name,status,networkInterfaces[0].accessConfigs[0].natIP)'
   ```

   Provide the ready-to-use SSH command:
   ```bash
   gcloud compute ssh my-instance --zone us-central1-a
   # or without external IP via IAP:
   gcloud compute ssh my-instance --zone us-central1-a --tunnel-through-iap
   ```

5. Offer logical follow-ups:
   - Open firewall ports (`gcp-networking`): `gcloud compute firewall-rules create allow-http --allow tcp:80 --target-tags http-server`
   - Attach an extra disk (`gcp-storage`): `gcloud compute disks create` + `gcloud compute instances attach-disk`
   - Reserve a static IP (`gcp-networking`): `gcloud compute addresses create`
   - Set a DNS record (`gcp-dns`): `gcloud dns record-sets create`

Keep it conversational — never destroy or overwrite anything as part of "deploy".
