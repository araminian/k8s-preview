#!/bin/bash

# Verify Istio is installed
if kubectl get deployment istiod -n istio-system &> /dev/null && \
   kubectl get pods -n istio-system -l app=istiod --field-selector=status.phase=Running | grep -q "Running" && \
   kubectl get svc istio-ingressgateway -n istio-system &> /dev/null; then
  echo "done"
else
  echo "Istio is not properly installed"
  exit 1
fi
