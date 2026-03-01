# Creating the ApplicationSet

Now for the final piece: automating preview environment creation with ArgoCD ApplicationSets!

## What is an ApplicationSet?

An ApplicationSet is like a template that generates multiple ArgoCD Applications automatically. It:

- Uses **generators** to determine what Applications to create
- Supports various generator types: Git, PR, Cluster, List, etc.
- Automatically creates/updates/deletes Applications
- Perfect for dynamic environments like preview environments!

## The Pull Request Generator

The PR generator watches GitHub PRs and creates an Application for each:

```yaml
generators:
- pullRequest:
    github:
      owner: araminian
      repo: k8s-preview
      labels:
      - preview  # Only PRs with this label
    requeueAfterSeconds: 90  # Check every 90s
```

## Create the ApplicationSet

Let's examine the ApplicationSet manifest:

```bash
cat /root/demo/kubernetes/argocd/applicationSet.yaml
```{{exec}}

Key sections:

1. **Generator**: Watches PRs with `preview` label
2. **Template**: Defines how to create each Application
3. **Source**: Points to the temporary branch `preview-{{.number}}`
4. **Sync Policy**: Automatically removes Application when PR closes

## Apply the ApplicationSet

Before applying, we need to create a GitHub token for ArgoCD to access the repository. For this tutorial, we'll use a template configuration:

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
  - list:
      elements:
      - number: "123"
        branch: preview-123
        head_sha: 827f6a4
  template:
    metadata:
      name: todo-app-preview-{{.number}}
      labels:
        environment: preview
        app: todo-app
    spec:
      project: default
      source:
        repoURL: https://github.com/araminian/k8s-preview.git
        targetRevision: {{.branch}}
        path: manifests/preview/{{.number}}
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
```{{exec}}

**Note**: In production, you'd use the `pullRequest` generator with proper GitHub credentials. For this tutorial, we're using a `list` generator with a simulated PR.

## Verify the ApplicationSet

Check that it was created:

```bash
kubectl get applicationset -n argocd
```{{exec}}

## Watch Applications Being Created

The ApplicationSet will generate Application resources:

```bash
kubectl get application -n argocd
```{{exec}}

You should see `todo-app-preview-123`!

## Check Application Details

View the generated Application:

```bash
kubectl get application todo-app-preview-123 -n argocd -o yaml
```{{exec}}

Notice:
- Source points to the preview branch
- Destination creates a unique namespace
- Auto-sync is enabled

## Understanding the Workflow

```
1. Developer creates PR
   ↓
2. GitHub Action adds "preview" label
   ↓
3. GitHub Action builds & pushes image
   ↓
4. GitHub Action renders manifests → preview-123 branch
   ↓
5. ApplicationSet detects new PR
   ↓
6. Creates Application for PR #123
   ↓
7. ArgoCD syncs manifests from preview-123 branch
   ↓
8. Preview environment deployed!
   ↓
9. PR merged/closed → Application deleted
   ↓
10. Preview environment cleaned up!
```

## Access ArgoCD UI

Let's see this in the ArgoCD UI. Open it here:

[Open ArgoCD UI]({{TRAFFIC_HOST1_30081}})

Get the password if you need it again:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```{{exec}}

Log in with:
- Username: `admin`
- Password: (from above)

You'll see the `todo-app-preview-123` application! Click on it to explore:
- The sync status
- The resources deployed
- The health of each component
- A visual representation of the architecture

## Benefits of ApplicationSet

1. **No manual Application creation** - Automatic for every PR
2. **Automatic cleanup** - Applications deleted when PR closes
3. **Consistent configuration** - All preview environments use same template
4. **GitOps compliance** - Everything in Git, nothing manual

## Cleanup Behavior

When a PR is closed:
- ApplicationSet removes the Application
- ArgoCD deletes all resources in the namespace
- No manual cleanup needed!

Perfect! You now understand how to fully automate preview environments with ArgoCD ApplicationSets!
