#!/bin/bash

# Verify Gateway is created
if kubectl get gateway ingress-gateway -n istio-system &> /dev/null; then
  echo "done"
else
  echo "Gateway not found"
  exit 1
fi
