#!/bin/bash

# Verify ArgoCD is installed and running
if kubectl get deployment argocd-server -n argocd &> /dev/null && \
   kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --field-selector=status.phase=Running | grep -q "Running"; then
  echo "done"
else
  echo "ArgoCD is not properly installed"
  exit 1
fi
