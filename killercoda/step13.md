# Understanding the Dual-URL Strategy

You might have noticed that preview environments provide **two different URLs**. Let's understand why this is crucial for catching bugs before production!

## The Two URLs

For your preview environment (PR #123), you have:

### PR URL (Human-Friendly)
```
http://todo-123-pr.{IP}.sslip.io
```
- Routes through **Kubernetes Service**
- Points to **healthy, ready pods only**
- If new deploy crashes, old version keeps serving
- **Use for**: Manual testing, demos, stakeholder reviews

### Commit URL (Test-Specific)
```
http://todo-123-pr-abc1234.{IP}.sslip.io
```
- Routes through **Istio DestinationRule**
- Points to **specific commit version** (abc1234)
- Even if pods crash, tests hit them
- **Use for**: Automated integration tests, CI/CD pipelines

## The Problem: Rolling Updates Hide Bugs

Let me tell you a story about why we need two URLs...

### The Production Incident

One day, we deployed to production and **the service started crashing immediately**. Panic!

We frantically checked:
- ✅ GitHub Actions: All green
- ✅ Integration tests: All passing  
- ✅ Code review: Approved
- ❌ **Production: Crashing on startup**

How did this pass all our tests?!

### The Root Cause

One commit in the PR had a critical bug:

```javascript
// This crashes immediately on startup!
const config = JSON.parse(process.env.MISSING_VAR)
// MISSING_VAR is undefined → crashes
```

But our tests all passed! Why?

## Understanding Kubernetes Rolling Updates

Kubernetes uses rolling updates to deploy new versions safely:

```
Old Deployment (v1):
├─ Pod 1: ✅ Healthy, serving traffic
└─ Pod 2: ✅ Healthy, serving traffic

New Deployment (v2) starts:
├─ Pod 3: ❌ CrashLoopBackOff (startup error)
└─ Pod 4: ❌ CrashLoopBackOff (startup error)

Service routes traffic to: ✅ Pod 1, ✅ Pod 2
(New pods never become Ready, so service ignores them)

Test hits Service → Gets routed to old healthy pods → ✅ Test passes!
```

**The problem**: Tests were hitting the OLD working version while the NEW version quietly crashed in the background!

### What We Could Detect

✅ **Business logic bugs** - Code runs but produces wrong results
✅ **API response errors** - Endpoints return 500 errors
✅ **Performance issues** - Slow responses

### What We Couldn't Detect

❌ **Startup crashes** - Pod exits before becoming Ready
❌ **Configuration errors** - Missing environment variables
❌ **Dependency failures** - Required services unavailable

## The Solution: Dual-URL Strategy

We added a **Commit URL** that routes directly to the new version, even if it's crashing.

### How It Works

#### PR URL Flow
```
User Request
    ↓
Kubernetes Service
    ↓
ReadinessProbe checks pods
    ↓
Routes ONLY to Ready pods
    ↓
✅ Old v1 pods (healthy)
❌ New v2 pods (not ready)
```

**Result**: Always get a working version

#### Commit URL Flow
```
Test Request
    ↓
Istio VirtualService
    ↓
DestinationRule: version=abc1234
    ↓
Routes to pods with that label
    ↓
✅ New v2 pods (even if crashing!)
```

**Result**: Test the EXACT code you pushed

## Implementing the Dual-URL Strategy

### Step 1: Label Pods with Version

In your deployment:

```yaml
spec:
  template:
    metadata:
      labels:
        app: todo-app
        version: abc1234  # Git commit SHA
```

### Step 2: Create DestinationRule

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: todo
spec:
  host: preview-todo-app
  subsets:
  - name: preview-abc1234
    labels:
      version: abc1234  # Match specific version
```

### Step 3: Create VirtualService with Two Routes

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: todo
spec:
  hosts:
  - todo-123-pr.example.com           # PR URL
  - todo-123-pr-abc1234.example.com   # Commit URL
  http:
  # PR URL: Route through KEDA (healthy pods only)
  - match:
    - authority:
        prefix: todo-123-pr.
    route:
    - destination:
        host: keda-interceptor
        
  # Commit URL: Route to specific version (even if crashing)
  - match:
    - authority:
        prefix: todo-123-pr-abc1234.
    route:
    - destination:
        host: preview-todo-app
        subset: preview-abc1234  # Specific version!
```

## Check Your Preview Environment Configuration

Let's examine how your preview environment implements this:

### View the DestinationRule

```bash
kubectl get destinationrule -n preview-PR_NUMBER-todo-app -o yaml
```{{copy}}

Look for the `subsets` section with version labels.

### View the VirtualService

```bash
kubectl get virtualservice -n preview-PR_NUMBER-todo-app -o yaml
```{{copy}}

Notice the two different routing rules for the two URLs.

### Check Pod Labels

```bash
kubectl get pods -n preview-PR_NUMBER-todo-app --show-labels
```{{copy}}

You'll see the `version` label with the commit SHA.

## Testing the Strategy

Let's simulate the bug scenario:

### Scenario 1: Healthy Deployment (Both URLs Work)

When your code is healthy:

**PR URL**:
```bash
curl -I http://localhost:30080
# Returns: 200 OK
```

**Commit URL** (specific version):
```bash
# In production, this would be a different hostname
# In NodePort setup, routing is via headers/paths
```

Both work because pods are healthy!

### Scenario 2: Crashing Deployment

If you push code with a startup crash:

**PR URL**:
- New pods crash and never become Ready
- Service routes to old healthy pods
- ✅ **Users still get service** (good!)
- ✅ **Tests pass** (BAD! Bug not caught!)

**Commit URL**:
- Routes directly to new version pods
- Attempts to hit crashing pods
- ❌ **Tests fail** (GOOD! Bug caught!)

## Practical CI/CD Integration

In your GitHub Actions workflow:

```yaml
steps:
  # Deploy preview environment
  - name: Deploy to preview
    run: |
      # ArgoCD deploys, generates both URLs
      PR_URL="http://todo-${PR_NUMBER}-pr.example.com"
      COMMIT_URL="http://todo-${PR_NUMBER}-pr-${COMMIT_SHA}.example.com"
      
  # Test against COMMIT URL (exact version)
  - name: Run integration tests
    run: |
      npm run test:integration -- --url=$COMMIT_URL
      
  # Smoke test against PR URL (user experience)
  - name: Smoke test
    run: |
      curl -f $PR_URL || exit 1
```

## Real-World Bug Examples

### Bug 1: Missing Environment Variable

```javascript
// This crashes on startup
const API_KEY = process.env.API_KEY.trim()
// If API_KEY is undefined → crash
```

- **PR URL**: Routes to old pods → Tests pass ❌
- **Commit URL**: Hits new pods → Tests fail ✅ **BUG CAUGHT!**

### Bug 2: Database Migration Failure

```javascript
// Migration runs on startup
await db.migrate()
// If migration fails → crash
```

- **PR URL**: Old pods still work → Tests pass ❌
- **Commit URL**: New pods crash → Tests fail ✅ **BUG CAUGHT!**

### Bug 3: Circular Dependency

```javascript
// Import cycle causes crash
import { A } from './a'
import { B } from './b'
// B imports A, A imports B → crash
```

- **PR URL**: Service routes away from crashes → Tests pass ❌
- **Commit URL**: Forced to hit new version → Tests fail ✅ **BUG CAUGHT!**

## Best Practices

### For Manual Testing
✅ Use **PR URL**
- Share with stakeholders
- Demo to product managers
- Manual QA testing
- Always shows working version

### For Automated Tests
✅ Use **Commit URL**
- Integration test suites
- End-to-end tests
- Security scans
- Performance tests
- Verifies EXACT deployed code

### For Monitoring
✅ Monitor **both URLs**
- PR URL: User experience metrics
- Commit URL: Deployment health checks
- Alert on Commit URL failures

## Cost-Benefit Analysis

### Benefits
✅ **Catch startup crashes** before production
✅ **Verify exact code** being deployed
✅ **Maintain user experience** (PR URL always works)
✅ **Fast feedback** on broken deployments

### Costs
⚠️ **Slightly more complex** setup (DestinationRule + VirtualService)
⚠️ **Two URLs to manage** in CI/CD pipelines
⚠️ **Learning curve** for team members

**Verdict**: The benefits FAR outweigh the costs! This pattern has saved us multiple production incidents.

## Key Takeaways

✅ **Two URLs solve different problems**:
   - PR URL: Human-friendly, always healthy
   - Commit URL: Test-specific, exact version

✅ **Rolling updates hide bugs** that crash on startup

✅ **Commit URL catches these bugs** before production

✅ **Use Istio DestinationRule** for version-specific routing

✅ **Label pods with commit SHA** for precise targeting

✅ **Route automated tests to Commit URL** for accuracy

This dual-URL strategy is a critical part of a robust preview environment system. It's caught countless bugs before they reached production!

Congratulations! You now understand the complete preview environment architecture. 🎉
