#!/bin/bash

# Verify that ApplicationSet is created
if kubectl get applicationset todo-app-preview-environment -n argocd &> /dev/null; then
  echo "done"
else
  echo "ApplicationSet not found"
  exit 1
fi
