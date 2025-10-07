curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install K3s
curl -sfL https://get.k3s.io | sh -

sudo k3s kubectl get nodes

# Set up kubeconfig for your user
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $USER:$USER $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

# Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
sudo cp bin/istioctl /usr/local/bin/

istioctl install --set profile=demo -y

kubectl label namespace default istio-injection=enabled