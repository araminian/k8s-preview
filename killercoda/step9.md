# Creating the ApplicationSet

Now let's configure ArgoCD to automatically create preview environments for each Pull Request!

## What is an ApplicationSet?

An ApplicationSet generates multiple ArgoCD Applications automatically using **generators**. Think of it as a template that creates Applications dynamically.

For preview environments, we use the **Pull Request generator** which:
- Watches your GitHub repository for Pull Requests
- Creates an Application for each PR with the `preview` label
- Automatically deletes the Application when the PR is closed/merged

## Create the ApplicationSet

Let's create the ApplicationSet that watches for Pull Requests in your forked repository.

**Important**: Make sure your forked repository is **public**. ArgoCD can read public repositories without authentication.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: todo-app-preview-environment
  namespace: argocd
spec:
  goTemplate: true
  syncPolicy:
    preserveResourcesOnDeletion: false
  generators:
  - pullRequest:
      github:
        owner: YOUR-GITHUB-USERNAME  # ⚠️ CHANGE THIS!
        repo: k8s-preview
        labels:
        - preview
      requeueAfterSeconds: 90
  template:
    metadata:
      name: todo-app-preview-{{.number}}
      labels:
        environment: preview
        app: todo-app
    spec:
      project: default
      source:
        repoURL: https://github.com/YOUR-GITHUB-USERNAME/k8s-preview.git  # ⚠️ CHANGE THIS!
        targetRevision: preview-{{.number}}
        path: .
        directory:
          include: '{*.yml,*.yaml}'
      destination:
        server: https://kubernetes.default.svc
        namespace: preview-{{.number}}-todo-app
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
EOF
```{{copy}}

**⚠️ IMPORTANT**: Replace `YOUR-GITHUB-USERNAME` with your actual GitHub username in **TWO places**:
1. Line with `owner:`
2. Line with `repoURL:`

**Note**: Since your repository is public, ArgoCD doesn't need authentication to read it. The Pull Request generator will poll GitHub's public API.

## Understanding the ApplicationSet

Let's break down what this does:

### Pull Request Generator

```yaml
generators:
- pullRequest:
    github:
      owner: YOUR-GITHUB-USERNAME
      repo: k8s-preview
      labels:
      - preview
    requeueAfterSeconds: 90
```

- **Watches**: Your GitHub repository for PRs
- **Filters**: Only PRs with the `preview` label
- **Polls**: Checks every 90 seconds for changes
- **Provides**: PR number, branch, head_sha, etc.

### Application Template

```yaml
template:
  metadata:
    name: todo-app-preview-{{.number}}
  spec:
    source:
      targetRevision: preview-{{.number}}
      path: .
    destination:
      namespace: preview-{{.number}}-todo-app
```

For PR #42, this creates:
- **Application name**: `todo-app-preview-42`
- **Source branch**: `preview-42`
- **Manifest path**: `manifests/preview/42/`
- **Namespace**: `preview-42-todo-app`

### Auto-Sync Policy

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
  syncOptions:
  - CreateNamespace=true
```

- **automated**: Deploy automatically (no manual sync needed)
- **prune**: Delete resources when removed from Git
- **selfHeal**: Restore resources if manually changed
- **CreateNamespace**: Auto-create the preview namespace

## Verify the ApplicationSet

Check that it was created successfully:

```bash
kubectl get applicationset -n argocd
```{{exec}}

You should see:
```
NAME                           AGE
todo-app-preview-environment   10s
```

View the details:

```bash
kubectl get applicationset todo-app-preview-environment -n argocd -o yaml
```{{exec}}

## How the Complete Workflow Works

```
1. Developer creates PR on GitHub
         ↓
2. GitHub Action runs (.github/workflows/ci-preview.yaml)
   - Builds Docker image
   - Pushes to Docker Hub
   - Renders manifests with Skaffold
   - Commits manifests to branch: preview-{PR_NUMBER}
   - Adds 'preview' label to PR
         ↓
3. ArgoCD ApplicationSet (polls every 90s)
   - Detects new PR with 'preview' label
   - Creates Application: todo-app-preview-{PR_NUMBER}
         ↓
4. ArgoCD Application
   - Pulls manifests from preview-{PR_NUMBER} branch
   - Creates namespace: preview-{PR_NUMBER}-todo-app
   - Deploys all resources (Deployment, Service, VirtualService, etc.)
         ↓
5. KEDA HTTP Add-on
   - Watches HTTPScaledObject
   - Scales deployment to zero after inactivity
         ↓
6. Developer/Tester accesses via URL
   - Traffic → Istio Gateway → KEDA Interceptor
   - KEDA scales up → Forwards traffic → Application
         ↓
7. PR merged/closed
   - ApplicationSet removes Application
   - ArgoCD deletes all resources
   - Namespace is cleaned up
```

## Access ArgoCD UI

Let's see the ApplicationSet in the ArgoCD UI:

[Open ArgoCD UI]({{TRAFFIC_HOST1_30081}})

Login with:
- **Username**: `admin`
- **Password**: Run this command to get it:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```{{exec}}

In the UI, you'll see the ApplicationSet listed. Once you create a PR in the next step, you'll see Applications appear automatically!

## Quick Check

Make sure you have:

- [ ] Verified your forked repository is **public**
- [ ] Created ApplicationSet with **your GitHub username** (in TWO places)
- [ ] Verified ApplicationSet exists in ArgoCD

Excellent! Now let's create a Pull Request and watch the magic happen!
