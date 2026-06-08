---
name: oracle-deploy
description: Guided interactive deployment of an Oracle Cloud Infrastructure (OCI) compute instance with smart defaults
---

Guide the user through deploying an OCI compute instance, collecting only what's needed and offering sensible defaults.

## Steps

1. Confirm authentication works (see the `oracle-setup` skill). A quick sanity check:
   ```bash
   oci iam region list --output table
   ```
   If this errors, stop and help the user authenticate before continuing.

2. Confirm the target **compartment**. Ask for a compartment OCID or check `$OCI_COMPARTMENT`. If the user is unsure, list compartments:
   ```bash
   oci iam compartment list \
     --compartment-id <tenancy-ocid> \
     --output table \
     --query 'data[].{name:"name",ocid:"id"}'
   ```

3. Confirm the target **region** and **availability domain** (AD):
   ```bash
   oci iam availability-domain list \
     --compartment-id <compartment-ocid> \
     --output table
   ```
   Default to the first AD in the list unless the user specifies otherwise.

4. Choose a **shape**. Suggest `VM.Standard.E4.Flex` (AMD, flexible) or `VM.Standard.A1.Flex` (Arm, free-tier eligible) as defaults, then offer to list all shapes:
   ```bash
   oci compute shape list \
     --compartment-id <compartment-ocid> \
     --output table
   ```
   For `.Flex` shapes, confirm **OCPUs** (default: `1`) and **memory GB** (default: `6`).

5. Choose an **OS image**. Default to current Oracle Linux 8 or Ubuntu 22.04 LTS and offer to list options:
   ```bash
   # Oracle Linux 8 (latest)
   oci compute image list \
     --compartment-id <compartment-ocid> \
     --operating-system "Oracle Linux" \
     --operating-system-version "8" \
     --sort-by TIMECREATED --sort-order DESC \
     --query 'data[0].id' --raw-output

   # Ubuntu 22.04 LTS (latest)
   oci compute image list \
     --compartment-id <compartment-ocid> \
     --operating-system "Canonical Ubuntu" \
     --operating-system-version "22.04" \
     --sort-by TIMECREATED --sort-order DESC \
     --query 'data[0].id' --raw-output
   ```

6. Choose a **subnet**. Ask for a subnet OCID or list available ones:
   ```bash
   oci network subnet list \
     --compartment-id <compartment-ocid> \
     --output table \
     --query 'data[].{name:"display-name",ocid:"id",vcn:"vcn-id",cidr:"cidr-block"}'
   ```

7. Collect the **SSH public key** to inject. Default to `~/.ssh/id_ed25519.pub` if it exists; otherwise ask the user to provide a path or paste the key.

8. Ask for a **display name** for the instance (default: `my-instance`).

9. Ask about optional items:
   - **Assign public IP?** (default: `true` for instances in a public subnet)
   - **Freeform tags?** e.g. `{"env":"dev","team":"platform"}`

10. Show the exact command that will run and **ask for confirmation** before executing:

    ```bash
    oci compute instance launch \
      --availability-domain <AD-name> \
      --compartment-id <compartment-ocid> \
      --shape <shape> \
      --shape-config '{"ocpus":<n>,"memoryInGBs":<m>}' \
      --image-id <image-ocid> \
      --subnet-id <subnet-ocid> \
      --display-name <name> \
      --assign-public-ip true \
      --metadata '{"ssh_authorized_keys":"'"$(cat ~/.ssh/id_ed25519.pub)"'"}' \
      --freeform-tags '{"env":"dev"}' \
      --wait-for-state RUNNING
    ```

    Do **not** execute until the user says yes.

11. After the instance reaches `RUNNING`, report the public IP and the ready-to-use SSH command:

    ```bash
    # Get the public IP
    oci compute instance list-vnics \
      --instance-id <instance-ocid> \
      --query 'data[0]."public-ip"' --raw-output
    ```

    Default SSH user: `opc` for Oracle Linux, `ubuntu` for Ubuntu images.

    ```bash
    ssh opc@<public-ip>
    ```

12. Offer logical follow-ups:
    - Attach a data volume (`oracle-storage`)
    - Open additional ports in the security list or NSG (`oracle-networking`)
    - Set a DNS A record pointing to the public IP (`oracle-dns`)
    - Reserve the public IP so it survives termination (`oracle-networking`)

Never destroy or overwrite existing resources as part of a deploy step.
