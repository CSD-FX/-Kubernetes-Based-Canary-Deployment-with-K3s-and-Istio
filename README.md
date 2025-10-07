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
  chmod 755 *.sh
  ```
### Docker Install.
  ```bash
  # Add Docker's official GPG key
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ```
### Configure Docker 
  ```bash
# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
docker ps
  ```

###  Install K3S
  ```bash
 curl -sfL https://get.k3s.io | sh -
  ```
## ⛔️ wait for 1-2minutes before proceeding 

  ```bash
 sudo systemctl status k3s
# Should show: active (running)
  ```
### Configure Kubectl access
  ```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

# Change ownership
sudo chown $USER:$USER ~/.kube/config

# Set KUBECONFIG environment variable
echo "export KUBECONFIG=~/.kube/config" >> ~/.bashrc
source ~/.bashrc

# Verify kubectl works
kubectl get nodes
  ```
### Verify K3S installation
  ```bash
# Check all system pods
kubectl get pods --all-namespaces

# Check node details
kubectl describe node $(kubectl get nodes -o name | cut -d/ -f2)

# Check cluster info
kubectl cluster-info
  ```
### ISTIO Install.
  ```bash
# ISTIO Install - Add sudo for permanent access:
curl -L https://istio.io/downloadIstio | sh -
cd istio-*

# Make istioctl permanently available
sudo cp bin/istioctl /usr/local/bin/
export PATH=$PWD/bin:$PATH

istioctl version --remote=false
  ```
### Install Istio with Demo Profile
  ```bash
istioctl install --set profile=demo -y
  ```
### Enable Istio Sidecar Injection
  ```bash
kubectl label namespace default istio-injection=enabled
  ```
### Verify Istio Installation.
  ```bash
# Check Istio services
kubectl get svc -n istio-system

# Check Istio pods
kubectl get pods -n istio-system
  ```

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


