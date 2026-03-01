# Understanding the Dual-URL Strategy

Why do we provide TWO URLs for each preview environment? Let me tell you a story...

## The Problem

In our first implementation, we only had one URL - the PR URL. Everything worked great... until we deployed to production and the service started crashing!

We frantically checked:
- ✅ GitHub Actions: All green
- ✅ Integration tests: All passing
- ❌ Production: Crashing

What happened?!

## The Root Cause: Rolling Updates

Here's what Kubernetes does during a rolling update:

```
1. Starts new pods with updated code
2. Waits for new pods to be Ready
3. Only then removes old pods
4. If new pods never become Ready, old pods keep serving traffic
```

So when we deployed broken code:
- New pods crashed immediately
- Old pods kept running and serving traffic
- Tests hit the OLD pods (which worked fine)
- We never caught the bug!

## The Two URLs Explained

### PR URL: Always Healthy

```
todo-123-pr.127.0.0.1.sslip.io
     ↓
Kubernetes Service
     ↓
Only routes to READY pods
     ↓
Old version keeps running if new crashes
```

**Purpose**: For human testing and exploration
**Routes to**: Whatever pods are healthy and ready

### Commit URL: Exact Version

```
todo-123-pr-abc1234.127.0.0.1.sslip.io
     ↓
DestinationRule with version label
     ↓
Routes to specific commit version
     ↓
New version pods (even if crashing)
```

**Purpose**: For automated testing and verification
**Routes to**: Exact commit SHA pods

## Examining Our Configuration

Let's look at the VirtualService that implements this:

```bash
kubectl get virtualservice -n preview-123-todo-app -o yaml
```{{exec}}

Notice the two routing rules:

1. **PR URL** → KEDA interceptor → Healthy pods
2. **Commit URL** → Direct to version subset

## Check the DestinationRule

The DestinationRule creates subsets based on version labels:

```bash
kubectl get destinationrule -n preview-123-todo-app -o yaml
```{{exec}}

Look for the `subsets` section with version labels like `version: 827f6a4`.

## Real-World Example

Let's say you push commit `abc1234` that has a startup bug:

```javascript
// Oops, this crashes on startup!
const config = JSON.parse(process.env.UNDEFINED_VAR)
```

**PR URL behavior:**
- New pods crash on startup
- Old pods (abc1233) still running and healthy
- Tests hit old pods
- ✅ Tests pass (but shouldn't!)

**Commit URL behavior:**
- DestinationRule routes to `version: abc1234`
- Tries to reach new pods
- New pods are crashing
- ❌ Tests fail (correctly!)

## Testing Strategy

1. **Use PR URL for**:
   - Manual testing by humans
   - Exploratory testing
   - Sharing with stakeholders

2. **Use Commit URL for**:
   - Automated integration tests
   - Smoke tests
   - Deployment verification

## The Complete Picture

```
PR Created → GitHub Actions → Build & Push Image
    ↓
Render Manifests with version label
    ↓
Deploy to Kubernetes
    ↓
Two URLs Created:
  - PR URL (human testing)
  - Commit URL (automated tests)
    ↓
Tests run against Commit URL
    ↓
Catch bugs before merge!
```

## Key Takeaway

The dual-URL strategy ensures that your automated tests verify the **exact code** you pushed, not just "whatever is currently healthy." This catches critical bugs that would otherwise slip through to production.

Let's now see how to automate all of this with ArgoCD ApplicationSets!
