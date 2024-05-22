#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Update the package index
logMessage "Updating package index..."

masterNodeName="$1"

sudo apt-get update && \
sudo apt-get upgrade -y

# Add Docker’s official GPG key
logMessage "Adding Docker’s official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker stable repository
logMessage "Setting up the Docker stable repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index again
logMessage "Updating package index again..."
sudo apt-get update && \
sudo apt-get upgrade -y

# Install containerd
logMessage "Installing containerd..."
sudo apt-get install -y containerd.io kubelet kubeadm kubectl

# Configure the prerequisites for the container runtime (https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic)
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF


# Apply sysctl params without reboot
sudo sysctl --system

# Create the default config.toml configuration file
logMessage "Creating the default containerd configuration file..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
logMessage "Restarting containerd..."
sudo systemctl restart containerd

# Enable containerd to start on boot
logMessage "Enabling containerd to start on boot..."
sudo systemctl enable containerd

# inicializar o cluster
sudo kubeadm init --control-plane-endpoint "$masterNodeNamekube.cloudapp.azure.com:6443" --upload-certs 

## configurar o kubectl (essas instruções também são exibidas após iniciar o cluster com kubeadm)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# instalar plugin de CNI (https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

logMessage "containerd installation completed successfully!"
