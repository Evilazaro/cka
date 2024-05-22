#!/bin/bash
set -e

while true; do
    ping -c 1 eshop-k8s-master
    ping -c 1 www.uol.com.br
    sleep 1  # Optional: add a delay to avoid overwhelming the network
done


exec "$@"
