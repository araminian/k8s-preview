#!/bin/bash

# Verify ApplicationSet is created
if kubectl get applicationset todo-app-preview-environment -n argocd &> /dev/null && \
   kubectl get application -n argocd | grep -q "todo-app-preview"; then
  echo "done"
else
  echo "ApplicationSet not properly configured"
  exit 1
fi
