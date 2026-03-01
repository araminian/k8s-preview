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

## Configure ArgoCD for Insecure Access

For this tutorial environment, we need to configure ArgoCD to run without TLS (insecure mode) to avoid redirect loops.

First, let's add the insecure flag using kubectl set:

```bash
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
```{{exec}}

Now restart the ArgoCD server to apply the changes:

```bash
kubectl rollout restart deployment argocd-server -n argocd
```{{exec}}

Wait for the ArgoCD server to be ready:

```bash
kubectl rollout status deployment/argocd-server -n argocd --timeout=120s
```{{exec}}

## Expose ArgoCD UI via NodePort

Now let's expose ArgoCD server via NodePort for easy access:

```bash
kubectl patch svc argocd-server -n argocd --type='json' -p='[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"add","path":"/spec/ports/0/nodePort","value":30081}]'
```{{exec}}

## Get Admin Password

Get the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```{{exec}}

**Note**: Save this password! You'll use it to log in to the ArgoCD UI.

## Access ArgoCD UI

Now you can access the ArgoCD UI via HTTP:

[Open ArgoCD UI]({{TRAFFIC_HOST1_30081}})

Login with:
- Username: `admin`
- Password: (from the command above)

**Note**: We're using HTTP (insecure mode) which is fine for this tutorial environment. In production, you should always use HTTPS with proper TLS certificates.

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
