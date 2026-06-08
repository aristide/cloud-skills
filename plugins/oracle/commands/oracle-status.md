---
name: oracle-status
description: Show an overview of Oracle Cloud Infrastructure (OCI) resources in a compartment
---

Show a concise overview of an OCI compartment's infrastructure.

## Steps

1. Determine the target compartment. If the user hasn't given a compartment OCID, ask for one (or use `$OCI_COMPARTMENT` / the tenancy root). Confirm auth works:
   ```bash
   oci iam region list --output table
   ```

2. With `CID=<compartment-ocid>`, list core resources (skip any that error or return empty):
   - Compute instances:
     ```bash
     oci compute instance list --compartment-id "$CID" \
       --query 'data[].{name:"display-name",state:"lifecycle-state",shape:shape,ad:"availability-domain"}' --output table
     ```
   - Block volumes: `oci bv volume list --compartment-id "$CID" --query 'data[].{name:"display-name",state:"lifecycle-state",gb:"size-in-gbs"}' --output table`
   - Boot volumes: `oci bv boot-volume list --compartment-id "$CID" --availability-domain <AD>`
   - VCNs: `oci network vcn list --compartment-id "$CID" --output table`
   - Public IPs: `oci network public-ip list --compartment-id "$CID" --scope REGION --output table`

3. Present a concise summary highlighting:
   - Instance counts by lifecycle state (skip states with zero)
   - `STOPPED` instances whose boot/block volumes still bill
   - Unattached block volumes (`AVAILABLE` and not attached)
   - Reserved public IPs not in use (these bill while idle)
   - Anything in a `PROVISIONING`/`TERMINATING`/error state

Run the list commands and summarize. If unauthenticated, point the user to the `oracle-setup` skill (`oci setup config` or `oci session authenticate`). Remember most commands are per-compartment and per-region — repeat for other compartments/regions as needed.
