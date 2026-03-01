# Deploying a Preview Environment

Now comes the exciting part! Let's manually deploy a preview environment to understand how everything works together.

## Prepare the Manifests

In a real workflow, GitHub Actions would render these manifests. For this tutorial, we'll use a pre-rendered manifest for PR #123:

```bash
cd /root/demo
ls -la manifests/preview/123/
```{{exec}}

## Examine the Manifest

Let's look at what will be deployed:

```bash
cat manifests/preview/123/manifests.yaml | head -50
```{{exec}}

Notice the structure:
- A unique namespace: `preview-123-todo-app`
- Labels with PR number and commit hash
- Deployment, Service, VirtualService, DestinationRule, and HTTPScaledObject

## Deploy the Preview Environment

Apply the manifest:

```bash
kubectl apply -f manifests/preview/123/manifests.yaml
```{{exec}}

## Verify the Deployment

Check the namespace:

```bash
kubectl get ns | grep preview-123
```{{exec}}

Check all resources in the preview namespace:

```bash
kubectl get all -n preview-123-todo-app
```{{exec}}

## Check KEDA HTTPScaledObject

Verify the HTTPScaledObject was created:

```bash
kubectl get httpscaledobject -n preview-123-todo-app
```{{exec}}

Get more details:

```bash
kubectl describe httpscaledobject -n preview-123-todo-app
```{{exec}}

## Check Istio VirtualService

Verify the VirtualService:

```bash
kubectl get virtualservice -n preview-123-todo-app
```{{exec}}

View the routing rules:

```bash
kubectl get virtualservice -n preview-123-todo-app -o yaml
```{{exec}}

## Wait for Pods to Be Ready

The deployment will start with 1 replica. Let's wait for it to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=todo-app -n preview-123-todo-app --timeout=120s
```{{exec}}

## Access the Preview Environment

Now you can access the TODO app through the Istio Gateway exposed on NodePort 30080!

**Access the PR URL:**

[Open TODO App - PR URL]({{TRAFFIC_HOST1_30080}})

You can also access it via command line:

```bash
curl -s http://localhost:30080 | grep -o "<title>.*</title>"
```{{exec}}

**Note**: The preview environment routes through KEDA's HTTP interceptor, which manages the auto-scaling.

## Understanding the URLs

In this tutorial environment, we're accessing via NodePort. In a real environment with proper DNS:

1. **PR URL**: `todo-123-pr.example.com` → Routes through KEDA
2. **Commit URL**: `todo-123-pr-827f6a4.example.com` → Direct to specific version

Both URLs work through the same Gateway, but with different routing rules.

## Understanding the Deployment

The deployment starts with replicas set to 1, but KEDA will manage the scaling based on traffic.

Check the deployment details:

```bash
kubectl get deployment -n preview-123-todo-app
```{{exec}}

## What Happens Next?

1. KEDA monitors the HTTPScaledObject
2. If no traffic arrives, it scales the deployment to 0
3. When a request comes in, KEDA scales it back up
4. After 5 minutes of inactivity, it scales down again

Let's test this in the next step!

Your preview environment is now deployed and accessible!
