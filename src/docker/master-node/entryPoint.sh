#!/bin/bash
set -e

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to handle errors
error_handler() {
    log_message "Error occurred in script at line: $1."
    exit 1
}

# Trap errors
trap 'error_handler $LINENO' ERR

# Log that the entrypoint script is running
log_message "Running entrypoint script"

# Enable and start containerd
if sudo systemctl enable containerd; then
    log_message "Successfully enabled containerd."
else
    log_message "Failed to enable containerd."
    exit 1
fi

if sudo systemctl start containerd; then
    log_message "Successfully started containerd."
else
    log_message "Failed to start containerd."
    exit 1
fi

# Enable and start kubelet.service
if sudo systemctl enable kubelet; then
    log_message "Successfully enabled kubelet.service."
else
    log_message "Failed to enable kubelet.service."
    exit 1
fi

if sudo systemctl start kubelet; then
    log_message "Successfully started kubelet.service."
else
    log_message "Failed to start kubelet.service. $1"
    exit 1
fi

# Initialize Kubernetes cluster
log_message "Initializing Kubernetes cluster..."
if sudo kubeadm init --control-plane-endpoint "eshop-k8s-master:6443" --upload-certs; then
    log_message "Kubernetes cluster initialized successfully."
else
    log_message "Failed to initialize Kubernetes cluster."
    exit 1
fi

# Configure kubectl for the current user
log_message "Configuring kubectl for current user..."
if mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config; then
    log_message "kubectl configured successfully."
else
    log_message "Failed to configure kubectl."
    exit 1
fi

# Install Weave Net CNI plugin
log_message "Installing Weave Net CNI plugin..."
if kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml; then
    log_message "Weave Net CNI plugin installed successfully."
else
    log_message "Failed to install Weave Net CNI plugin."
    exit 1
fi

# Execute the command specified as CMD in the Dockerfile or passed in the docker run command
exec "$@"
