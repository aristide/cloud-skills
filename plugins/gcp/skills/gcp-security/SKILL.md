---
name: gcp-security
description: "Use when the user needs to manage Google Cloud security — SSH keys (OS Login or metadata-based), TLS/SSL certificates, IAM roles and service accounts, and resource labels."
---

# Google Cloud Security

GCP security spans SSH access, TLS certificates, IAM, and service accounts. Enable relevant APIs: `gcloud services enable compute.googleapis.com iamcredentials.googleapis.com certificatemanager.googleapis.com`.

## SSH Keys

GCP supports two approaches. **OS Login** is recommended for production; **metadata-based keys** are simpler for quick setups.

### OS Login (recommended)

OS Login ties SSH access to your Google identity and IAM roles. Enable it at project or instance level:

```bash
# Enable OS Login project-wide
gcloud compute project-info add-metadata --metadata enable-oslogin=TRUE

# Add your SSH public key to your Google account
gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa.pub

# List stored OS Login SSH keys
gcloud compute os-login ssh-keys list

# Remove an SSH key (use the fingerprint from the list above)
gcloud compute os-login ssh-keys remove --key <fingerprint>

# Grant OS Login access via IAM
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@example.com' \
  --role='roles/compute.osLogin'
```

### Metadata-based SSH keys (simpler, legacy)

```bash
# Add a project-wide SSH key (applies to all instances)
gcloud compute project-info add-metadata \
  --metadata ssh-keys="myuser:$(cat ~/.ssh/id_rsa.pub)"

# Add an instance-level key (overrides project keys when set)
gcloud compute instances add-metadata my-instance \
  --zone us-central1-a \
  --metadata ssh-keys="myuser:$(cat ~/.ssh/id_rsa.pub)"

# Block project-wide SSH keys on a specific instance
gcloud compute instances add-metadata my-instance \
  --zone us-central1-a \
  --metadata block-project-ssh-keys=TRUE
```

## TLS / SSL Certificates

### Self-managed certificates (upload your own)

```bash
gcloud compute ssl-certificates create my-cert \
  --certificate cert.pem \
  --private-key key.pem

gcloud compute ssl-certificates list
gcloud compute ssl-certificates describe my-cert
gcloud compute ssl-certificates delete my-cert
```

### Google-managed certificates (Certificate Manager — auto-renewed)

```bash
# Enable API
gcloud services enable certificatemanager.googleapis.com

# Create a Google-managed certificate
gcloud certificate-manager certificates create my-managed-cert \
  --domains="example.com,www.example.com"

gcloud certificate-manager certificates list
gcloud certificate-manager certificates describe my-managed-cert
gcloud certificate-manager certificates delete my-managed-cert
```

Attach a certificate to an HTTPS load balancer target proxy:

```bash
gcloud compute target-https-proxies create my-https-proxy \
  --ssl-certificates my-cert \
  --url-map my-url-map
```

## IAM: Roles and Policy Bindings

```bash
# List IAM policy on a project
gcloud projects get-iam-policy PROJECT_ID

# Grant a role to a user
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@example.com' \
  --role='roles/compute.instanceAdmin.v1'

# Grant a role to a service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/storage.objectAdmin'

# Revoke a role
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member='user:alice@example.com' \
  --role='roles/compute.instanceAdmin.v1'

# List predefined roles
gcloud iam roles list --filter='name~compute'
```

## Service Accounts

```bash
# Create a service account
gcloud iam service-accounts create my-sa \
  --display-name="My Service Account"

# List service accounts
gcloud iam service-accounts list

# Create a key file (download credentials)
gcloud iam service-accounts keys create key.json \
  --iam-account=my-sa@PROJECT_ID.iam.gserviceaccount.com

# List keys for a service account
gcloud iam service-accounts keys list \
  --iam-account=my-sa@PROJECT_ID.iam.gserviceaccount.com

# Delete a key
gcloud iam service-accounts keys delete KEY_ID \
  --iam-account=my-sa@PROJECT_ID.iam.gserviceaccount.com

# Delete a service account
gcloud iam service-accounts delete my-sa@PROJECT_ID.iam.gserviceaccount.com
```

Attach a service account to an instance at create time or update:

```bash
gcloud compute instances create my-instance \
  --service-account=my-sa@PROJECT_ID.iam.gserviceaccount.com \
  --scopes=cloud-platform \
  --zone us-central1-a
```

## Labels

Labels are key-value pairs attached to resources for organization and billing.

```bash
# Add/update labels on an instance
gcloud compute instances update my-instance \
  --zone us-central1-a \
  --update-labels env=prod,team=backend

# Add labels on a disk
gcloud compute disks update my-disk \
  --zone us-central1-a \
  --update-labels env=prod

# Filter resources by label
gcloud compute instances list --filter='labels.env=prod'

# Remove a label (set its value to empty string)
gcloud compute instances update my-instance \
  --zone us-central1-a \
  --remove-labels team
```

## Beyond the basics

Run `gcloud iam --help`, `gcloud compute ssl-certificates --help`, or `gcloud certificate-manager --help` for more options. Workload Identity Federation, VPC Service Controls, and Secret Manager (`gcloud secrets`) provide deeper security postures for production workloads.
