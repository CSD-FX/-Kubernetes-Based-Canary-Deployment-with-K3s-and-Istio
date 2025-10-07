#!/bin/bash

echo "Starting K3s + Istio installation..."
sleep 2

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y
sleep 10

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
sleep 10

# Install K3s (Kubernetes)
echo "Installing K3s Kubernetes..."
curl -sfL https://get.k3s.io | sh -
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
export KUBECONFIG=~/.kube/config
sleep 10

# Install Istio
echo "Installing Istio service mesh..."
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
sudo cp bin/istioctl /usr/local/bin/
cd ~
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
sleep 10

echo "✅ K3s + Istio installation completed!"
