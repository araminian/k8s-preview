# Testing the Preview Environment

Your preview environment is deployed! Let's access it and see your changes in action.

## Get Your Preview Environment URL

The GitHub Actions workflow added a comment to your PR with the URLs. Let's find them:

1. **Go to your Pull Request** on GitHub

2. **Scroll down to the comments**

3. **Look for the bot comment** that shows:
   ```
   Preview Environment URLs:
   - PR URL: http://todo-{PR_NUMBER}-pr.{IP}.sslip.io
   - Commit URL: http://todo-{PR_NUMBER}-pr-{SHA}.{IP}.sslip.io
   ```

**Note**: In this tutorial environment, we'll access via NodePort instead since we're using Killercoda.

## Check if Pods are Running

First, let's verify the preview environment pods are running:

```bash
# Replace PR_NUMBER with your actual PR number (e.g., 1, 2, 3...)
kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

You might see:
- **No resources found** - KEDA has scaled to zero (expected!)
- **1 pod Running** - The app is running
- **Pod ContainerCreating** - It's starting up

## Access the Preview Environment

We'll access the app through the Istio Gateway on NodePort 30080:

[Open Preview Environment]({{TRAFFIC_HOST1_30080}})

Or use curl:

```bash
curl -I http://localhost:30080
```{{exec}}

## Watch KEDA Scale Up (If Scaled to Zero)

If the deployment was scaled to zero, here's what happens when you access it:

1. **KEDA Interceptor receives your request**
2. **Holds the request** (you'll see "waiting...")
3. **Scales the deployment to 1 replica**
4. **Waits for pod to be ready**
5. **Forwards your request** to the pod
6. **You see the application!**

This is called a "cold start" and takes 10-30 seconds.

Watch the pods scale up in real-time:

```bash
# Replace PR_NUMBER with your PR number
watch kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

Press `Ctrl+C` to stop watching.

## Test the Application

Once the app loads, you should see:

✅ **TODO List** heading
✅ **"Welcome to Preview Environment! 🚀"** greeting (your change!)
✅ Ability to add TODO items
✅ Ability to mark items as complete
✅ Ability to delete items

Try it out:
1. Add a few TODO items
2. Mark some as complete
3. Delete some items
4. Verify everything works!

## Understanding the URLs

### PR URL (For Humans)

```
http://todo-{PR_NUMBER}-pr.{IP}.sslip.io
```

- Routes through **KEDA HTTP Interceptor**
- Always points to **healthy, ready pods**
- If new deploy crashes, old version keeps running
- **Use this** for manual testing and demos

In our NodePort setup, all traffic goes through port 30080.

### Commit URL (For Automated Tests)

```
http://todo-{PR_NUMBER}-pr-{COMMIT_SHA}.{IP}.sslip.io
```

- Routes **directly to specific commit version**
- Uses Istio DestinationRule with version labels
- Even if pods are crashing, tests hit them
- **Use this** for automated integration tests

This ensures tests verify the *exact* code you pushed!

## Check the Deployment Details

Let's examine what was deployed:

### View Deployment

```bash
kubectl get deployment -n preview-PR_NUMBER-todo-app -o yaml | grep -A 5 "image:"
```{{copy}}

You'll see your Docker Hub image with the PR tag!

### View VirtualService

```bash
kubectl get virtualservice -n preview-PR_NUMBER-todo-app -o yaml
```{{copy}}

Notice the two hosts (PR URL and Commit URL) routing differently.

### View HTTPScaledObject

```bash
kubectl get httpscaledobject -n preview-PR_NUMBER-todo-app -o yaml
```{{copy}}

See the `min: 0` and `max: 2` replica configuration.

## Make Another Change

Want to see the preview environment update? Make another commit to your PR branch!

### Quick Change Example

1. **Edit** `src/components/Heading.jsx` again on GitHub

2. **Change the greeting** to something else:
   ```jsx
   <h2>Testing Auto-Deployment! ✨</h2>
   ```

3. **Commit** to the same branch

4. **Watch**:
   - GitHub Actions rebuilds
   - New manifests pushed to preview branch
   - ArgoCD detects change and syncs
   - New version deployed!

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

## Test Different Scenarios

Try these experiments:

### Scenario 1: Scale to Zero

1. **Stop accessing the app** for 5 minutes
2. **Watch pods scale down**:
   ```bash
   watch kubectl get pods -n preview-PR_NUMBER-todo-app
   ```
3. **Access again** and watch scale up

### Scenario 2: Multiple Commits

1. **Push several commits** to your PR
2. **Watch ArgoCD** auto-sync each one
3. **See deployment history** in ArgoCD UI

### Scenario 3: Resource Inspection

```bash
# See all resources in preview namespace
kubectl get all -n preview-PR_NUMBER-todo-app

# Describe the HTTPScaledObject
kubectl describe httpscaledobject -n preview-PR_NUMBER-todo-app

# View pod logs
kubectl logs -n preview-PR_NUMBER-todo-app -l app=todo-app --tail=50
```{{copy}}

## Troubleshooting

### Can't Access the App?

**Check pods are running:**
```bash
kubectl get pods -n preview-PR_NUMBER-todo-app
```

**Check Istio Gateway:**
```bash
kubectl get gateway -n istio-system
kubectl get virtualservice -n preview-PR_NUMBER-todo-app
```

**Check KEDA Interceptor logs:**
```bash
kubectl logs -n keda-http-addon -l app.kubernetes.io/name=keda-add-ons-http-interceptor --tail=50
```

### App Showing Old Version?

**Force ArgoCD to sync:**
```bash
kubectl patch application todo-app-preview-PR_NUMBER -n argocd \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

Or click "Sync" in the ArgoCD UI.

### Pods Crashing?

**Check logs:**
```bash
kubectl logs -n preview-PR_NUMBER-todo-app -l app=todo-app --tail=100
```

**Check events:**
```bash
kubectl get events -n preview-PR_NUMBER-todo-app --sort-by='.lastTimestamp'
```

## Quick Check

You should now have:

- [ ] Accessed your preview environment
- [ ] Seen your changes (the greeting message)
- [ ] Tested the TODO app functionality
- [ ] Understood PR URL vs Commit URL
- [ ] (Optional) Made additional commits and saw auto-deployment

Excellent! In the next step, we'll dive deeper into how KEDA auto-scaling works.
