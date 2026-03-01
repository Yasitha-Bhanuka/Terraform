# 🚀 Terraform GCP — Docker + Cloud Run Deployment

Infrastructure as Code (IaC) project that uses **Terraform** to build a Docker image, push it to **Google Artifact Registry**, and deploy it to **Google Cloud Run** — all automated.

---

## 📁 Project Structure

```
Terraform/
├── src/                        # Application source code
│   ├── app.py                  # Flask web application
│   ├── Dockerfile              # Docker image definition
│   └── requirements.txt        # Python dependencies
├── terraform/                  # Terraform configuration files
│   ├── main.tf                 # Providers & backend config
│   ├── service.tf              # Docker image build, registry push & Cloud Run
│   ├── storage.tf              # Google Cloud Storage bucket
│   └── iam.tf                  # IAM policy for Cloud Run (optional)
├── .gitignore
└── README.md
```

---

## 🛠️ Tech Stack

| Tool                  | Purpose                                  |
| --------------------- | ---------------------------------------- |
| **Terraform**         | Infrastructure provisioning & management |
| **Google Cloud**      | Cloud platform (GCP)                     |
| **Artifact Registry** | Docker image storage on GCP              |
| **Cloud Run**         | Serverless container deployment          |
| **Docker**            | Containerization                         |
| **Flask (Python)**    | Simple web application                   |

---

## ⚙️ Infrastructure Overview

This project provisions the following GCP resources via Terraform:

1. **Google Cloud Storage Bucket** — `yasitha-gcs-demo` with soft-delete disabled
2. **Google Artifact Registry** — Docker repository in `asia-southeast1`
3. **Docker Image** — Built from `src/` and pushed to Artifact Registry
4. **Google Cloud Run Service** — Deploys the containerized Flask app
5. **IAM Policy** *(optional, currently commented out)* — Allows public access to Cloud Run service

### Architecture Flow

```
src/ (Flask App)
    │
    ▼
Docker Image Build (Terraform + Docker provider)
    │
    ▼
Google Artifact Registry (asia-southeast1)
    │
    ▼
Google Cloud Run (yasitha-service)
    │
    ▼
Accessible via Cloud Run URL (authenticated / public)
```

---

## 📋 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install) installed & authenticated
- [Docker](https://docs.docker.com/get-docker/) installed & running
- A GCP project (this project uses `yasitha-docker-demo`)

---

## 🚀 Getting Started

### 1. Authenticate with Google Cloud

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project yasitha-docker-demo
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Preview Changes

```bash
terraform plan
```

### 4. Apply Infrastructure

```bash
terraform apply
```

This will:
- Create the Artifact Registry repository
- Build the Docker image from `src/`
- Push the image to Artifact Registry
- Deploy the image to Cloud Run

### 5. Access the Service

After deployment, Terraform will output the Cloud Run service URL. By default, the service requires **authentication** (Bearer token via IAM).

To test with a Bearer token:

```bash
# Get an access token
TOKEN=$(gcloud auth print-identity-token)

# Call the service
curl -H "Authorization: Bearer $TOKEN" <CLOUD_RUN_URL>
```

---

## 🔐 IAM Configuration

The `iam.tf` file contains a **commented-out** IAM policy that grants public (`allUsers`) access to the Cloud Run service.

- **To enable public access:** Uncomment the resources in `iam.tf` and run `terraform apply`
- **To keep it private:** Leave `iam.tf` as-is and use Bearer tokens for authentication

---

## 📄 Terraform Files Explained

| File         | Description                                                            |
| ------------ | ---------------------------------------------------------------------- |
| `main.tf`    | Configures Google & Docker providers, sets GCP project/region          |
| `service.tf` | Builds Docker image, pushes to Artifact Registry, deploys to Cloud Run |
| `storage.tf` | Creates a GCS bucket with soft-delete policy disabled                  |
| `iam.tf`     | (Optional) IAM bindings to allow public access to Cloud Run            |

---

## 🧹 Cleanup

To destroy all provisioned infrastructure:

```bash
terraform destroy
```

---

## 🧭 Development Journey — Step by Step

This project was built **incrementally**, where each step solved a problem or limitation discovered in the previous step.

---

### Step 1 — Initial Setup: Terraform + GCP *(commit `e1ccf2a`)*

> **Goal:** Start practicing Terraform with Google Cloud Platform.

Set up the basic Terraform configuration with the **Google provider**, configured the GCP project (`yasitha-docker-demo`), region (`asia-southeast1`), and created a **Google Cloud Storage bucket** for learning purposes.

**Files created:** `main.tf`, `storage.tf`

---

### Step 2 — Soft Delete Problem *(commit `1944e74`)*

> **🤔 Problem:** The GCS bucket had the default soft-delete retention policy, which keeps deleted objects for extra cost and time.
>
> **✅ Solution:** Added `soft_delete_policy` with `retention_duration_seconds = 0` to disable soft-delete and avoid unnecessary storage costs.

```hcl
soft_delete_policy {
  retention_duration_seconds = 0
}
```

---

### Step 3 — Dockerize the Application *(commit `ed65aca`)*

> **🤔 Problem:** The Flask app was just raw Python — no standard way to package and run it consistently across environments.
>
> **✅ Solution:** Created a `Dockerfile` to containerize the Flask app using Python 3.12, exposing it on port 8080.

**Files created:** `src/Dockerfile`, `src/app.py`, `src/requirements.txt`

---

### Step 4 — Build Docker Image with Terraform *(commit `85f9930`)*

> **🤔 Problem:** Docker images were being built manually with `docker build`. This is not Infrastructure as Code — it's not automated or reproducible.
>
> **✅ Solution:** Added the **kreuzwerker/docker** Terraform provider to build Docker images directly from Terraform, making the image build part of the infrastructure pipeline.

**Files modified:** `main.tf` (added Docker provider), **created:** `service.tf`

---

### Step 5 — Push Image to Google Artifact Registry *(commit `ce21033`)*

> **🤔 Problem:** The Docker image was built locally but had no cloud registry to store it. Without a registry, Cloud Run can't pull the image for deployment.
>
> **✅ Solution:** Created a **Google Artifact Registry** repository and configured the Docker provider with **OAuth2 authentication** to push images to GCP.

```hcl
provider "docker" {
  registry_auth {
    address  = "asia-southeast1-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}
```

---

### Step 6 — Automate Build + Push via Terraform *(commit `3fcc7f7`)*

> **🤔 Problem:** Building the image and pushing it were separate manual steps. The image name also needed to match the Artifact Registry path format.
>
> **✅ Solution:** Updated the Docker image `name` to include the full Artifact Registry path, and added a `docker_registry_image` resource to **automatically push** the built image to the registry.

```hcl
resource "docker_registry_image" "yasitha_registry_image" {
  name          = docker_image.yasitha-demo-docker-image.name
  keep_remotely = true
}
```

---

### Step 7 — Deploy to Cloud Run *(commit `6157517`)*

> **🤔 Problem:** The image is in Artifact Registry, but it's not running anywhere. There's no live service serving traffic.
>
> **✅ Solution:** Created a **Google Cloud Run** service that pulls the image from Artifact Registry and deploys it as a serverless container.

```hcl
resource "google_cloud_run_service" "yasitha_service" {
  name     = "yasitha-service"
  location = "asia-southeast1"
  template {
    spec {
      containers {
        image = docker_registry_image.yasitha_registry_image.name
      }
    }
  }
}
```

---

### Step 8 — Enable Public Access via IAM *(commit `c938d48`)*

> **🤔 Problem:** Cloud Run deployed successfully, but the service URL returned **403 Forbidden**. By default, Cloud Run requires authentication — no one can access it publicly.
>
> **✅ Solution:** Created an IAM policy binding with `allUsers` as `roles/run.invoker`, allowing **anyone** to access the Cloud Run service without authentication.

**Files created:** `iam.tf`

---

### Step 9 — Remove Public Access for Security *(commit `ca81fbb`)*

> **🤔 Problem:** The service is now publicly exposed to the internet. This is a **security risk** — anyone can call the API without restrictions.
>
> **✅ Solution:** Commented out the IAM policy in `iam.tf` to **revoke public access**. Now the service requires a **Bearer token** for authentication, which can be tested via Postman or `curl`.

```bash
# Get token & test
TOKEN=$(gcloud auth print-identity-token)
curl -H "Authorization: Bearer $TOKEN" <CLOUD_RUN_URL>
```

---

### 📊 Journey Summary

```
Step 1: Setup Terraform + GCP basics
  │
  ▼  ❌ Soft-delete wastes storage
Step 2: Disable soft-delete policy
  │
  ▼  ❌ App has no container packaging
Step 3: Dockerize the Flask app
  │
  ▼  ❌ Docker build is manual, not IaC
Step 4: Build Docker image via Terraform
  │
  ▼  ❌ Image exists locally only, no registry
Step 5: Create Artifact Registry + push config
  │
  ▼  ❌ Build & push are separate manual steps
Step 6: Automate full build → push pipeline
  │
  ▼  ❌ Image is stored but not running anywhere
Step 7: Deploy to Cloud Run
  │
  ▼  ❌ Service returns 403 — not publicly accessible
Step 8: Add IAM policy for public access
  │
  ▼  ❌ Security risk — open to everyone
Step 9: Revoke public access, use Bearer tokens
  │
  ▼  ✅ Secure, automated, cloud-native deployment!
```

---

## 👤 Author

**Yasitha Bhanuka** — [yasithabhanukac@gmail.com](mailto:yasithabhanukac@gmail.com)
