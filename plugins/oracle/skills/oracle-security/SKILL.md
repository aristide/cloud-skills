---
name: oracle-security
description: "Use when the user needs to manage Oracle Cloud Infrastructure (OCI) security — SSH key injection, TLS/SSL certificates, IAM users, groups, policies, compartments, and resource tags."
---

# Oracle Cloud Infrastructure Security

Commands span `oci iam ...` for identity and access, and `oci certs-mgmt ...` for the Certificates service. SSH keys on OCI are injected via instance metadata at launch, not managed as standalone resources. See the `oracle-setup` skill for auth and OCIDs.

## SSH Keys

OCI does not have a standalone SSH key resource. Public keys are injected into instances at launch via the `--metadata` flag. The key lands in `/home/<user>/.ssh/authorized_keys` via cloud-init.

```bash
# Inject your public key at instance launch
oci compute instance launch \
  --compartment-id <compartment-ocid> \
  --availability-domain <AD-name> \
  --shape VM.Standard.E4.Flex \
  --shape-config '{"ocpus":1,"memoryInGBs":6}' \
  --image-id <image-ocid> \
  --subnet-id <subnet-ocid> \
  --display-name my-instance \
  --metadata '{"ssh_authorized_keys":"'"$(cat ~/.ssh/id_ed25519.pub)"'"}'

# Inject multiple keys (newline-separated inside the JSON value)
oci compute instance launch \
  --compartment-id <compartment-ocid> \
  ... \
  --metadata "{\"ssh_authorized_keys\":\"$(cat ~/.ssh/id_ed25519.pub)\n$(cat ~/.ssh/id_rsa.pub)\"}"
```

To add a key to a running instance, connect via SSH and append to `~/.ssh/authorized_keys` manually.

## TLS / SSL Certificates (Certificates Service)

The Certificates service manages CA-issued and imported TLS certificates, which are referenced by load balancers and other services.

```bash
# Import an existing certificate (PEM files)
oci certs-mgmt certificate create-by-importing-config \
  --compartment-id <compartment-ocid> \
  --name my-cert \
  --certificate-pem "$(cat cert.pem)" \
  --private-key-pem "$(cat key.pem)" \
  --chain-pem "$(cat chain.pem)"

# Create an internally-issued certificate
oci certs-mgmt certificate create-by-issuing-internally \
  --compartment-id <compartment-ocid> \
  --name my-internal-cert \
  --issuer-certificate-authority-id <ca-ocid> \
  --validity '{"timeOfValidityNotAfter":"2027-01-01T00:00:00Z"}' \
  --subject '{"commonName":"myservice.example.com"}'

oci certs-mgmt certificate list --compartment-id <compartment-ocid> --output table
oci certs-mgmt certificate get --certificate-id <cert-ocid>
oci certs-mgmt certificate schedule-certificate-deletion --certificate-id <cert-ocid>
```

## IAM: Users and Groups

```bash
# Users
oci iam user create \
  --compartment-id <tenancy-ocid> \
  --name jdoe \
  --description "Jane Doe"

oci iam user list --compartment-id <tenancy-ocid> --output table
oci iam user get --user-id <user-ocid>
oci iam user delete --user-id <user-ocid>

# Groups
oci iam group create \
  --compartment-id <tenancy-ocid> \
  --name developers \
  --description "Dev team"

oci iam group list --compartment-id <tenancy-ocid> --output table

# Add user to group
oci iam group add-user \
  --group-id <group-ocid> \
  --user-id <user-ocid>

oci iam group list-users --group-id <group-ocid> --output table
oci iam group remove-user --group-id <group-ocid> --user-id <user-ocid>
```

## IAM: Policies

Policies grant groups access to resources. Statements follow the format: `Allow group <name> to <verb> <resource-type> in compartment <name>`.

```bash
oci iam policy create \
  --compartment-id <compartment-ocid> \
  --name dev-policy \
  --description "Dev team access" \
  --statements '["Allow group developers to manage instance-family in compartment dev","Allow group developers to use virtual-network-family in compartment dev"]'

oci iam policy list --compartment-id <compartment-ocid> --output table
oci iam policy get --policy-id <policy-ocid>

# Update statements (replaces all existing statements)
oci iam policy update \
  --policy-id <policy-ocid> \
  --statements '["Allow group developers to manage all-resources in compartment dev"]'

oci iam policy delete --policy-id <policy-ocid>
```

## Compartments

Compartments are the primary isolation boundary in OCI for billing, access control, and resource organization.

```bash
oci iam compartment create \
  --compartment-id <parent-compartment-ocid> \
  --name production \
  --description "Production workloads"

oci iam compartment list --compartment-id <tenancy-ocid> --output table
oci iam compartment get --compartment-id <compartment-ocid>
```

## Tags

OCI supports freeform tags (key-value strings) and defined tags (governed by tag namespaces).

```bash
# Freeform tags at resource creation (works on most oci ... create commands)
oci compute instance launch \
  --compartment-id <compartment-ocid> \
  ... \
  --freeform-tags '{"env":"prod","team":"platform"}'

# Defined tags
oci compute instance launch \
  ... \
  --defined-tags '{"Operations":{"CostCenter":"42"}}'

# Update tags on an existing instance
oci compute instance update \
  --instance-id <ocid> \
  --freeform-tags '{"env":"staging"}'

# Manage tag namespaces
oci iam tag-namespace create \
  --compartment-id <compartment-ocid> \
  --name Operations \
  --description "Operational tags"

oci iam tag-namespace list --compartment-id <compartment-ocid> --output table
```

## Beyond the basics

Run `oci iam --help` and `oci certs-mgmt --help` for the full surface. Investigate dynamic groups (`oci iam dynamic-group`) to grant instances and functions an IAM identity without static credentials. API keys for service accounts are managed under `oci iam user api-key`. For federated identity, see `oci iam identity-provider`.
