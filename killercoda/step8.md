# Testing Auto-Scaling to Zero

Let's watch KEDA in action! This is where the cost-saving magic happens.

## Initial State

First, check the current replica count:

```bash
kubectl get deployment preview-todo-app -n preview-123-todo-app
```{{exec}}

You should see 1 replica running.

## Watch the Pods

Let's watch the pods in real-time (this will run in the background):

```bash
watch -n 2 'kubectl get pods -n preview-123-todo-app' &
```{{exec}}

## Wait for Scale Down

KEDA is configured to scale down after 5 minutes (300 seconds) of inactivity. Since we haven't sent much traffic, let's force a scale down to see the behavior faster.

First, let's scale to zero manually to demonstrate:

```bash
kubectl scale deployment preview-todo-app -n preview-123-todo-app --replicas=0
```{{exec}}

Now check the pods:

```bash
kubectl get pods -n preview-123-todo-app
```{{exec}}

You should see "No resources found" - the deployment has scaled to zero!

## Verify Zero Replicas

Confirm the deployment is at 0 replicas:

```bash
kubectl get deployment preview-todo-app -n preview-123-todo-app -o jsonpath='{.status.replicas}'
echo
```{{exec}}

## Trigger Scale-Up with Real Traffic

Now let's send a request to trigger KEDA to scale up the deployment. Access the app:

[Access TODO App]({{TRAFFIC_HOST1_30080}})

Or use curl:

```bash
curl -s http://localhost:30080 | head -20
```{{exec}}

## Watch the Scale-Up

Check the pods again:

```bash
kubectl get pods -n preview-123-todo-app
```{{exec}}

You should see KEDA has scaled the deployment back up! The pod will be in `ContainerCreating` or `Running` state.

## Understanding Scale-Up Flow

When a request arrives at the scaled-to-zero deployment:

1. **KEDA Interceptor receives the request**
2. **Checks if deployment is at 0 replicas**
3. **If yes, holds the request and scales deployment to 1**
4. **Waits for pod to be ready** (this is the "cold start")
5. **Forwards the request to the pod**
6. **User receives response**

The first request after scale-up takes longer (cold start), but subsequent requests are fast!

## Monitor Scale-Up

Watch the pod become ready:

```bash
kubectl wait --for=condition=ready pod -l app=todo-app -n preview-123-todo-app --timeout=120s
```{{exec}}

## Access the Running App

Now that it's scaled up, access it again:

[Access TODO App]({{TRAFFIC_HOST1_30080}})

The response should be faster since the pod is already running!

## Check HTTPScaledObject Status

The HTTPScaledObject tracks the scaling state:

```bash
kubectl get httpscaledobject -n preview-123-todo-app -o yaml | grep -A 10 status
```{{exec}}

## Key Observations

- **Scaling to zero saves resources** - No pods running means no CPU/memory consumed
- **Scale-up is automatic** - First request triggers the scale-up
- **Cold start delay** - Users experience a brief delay on first request after scale-down
- **Configurable timing** - You control the `scaledownPeriod` (default: 300s)

## Calculate Cost Savings

If you have 100 preview environments that are:
- Idle 20 hours per day
- Active 4 hours per day

**Without KEDA:** `100 PRs × 24 hours = 2400 pod-hours/day`

**With KEDA:** `100 PRs × 4 hours = 400 pod-hours/day`

**Savings: 83%!** 🎉

This is why KEDA is essential for cost-effective preview environments.

## Stop the Watch Process

Stop the background watch process:

```bash
pkill -f "watch.*kubectl get pods"
```{{exec}}

Let's move on to understand why we need dual URLs!
