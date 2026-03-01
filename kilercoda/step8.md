# Testing Auto-Scaling to Zero

Let's watch KEDA in action! This is where the cost-saving magic happens.

## Initial State

First, check the current replica count:

```bash
kubectl get deployment preview-todo-app -n preview-123-todo-app
```{{exec}}

You should see 1 replica running.

## Watch the Pods

Let's watch the pods in real-time:

```bash
kubectl get pods -n preview-123-todo-app -w &
```{{exec}}

Keep this running in the background.

## Wait for Scale Down

KEDA is configured to scale down after 5 minutes (300 seconds) of inactivity. Since we just deployed and haven't sent any traffic, it should scale down soon.

Check the KEDA operator logs to see what's happening:

```bash
kubectl logs -n keda-http-addon -l app.kubernetes.io/name=keda-add-ons-http --tail=20
```{{exec}}

## Force Scale Down (Optional)

If you don't want to wait 5 minutes, you can manually scale to zero to see the behavior:

```bash
kubectl scale deployment preview-todo-app -n preview-123-todo-app --replicas=0
```{{exec}}

Now check the pods again:

```bash
kubectl get pods -n preview-123-todo-app
```{{exec}}

You should see "No resources found" - the deployment has scaled to zero!

## Verify Zero Replicas

Confirm the deployment is at 0 replicas:

```bash
kubectl get deployment preview-todo-app -n preview-123-todo-app -o jsonpath='{.status.replicas}'
```{{exec}}

## Simulate a Request

Now let's simulate a request to trigger scale-up. First, we need to send traffic through the KEDA interceptor.

Get the KEDA interceptor service:

```bash
kubectl get svc -n keda-http-addon
```{{exec}}

## Understanding Scale-Up

When a request arrives:

1. **KEDA Interceptor receives the request**
2. **Checks if deployment is at 0 replicas**
3. **If yes, holds the request and scales deployment to 1**
4. **Waits for pod to be ready**
5. **Forwards the request to the pod**
6. **User receives response**

This happens automatically - the user just experiences a slightly longer first request (cold start).

## Check HTTPScaledObject Status

The HTTPScaledObject tracks the scaling state:

```bash
kubectl get httpscaledobject -n preview-123-todo-app -o yaml | grep -A 10 status
```{{exec}}

## Key Observations

- **Scaling to zero saves resources** - No pods running means no CPU/memory consumed
- **Scale-up is automatic** - First request triggers the scale-up
- **Configurable delay** - You control the `scaledownPeriod` (default: 300s)

## Calculate Cost Savings

If you have 100 preview environments that are:
- Idle 20 hours per day
- Active 4 hours per day

Without KEDA: `100 PRs × 24 hours = 2400 pod-hours`
With KEDA: `100 PRs × 4 hours = 400 pod-hours`

**Savings: 83%!** 🎉

This is why KEDA is essential for cost-effective preview environments.

Let's move on to understand why we need dual URLs!
