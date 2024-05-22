#!/bin/bash

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to handle errors
handle_error() {
    log_message "Error on line $1"
    exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   log_message "This script must be run as root" 
   exit 1
fi

# Ensure masterNodeName argument is provided
if [[ -z "$1" ]]; then
    log_message "Usage: $0 <masterNodeName>"
    exit 1
fi

masterNodeName="$1"

log_message "Updating package index and upgrading packages..."
sudo apt-get update && sudo apt-get upgrade -y

sudo mkdir -p /etc/apt/keyrings

log_message "Adding Docker’s official GPG key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

log_message "Setting up the Docker stable repository..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

log_message "Updating package index again and upgrading packages..."
sudo apt-get update && sudo apt-get upgrade -y

log_message "Installing containerd, kubelet, kubeadm, and kubectl..."
sudo apt-get install -y containerd.io kubeadm kubelet kubectl

log_message "Configuring prerequisites for container runtime..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

log_message "Applying sysctl parameters without reboot..."
sudo sysctl --system

log_message "Creating default containerd configuration file..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

log_message "Modifying containerd configuration to use systemd cgroup..."
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

log_message "Restarting containerd..."
sudo systemctl restart containerd

log_message "Enabling containerd to start on boot..."
sudo systemctl enable containerd

log_message "Initializing Kubernetes cluster..."
sudo kubeadm init --control-plane-endpoint "$masterNodeName.kube.cloudapp.azure.com:6443" --upload-certs 

# Uncomment the following lines to configure kubectl for the current user
# log_message "Configuring kubectl for current user..."
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Uncomment the following line to install a CNI plugin (e.g., Weave Net)
# log_message "Installing Weave Net CNI plugin..."
# kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

log_message "Containerd installation and Kubernetes cluster initialization completed successfully!"
