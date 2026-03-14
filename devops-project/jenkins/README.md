# Jenkins CI/CD Setup

## Prerequisites

- Jenkins with Docker Pipeline plugin, Pipeline: AWS Steps (or AWS CLI), and Helm installed
- Jenkins agent/controller able to run Docker (Docker-in-Docker or host Docker socket)
- AWS credentials with permission to `eks:DescribeCluster` and to assume any IAM role used by the EKS node/user
- Docker Hub credentials

## Jenkins Credentials

Create these credentials in Jenkins (Manage Jenkins → Credentials):

1. **dockerhub-credentials** (Username with password)
   - Kind: Username with password
   - ID: `dockerhub-credentials`
   - Username: your Docker Hub username
   - Password: Docker Hub password or access token

2. **aws-eks-credentials** (AWS)
   - Kind: AWS Credentials
   - ID: `aws-eks-credentials`
   - Access Key ID and Secret Key with permissions to EKS and (if using IRSA) appropriate IAM

## Environment Variables

In the Jenkinsfile, set:

- `EKS_CLUSTER_NAME`: Your EKS cluster name (e.g. from Terraform output `lms-devops-dev-eks`)
- `AWS_REGION`: AWS region (e.g. `us-east-1`)
- `DOCKERHUB_NAMESPACE`: Your Docker Hub username or org

## Pipeline Behavior

1. **Checkout**: Clones the repo from GitHub (configure job to use GitHub source).
2. **Build & Push**: Builds Docker images for api-gateway, user-service, product-service and pushes to Docker Hub with tag `BUILD_NUMBER` and `latest`.
3. **Configure kubectl**: Runs `aws eks update-kubeconfig` so `kubectl` and `helm` target your EKS cluster.
4. **Deploy**: Runs `helm upgrade --install` for each microservice with the new image tag.

## Job Configuration

- Create a **Pipeline** job.
- Under **Pipeline**, choose **Pipeline script from SCM**.
- SCM: **Git**, Repository URL: your GitHub repo URL, branch: `main` (or your default).
- Script Path: `devops-project/Jenkinsfile` (or `Jenkinsfile` if repo root is the project root).

## Optional: Apply Ingress

After first deploy, apply the Ingress once (if not managed by Terraform/Helm):

```bash
kubectl apply -f devops-project/kubernetes/ingress.yaml
```

Ensure AWS Load Balancer Controller is installed on the EKS cluster.
