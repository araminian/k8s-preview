#!/bin/bash

# Verify that required namespaces exist
if kubectl get namespace argocd &> /dev/null && \
   kubectl get namespace keda &> /dev/null && \
   kubectl get namespace keda-http-addon &> /dev/null && \
   kubectl get namespace istio-system &> /dev/null; then
  echo "done"
else
  echo "Required namespaces not found"
  exit 1
fi
