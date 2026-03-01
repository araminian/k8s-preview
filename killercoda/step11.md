# Testing the Preview Environment

Your preview environment is deployed! Let's test it and experience KEDA's auto-scaling in action.

**Note**: In Killercoda, you'll test using `curl` from the terminal. For the full browser-based experience with proper DNS and external access, check out the complete tutorial in the repository for running on a local cluster (Minikube/kind).

## Understanding Your Preview URLs

Your preview environment has two URLs (replace `PR_NUMBER` with your actual PR number, e.g., 1, 2, 3):

### PR URL
```
http://todo-PR_NUMBER-pr.127.0.0.1.sslip.io:30080
```
- Routes through KEDA HTTP Interceptor
- Points to healthy pods only
- Great for demos and manual testing

### Commit URL
```
http://todo-PR_NUMBER-pr-COMMIT_SHA.127.0.0.1.sslip.io:30080
```
- Routes to specific commit version
- Used for automated testing
- Ensures tests hit exact deployed code

## Check Initial Pod State

First, let's see if pods are running or scaled to zero:

```bash
# Replace PR_NUMBER with your actual PR number (e.g., 1, 2, 3)
kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

You might see:
- **No resources found** → KEDA has scaled to zero! ✅
- **1 pod Running** → App is currently active
- **Pod ContainerCreating** → Currently scaling up

## Test the PR URL and Watch Scale-Up from Zero!

This is where the magic happens! Let's trigger KEDA to scale from zero:

```bash
# Replace PR_NUMBER with your actual PR number
curl -i http://todo-PR_NUMBER-pr.127.0.0.1.sslip.io:30080
```{{copy}}

### What's Happening (Cold Start)

If the deployment was at zero replicas:

1. **KEDA Interceptor receives your request**
2. **Holds the request** (you'll see a delay - this is normal!)
3. **Scales deployment from 0 → 1**
4. **Waits for pod to be Ready** (~15-30 seconds)
5. **Forwards your request** to the pod
6. **Returns the response!**

Watch the magic happen in another terminal:

```bash
# Watch pods scale up in real-time
watch kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

You'll see:
```
NAME                               READY   STATUS
preview-todo-app-xxxxx-yyy         0/2     ContainerCreating
preview-todo-app-xxxxx-yyy         2/2     Running
```

Press `Ctrl+C` to stop watching.

## Test the Commit URL

Now test the commit-specific URL (check your VirtualService for the exact commit SHA):

```bash
# Get the commit SHA from the VirtualService
kubectl get virtualservice -n preview-PR_NUMBER-todo-app -o jsonpath='{.spec.hosts[1]}' && echo
```{{exec}}

```bash
# Test the commit URL (replace COMMIT_SHA with actual value)
curl -i http://todo-PR_NUMBER-pr-COMMIT_SHA.127.0.0.1.sslip.io:30080
```{{copy}}

This URL routes directly to your specific commit version, bypassing the service's health checks - crucial for automated testing!

## Verify the Application is Working

Let's check the HTML response:

```bash
curl -s http://todo-PR_NUMBER-pr.127.0.0.1.sslip.io:30080 | grep -i "welcome"
```{{copy}}

You should see your greeting message: **"Welcome to Preview Environment! 🚀"**

## Experience Scale-to-Zero

Now let's watch KEDA scale back down:

### Option 1: Wait for Natural Scale-Down

```bash
# KEDA will scale down after 5 minutes of inactivity
# Watch it happen (this takes ~5 minutes)
watch kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

### Option 2: Force Scale-Down (Faster Demo)

```bash
# Manually scale to zero to see the behavior faster
kubectl scale deployment preview-todo-app -n preview-PR_NUMBER-todo-app --replicas=0
```{{copy}}

Verify it's at zero:

```bash
kubectl get pods -n preview-PR_NUMBER-todo-app
# Output: No resources found in preview-PR_NUMBER-todo-app namespace.
```{{exec}}

### Test Scale-Up Again

```bash
# Send another request - watch KEDA scale back up!
time curl -i http://todo-PR_NUMBER-pr.127.0.0.1.sslip.io:30080
```{{exec}}

The `time` command shows how long the cold start takes (~15-30 seconds).

## Want the Full Experience?

**🖥️ For browser access and the complete experience**:

This Killercoda environment is great for learning the architecture, but for the full experience with:
- Browser-based testing
- Proper DNS resolution  
- External access to preview environments
- Full dual-URL strategy testing

Check out the **complete tutorial in the repository README** for running on a local cluster (Minikube or kind). You'll get the same setup with full browser access!

Repository: https://github.com/araminian/k8s-preview

## Check the Deployment Details

Let's examine what was deployed:

### View Deployment and Image

```bash
kubectl get deployment -n preview-PR_NUMBER-todo-app -o yaml | grep -A 3 "image:"
```{{copy}}

You'll see your Docker Hub image with the PR tag!

### View VirtualService and URLs

```bash
kubectl get virtualservice -n preview-PR_NUMBER-todo-app -o yaml | grep -A 5 "hosts:"
```{{copy}}

Notice the two hosts (PR URL and Commit URL) with different routing rules.

### View HTTPScaledObject Configuration

```bash
kubectl get httpscaledobject -n preview-PR_NUMBER-todo-app -o yaml | grep -A 10 "replicas:"
```{{copy}}

See the `min: 0` and `max: 2` replica configuration that enables scale-to-zero.

## Make Another Change and Test Auto-Deployment

Want to see the preview environment update automatically? Make another commit!

### Quick Change Example

1. **Edit** `src/components/Heading.jsx` again on GitHub

2. **Change the greeting** to something else:
   ```jsx
   <h2>Testing Auto-Deployment! ✨</h2>
   ```

3. **Commit** to the same branch

4. **Watch the automated workflow**:
   - GitHub Actions rebuilds (~2-3 minutes)
   - New manifests pushed to preview branch
   - ArgoCD detects change and syncs (up to 90 seconds)
   - New version deployed!

5. **Test the update**:
   ```bash
   # The deployment might scale to zero between updates
   curl -s http://todo-PR_NUMBER-pr.127.0.0.1.sslip.io:30080 | grep -i "testing"
   ```

You should see your new message!

Check ArgoCD UI to see the sync happening:

[Open ArgoCD UI]({{TRAFFIC_HOST1_30081}})

## View Deployment History in ArgoCD

In the ArgoCD UI:

1. **Click your Application** (todo-app-preview-{PR_NUMBER})

2. **Click "History and Rollback"** tab

3. **See all deployments** with:
   - Commit SHAs
   - Timestamps
   - Who triggered it
   - Ability to rollback!

This is the power of GitOps!

## Additional Testing Scenarios

Try these experiments to understand the system better:

### Test KEDA Response Time

```bash
# Scale to zero first
kubectl scale deployment preview-todo-app -n preview-PR_NUMBER-todo-app --replicas=0

# Time the cold start
time curl -s http://todo-PR_NUMBER-pr.127.0.0.1.sslip.io:30080 > /dev/null

# Try again (warm - should be instant)
time curl -s http://todo-PR_NUMBER-pr.127.0.0.1.sslip.io:30080 > /dev/null
```{{copy}}

Compare cold start (~15-30s) vs warm request (~0.1s)!

### Monitor KEDA Interceptor Logs

```bash
kubectl logs -n keda-http-addon -l app.kubernetes.io/name=keda-add-ons-http-interceptor --tail=20 --follow
```{{copy}}

Watch KEDA handle requests and scaling decisions. Press `Ctrl+C` to stop.

### Resource Inspection

```bash
# See all resources in preview namespace
kubectl get all -n preview-PR_NUMBER-todo-app

# Check HTTPScaledObject status
kubectl describe httpscaledobject -n preview-PR_NUMBER-todo-app | grep -A 10 "Status:"

# View pod logs (if running)
kubectl logs -n preview-PR_NUMBER-todo-app -l app=todo-app --tail=50
```{{copy}}

## Troubleshooting

### Can't Access via curl?

**Check pods are running:**
```bash
kubectl get pods -n preview-PR_NUMBER-todo-app
```

**If "No resources found"**: This is normal! Send a curl request and wait ~20 seconds for scale-up.

**Check Istio Gateway:**
```bash
kubectl get gateway -n istio-system
kubectl get virtualservice -n preview-PR_NUMBER-todo-app
```

**Check KEDA HTTP Add-on:**
```bash
kubectl get pods -n keda-http-addon
kubectl logs -n keda-http-addon -l app.kubernetes.io/name=keda-add-ons-http-interceptor --tail=50
```

### Connection Refused or Timeout?

**Verify NodePort is accessible:**
```bash
kubectl get svc istio-ingressgateway -n istio-system | grep 30080
```

**Check if Istio is routing correctly:**
```bash
curl -I http://localhost:30080
# Should return Istio response (404 or 200)
```

### Application Not Working?

**Check ArgoCD sync status:**
```bash
kubectl get application -n argocd
kubectl describe application todo-app-preview-PR_NUMBER -n argocd | grep -A 10 "Status:"
```

**Force sync if needed:**
```bash
# Via kubectl
kubectl patch application todo-app-preview-PR_NUMBER -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'
```

Or use the ArgoCD UI: [Open ArgoCD]({{TRAFFIC_HOST1_30081}})

## Summary

You should now have successfully:

- ✅ Tested your preview environment via curl
- ✅ Experienced KEDA scale-from-zero (cold start)
- ✅ Verified your code changes are deployed
- ✅ Tested both PR URL and Commit URL
- ✅ Understood the scale-to-zero cost savings
- ✅ (Optional) Made additional commits and seen auto-deployment

**Next Steps**: Continue to step 12 to dive deeper into KEDA's auto-scaling behavior and cost savings calculations!
