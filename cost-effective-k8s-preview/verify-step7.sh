#!/bin/bash

# Verify preview environment is deployed
if kubectl get namespace preview-123-todo-app &> /dev/null && \
   kubectl get deployment preview-todo-app -n preview-123-todo-app &> /dev/null && \
   kubectl get httpscaledobject -n preview-123-todo-app &> /dev/null; then
  echo "done"
else
  echo "Preview environment not properly deployed"
  exit 1
fi
