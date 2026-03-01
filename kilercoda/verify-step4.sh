#!/bin/bash

# Verify KEDA and HTTP Add-on are installed
if kubectl get deployment keda-operator -n keda &> /dev/null && \
   kubectl get pods -n keda -l app.kubernetes.io/name=keda-operator --field-selector=status.phase=Running | grep -q "Running" && \
   kubectl get deployment -n keda-http-addon | grep -q "http"; then
  echo "done"
else
  echo "KEDA or HTTP Add-on is not properly installed"
  exit 1
fi
