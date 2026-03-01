# Creating a Pull Request

Time for the exciting part - let's create a Pull Request and watch ArgoCD automatically deploy your preview environment!

## Make a Change to the Application

Let's modify the TODO application to see the changes in our preview environment.

### Option 1: Edit on GitHub (Easiest)

1. **Go to your fork** on GitHub:
   ```
   https://github.com/YOUR-USERNAME/k8s-preview
   ```

2. **Click "Create new branch"** button or go to:
   ```
   https://github.com/YOUR-USERNAME/k8s-preview/tree/main/src/components
   ```

3. **Click the branch dropdown** → Type `feature/add-greeting` → Click "Create branch"

4. **Navigate to** `src/components/Heading.jsx`

5. **Click the edit button** (pencil icon)

6. **Modify the component** to add a greeting:

```jsx
function Heading() {
    return (
        <div className="heading">
            <h1>Todo List</h1>
            <h2>Welcome to Preview Environment! 🚀</h2>
        </div>
    )
}

export default Heading
```{{copy}}

7. **Commit changes** directly to the `feature/add-greeting` branch

### Option 2: Edit Locally (If You Cloned)

```bash
# Create a new branch
git checkout -b feature/add-greeting

# Edit the file
vi src/components/Heading.jsx

# Make the same changes as above

# Commit and push
git add src/components/Heading.jsx
git commit -m "Add greeting to preview environment"
git push origin feature/add-greeting
```{{copy}}

## Create the Pull Request

1. **Go to your repository** on GitHub

2. **Click "Pull requests"** tab

3. **Click "New pull request"**

4. **Select branches**:
   - **base**: `main`
   - **compare**: `feature/add-greeting`

5. **Click "Create pull request"**

6. **Fill in the PR**:
   - **Title**: `Add greeting to TODO app`
   - **Description**: 
     ```
     ## Changes
     - Added a welcome message to the heading
     - This PR will create a preview environment
     
     ## Testing
     - Check that the greeting appears in the preview environment
     - Verify the TODO app still functions correctly
     ```

7. **Click "Create pull request"**

## Watch GitHub Actions Build the Image

After creating the PR, GitHub Actions will automatically trigger:

1. **Go to the "Actions" tab** in your repository

2. **Click on the running workflow** (it should say "CI Preview")

3. **Watch the workflow run**:
   - ✅ Build Docker image
   - ✅ Push to Docker Hub
   - ✅ Render Kubernetes manifests
   - ✅ Push manifests to `preview-{PR_NUMBER}` branch
   - ✅ Add `preview` label to PR

This usually takes **2-3 minutes**.

## Check the Preview Label

Once the GitHub Action completes:

1. **Go back to your Pull Request**

2. **Look at the labels** - you should see a `preview` label

3. **Check the comments** - the workflow adds a comment with:
   - PR URL (for testing)
   - Commit URL (for automated tests)

## Watch ArgoCD Deploy

Now let's watch ArgoCD automatically deploy the preview environment!

### Check in ArgoCD UI

[Open ArgoCD UI]({{TRAFFIC_HOST1_30081}})

1. **Wait up to 90 seconds** (ArgoCD polls every 90 seconds)

2. **You'll see a new Application** appear:
   ```
   todo-app-preview-{YOUR_PR_NUMBER}
   ```

3. **Click on the Application** to see:
   - Sync status
   - All deployed resources
   - Visual representation of your app

### Check via kubectl

You can also check from the command line:

```bash
# List all ArgoCD Applications
kubectl get application -n argocd
```{{exec}}

You should see your preview environment application!

```bash
# Check the preview namespace was created
kubectl get ns | grep preview
```{{exec}}

```bash
# Check pods in your preview namespace (replace PR_NUMBER)
kubectl get pods -n preview-PR_NUMBER-todo-app
```{{copy}}

## Understanding What Got Deployed

ArgoCD deployed all these resources:

### Namespace
```bash
kubectl get ns preview-PR_NUMBER-todo-app
```{{copy}}

### Deployment
```bash
kubectl get deployment -n preview-PR_NUMBER-todo-app
```{{copy}}

### Service
```bash
kubectl get svc -n preview-PR_NUMBER-todo-app
```{{copy}}

### VirtualService (Istio)
```bash
kubectl get virtualservice -n preview-PR_NUMBER-todo-app
```{{copy}}

### DestinationRule (Istio)
```bash
kubectl get destinationrule -n preview-PR_NUMBER-todo-app
```{{copy}}

### HTTPScaledObject (KEDA)
```bash
kubectl get httpscaledobject -n preview-PR_NUMBER-todo-app
```{{copy}}

## The Preview Branch

GitHub Actions created a branch with your manifests:

1. **Go to your repository** on GitHub

2. **Click the "branches" dropdown**

3. **You'll see**: `preview-{PR_NUMBER}`

4. **Click on it** to see the rendered manifests in `manifests/preview/{PR_NUMBER}/`

This is what ArgoCD is deploying from!

## Troubleshooting

### GitHub Action Failed?

Check the workflow logs:
- **Actions** tab → Click the failed workflow
- Common issues:
  - Docker Hub credentials incorrect
  - `skaffold.yaml` has wrong Docker Hub username
  - Network issues

### ApplicationSet Not Creating Application?

Check:
```bash
# View ApplicationSet status
kubectl describe applicationset todo-app-preview-environment -n argocd

# Check if PR has 'preview' label
# Check if GitHub token is valid
kubectl get secret github-token -n argocd
```

### Application Shows "OutOfSync"?

This is normal! Click "Sync" in the ArgoCD UI, or it will auto-sync shortly.

## Quick Check

You should now have:

- [ ] Created a Pull Request
- [ ] GitHub Action completed successfully
- [ ] PR has the `preview` label
- [ ] ArgoCD Application created (todo-app-preview-{PR_NUMBER})
- [ ] Resources deployed to preview namespace

Next, let's access and test your preview environment!
