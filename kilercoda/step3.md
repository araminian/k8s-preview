# Installing ArgoCD

ArgoCD is the heart of our GitOps setup. It watches Git repositories and automatically deploys changes to Kubernetes.

## What is ArgoCD?

ArgoCD is a declarative GitOps continuous delivery tool for Kubernetes. It:

- Monitors Git repositories for changes
- Compares desired state (Git) with actual state (Kubernetes)
- Automatically syncs applications
- Provides a beautiful web UI for visualization

## Install ArgoCD

Let's install ArgoCD using the official manifests:

```bash
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```{{exec}}

## Wait for ArgoCD to Be Ready

This may take a minute or two. Let's watch the pods come up:

```bash
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```{{exec}}

## Access ArgoCD UI

Get the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```{{exec}}

**Note**: Save this password! You'll use it to log in to the ArgoCD UI.

## Port Forward ArgoCD (Optional)

If you want to access the ArgoCD UI, you can port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```{{exec}}

The UI will be available at `https://localhost:8080` (username: `admin`, password: from the command above).

## Verify ArgoCD Installation

Check that all ArgoCD components are running:

```bash
kubectl get pods -n argocd
```{{exec}}

You should see several pods in a Running state:
- argocd-application-controller
- argocd-repo-server
- argocd-server
- argocd-dex-server
- argocd-redis

## What's an ApplicationSet?

In the next steps, we'll create an **ApplicationSet**, which is a powerful ArgoCD feature that:

- Generates multiple Applications from a single template
- Supports various generators (Git, PR, cluster, etc.)
- Automatically creates/deletes Applications based on criteria
- Perfect for preview environments!

Great! ArgoCD is now ready. Let's move on to installing KEDA.
