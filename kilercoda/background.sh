#!/bin/bash

# This script runs in the background to prepare the environment
echo "Preparing your Kubernetes environment..."

# Wait for Kubernetes to be ready
while ! kubectl get nodes &> /dev/null; do
  echo "Waiting for Kubernetes cluster to be ready..."
  sleep 2
done

echo "Kubernetes cluster is ready!"

# Create namespace for tools
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace keda --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace keda-http-addon --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace istio-system --dry-run=client -o yaml | kubectl apply -f -

# Clone the demo repository
cd /root
git clone https://github.com/araminian/k8s-preview.git demo
cd demo

echo "Environment preparation complete!"
