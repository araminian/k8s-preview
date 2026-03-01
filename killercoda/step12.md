# Understanding Auto-Scaling to Zero

Now that you've seen your preview environment in action, let's dive deep into how KEDA manages auto-scaling to save costs!

## The Cost Problem

Imagine you have 100 open Pull Requests, each with its own preview environment running 24/7:

**Without auto-scaling**:
- 100 PRs × 24 hours = 2,400 pod-hours per day
- Most of these pods sit idle 80-90% of the time
- You're paying for resources you're not using!

**With KEDA scale-to-zero**:
- Pods run only when accessed
- Average usage: 2-4 hours per day per PR
- 100 PRs × 3 hours = 300 pod-hours per day
- **87% cost reduction!** 💰

## How KEDA HTTP Add-on Works

The KEDA HTTP Add-on acts as an intelligent proxy between incoming requests and your application.

### Components

**KEDA Interceptor Proxy**:
- Receives all incoming HTTP requests
- Checks if the target deployment is scaled to zero
- Holds requests while scaling up
- Forwards requests once pods are ready

**KEDA Scaler**:
- Monitors HTTP traffic metrics
- Scales deployments up based on request rate
- Scales deployments down after inactivity period

**HTTPScaledObject**:
- Custom resource defining scaling behavior
- Specifies target deployment, service, and scaling rules

## Watch Scale-to-Zero in Action

Let's observe the scaling behavior with your preview environment:

### Check Current State

```bash
# Replace PR_NUMBER with your actual PR number
kubectl get deployment -n preview-PR_NUMBER-todo-app
```{{copy}}

Note the number of replicas (READY column).

### Watch Pods in Real-Time

Open a watch command:

```bash
watch -n 2 kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

Keep this running in the background (press Ctrl+C to stop later).

### Trigger Scale-Down (If Still Running)

If pods are still running, wait 5 minutes without accessing the app, or manually scale down:

```bash
kubectl scale deployment preview-todo-app -n preview-PR_NUMBER-todo-app --replicas=0
```{{copy}}

Watch the pods terminate:

```bash
kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

You should see:
```
No resources found in preview-PR_NUMBER-todo-app namespace.
```

## Trigger Scale-Up

Now let's trigger a scale-up by sending traffic:

### Access the Preview Environment

[Open Preview Environment]({{TRAFFIC_HOST1_30080}})

Or use curl:

```bash
curl -s http://localhost:30080 | head -20
```{{exec}}

### Watch the Magic Happen

In your watch window, you'll see:

1. **Pod created**: Status `Pending` or `ContainerCreating`
2. **Container starting**: Pulling image, starting app
3. **Pod ready**: Status `Running`, READY `2/2`
4. **Request forwarded**: Your page loads!

This is the "cold start" - typically 10-30 seconds.

## Understanding the HTTPScaledObject

Let's examine the scaling configuration:

```bash
kubectl get httpscaledobject -n preview-PR_NUMBER-todo-app -o yaml
```{{copy}}

Key settings:

```yaml
spec:
  replicas:
    min: 0          # Can scale to zero!
    max: 2          # Maximum 2 replicas
  scaledownPeriod: 300  # Wait 5 minutes before scaling down
  scalingMetric:
    requestRate:
      targetValue: 1    # Target 1 request per second per pod
      window: 1m        # Look at last 1 minute of traffic
```

### Configuration Explained

**min: 0**
- Allows scaling to zero replicas
- No pods = no resource consumption
- Maximum cost savings

**max: 2**
- Limits maximum replicas
- Prevents runaway scaling
- Suitable for preview environments (low traffic)

**scaledownPeriod: 300**
- Waits 5 minutes of inactivity before scaling down
- Prevents rapid scale up/down cycles
- Balances cost savings with responsiveness

**targetValue: 1**
- Aims for 1 request/second per pod
- If traffic > 1 req/s, scales up
- If traffic < 1 req/s, scales down

## The Scaling Algorithm

### Scale-Up Logic

```
1. Request arrives at KEDA Interceptor
2. Check: Is deployment at 0 replicas?
   ├─ Yes: Hold request
   │       Scale deployment to 1
   │       Wait for pod ready
   │       Forward request
   └─ No:  Forward request immediately

3. Monitor request rate
4. If rate > targetValue × current replicas:
   └─ Scale up (up to max replicas)
```

### Scale-Down Logic

```
1. Monitor request rate continuously
2. If rate < targetValue × current replicas:
   ├─ Wait scaledownPeriod seconds
   ├─ Check rate again
   └─ If still low, scale down by 1

3. If no requests for scaledownPeriod:
   └─ Scale to 0 replicas
```

## Check KEDA Logs

Want to see KEDA in action? Check the logs:

### Interceptor Logs (Request Handling)

```bash
kubectl logs -n keda-http-addon -l app.kubernetes.io/name=keda-add-ons-http-interceptor --tail=50
```{{exec}}

You'll see:
- Incoming requests
- Scaling decisions
- Request forwarding

### Scaler Logs (Scaling Decisions)

```bash
kubectl logs -n keda-http-addon -l app.kubernetes.io/name=keda-add-ons-http-scaler --tail=50
```{{exec}}

You'll see:
- Metric collection
- Scaling calculations
- HPA updates

## Cost Calculation Example

Let's calculate real savings for your organization:

### Scenario: 50 Active PRs

**Assumptions**:
- 50 PRs with preview environments
- Each pod: 0.1 CPU, 128Mi memory
- Cloud cost: $0.05/hour per pod
- Active usage: 3 hours/day per PR

**Without KEDA** (always running):
```
50 PRs × 24 hours × $0.05 = $60/day = $1,800/month
```

**With KEDA** (scale-to-zero):
```
50 PRs × 3 hours × $0.05 = $7.50/day = $225/month
```

**Savings**: $1,575/month (87% reduction!) 🎉

## Testing Different Scenarios

### Scenario 1: Rapid Requests

Send multiple requests quickly:

```bash
for i in {1..10}; do curl -s http://localhost:30080 > /dev/null & done
```{{exec}}

Watch KEDA keep pods running due to activity.

### Scenario 2: Sustained Traffic

Keep sending requests every 30 seconds for 3 minutes:

```bash
for i in {1..6}; do 
  curl -s http://localhost:30080 > /dev/null
  echo "Request $i sent"
  sleep 30
done
```{{exec}}

Pods should stay running.

### Scenario 3: Inactivity

Stop all requests and wait 5 minutes. Watch pods scale to zero.

## Production Considerations

When using KEDA in production:

### Tune scaledownPeriod

```yaml
scaledownPeriod: 300  # 5 minutes (aggressive cost savings)
scaledownPeriod: 600  # 10 minutes (balance)
scaledownPeriod: 1800 # 30 minutes (prefer responsiveness)
```

**Trade-off**: Longer period = fewer cold starts but higher costs

### Adjust targetValue

```yaml
targetValue: 1   # Scale at 1 req/s per pod
targetValue: 10  # Scale at 10 req/s per pod
targetValue: 50  # Scale at 50 req/s per pod
```

**Lower value** = More aggressive scaling, more pods
**Higher value** = Fewer pods, higher latency under load

### Set Appropriate min/max

```yaml
replicas:
  min: 0  # Preview environments (max cost savings)
  min: 1  # Production (no cold starts)
  max: 5  # Small apps
  max: 50 # Large apps under heavy load
```

## Monitoring and Alerts

In production, monitor:

- **Cold start frequency**: Too many? Increase `scaledownPeriod`
- **Scale-up latency**: Too slow? Pre-warm with `min: 1`
- **Cost metrics**: Track actual savings vs. goals
- **Error rates during scale-up**: Tune timeouts

## Key Takeaways

✅ **KEDA enables scale-to-zero** - Native HPA can only scale to 1
✅ **HTTP Add-on holds requests** - No dropped requests during scale-up
✅ **Massive cost savings** - 80-90% reduction is common
✅ **Configurable trade-offs** - Balance cost vs. responsiveness
✅ **Perfect for preview environments** - Low traffic, high idle time

Your preview environment is now cost-optimized! Next, let's understand why we need two URLs for proper testing.
