---
name: contabo-status
description: Show an overview of Contabo resources for the configured account
---

Show a concise overview of the configured Contabo account's infrastructure.

## Steps

1. Confirm credentials work by listing instances (an auth error here means setup is incomplete):
   ```bash
   cntb get instances -o json
   ```

2. List core resources (skip any that error or return empty):
   - Instances: `cntb get instances`
   - Snapshots (per instance, if any instances exist): `cntb get snapshots <instance-id>`
   - Images (custom uploads): `cntb get images`
   - Secrets (SSH keys / passwords): `cntb get secrets`
   - Object storages: `cntb get objectStorages`
   - Private networks: `cntb get privateNetworks`

3. Present a concise summary highlighting:
   - Instance counts by status (skip statuses with zero)
   - Instances that are stopped/provisioning but still under contract (still billing)
   - Instances pending cancellation
   - Custom images and secrets that are unused
   - Anything in an error/installing state

Run the list commands and summarize. If credentials are missing or invalid, point the user to the `contabo-setup` skill (`cntb config set-credentials`). Remember Contabo billing is subscription-based — stopping an instance does **not** stop billing; only `cntb cancel instance <id>` does.
