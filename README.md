# Kubernetes Canary Deployment with K3s and Istio

# Project Overview
This project demonstrates a complete Kubernetes canary deployment using K3s and Istio. It features traffic splitting (80/20), safe rollouts, instant rollback capabilities, and production-ready configuration. Perfect for learning modern deployment strategies in a lightweight Kubernetes environment.

### Prerequisites
- AWS EC2 Account
- Docker Hub account (for container images)

## Step-by-Step Guide

# Step 1: Launch EC2 Instance.
   - Name: `k3s-istio-canary`
   - AMI: Ubuntu 22.04 LTS
   - Instance Type: t3 medium 
   - Storage: 20GB SSD
   -  Security Group** (Allow these ports: 22, 80, 30000-32767)
---
# Step 2: Clone the repo
  ```bash
  git clone https://github.com/CSD-FX/Kubernetes-Based-Canary-Deployment-with-K3s-and-Istio.git
  cd Kubernetes-Based-Canary-Deployment-with-K3s-and-Istio
  ```

---
# Step 3: Install Required Tools.
  ```bash
  ./requirements.sh
  ```
  ```bash
  sudo usermod -aG docker $USER
  newgrp docker
  ```

---

# Step 4: Build Docker-Images and push it to DockerHub.
  ```bash
cd app-v1
docker build -t YOUR_DOCKERHUB_USERNAME/canary-app:v1.0 .
docker push YOUR_DOCKERHUB_USERNAME/canary-app:v1.0
cd ..
cd app-v2
docker build -t YOUR_DOCKERHUB_USERNAME/canary-app:v1.1 .
docker push YOUR_DOCKERHUB_USERNAME/canary-app:v1.1
cd ..
  ```
---

# Step 5: Deploy to Kubernetes.

 ### Before applying, change these values in k8s-manifests/
   - ⚠️ In both v1.yaml and v2.yaml > Update your own DOCKERHUB Username in the files. ‼️ 
     
  ```bash
kubectl apply -f k8s-manifests/deployment-v1.yaml
kubectl apply -f k8s-manifests/deployment-v2.yaml
  ```
### Setup Istio traffic management
  ```bash
kubectl apply -f istio-config/gateway.yaml
kubectl apply -f istio-config/destination-rule.yaml
kubectl apply -f istio-config/80-20_deployment.yaml
  ```
---

### Verify Deployment
```bash
  ./verify-complete.sh
```
---

# Step 6: Get application access URL
  ```bash
export EC2_IP=$(curl -s http://checkip.amazonaws.com)
export NODE_PORT=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
echo "Access your application at: http://$EC2_IP:$NODE_PORT"
  ```
---

# Step 7: Test Canary_80%-20% /Rollback /latest-update deployments with logs.
--
 ### Test Canary Deployment.
 ```bash
./test-traffic-split.sh
```
--
 ### Upgrade completely to latest version.
 ```bash
./latest-version-update_only.sh
```
--
### Rollback to previous version.
```bash
./previous-version-rollback.sh
```
--
### BACK TO CANARY-DEPLOYMENT.
```bash
./80-20_deployment.sh
```
---
## 🙏 Acknowledgments

Thank you to everyone using this repository to practice DevOps skills! Your journey in mastering Kubernetes deployments matters. Keep learning, keep deploying! 🚀

---
*Happy coding! If this helped you, please give it a ⭐*


