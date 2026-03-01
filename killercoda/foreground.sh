#!/bin/bash

echo "Welcome to Kubernetes Preview Environments Tutorial!"
echo "Please wait while we prepare your environment..."
echo ""
echo "This may take a few moments..."

# Wait for background script to complete
while [ ! -f /root/demo/README.md ]; do
  sleep 1
done

clear
echo "✅ Environment is ready!"
echo ""
echo "Let's begin building preview environments on Kubernetes!"
