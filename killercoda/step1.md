# Understanding Preview Environments

## What Are Preview Environments?

Preview environments are temporary, isolated Kubernetes environments that are automatically created for each Pull Request. They allow developers and testers to:

- View changes in a real environment before merging
- Run integration tests against actual deployments
- Share a live URL with team members for review
- Catch bugs that only appear in deployed environments

## The Challenge

The main challenges with preview environments are:

1. **Cost**: Running hundreds of preview environments 24/7 is expensive
2. **Cleanup**: Manual deletion is error-prone
3. **Uniqueness**: Each PR needs its own namespace and URL
4. **Automation**: Everything should happen automatically via GitOps

## Our Solution

We'll solve these challenges using:

- **ArgoCD ApplicationSet**: Dynamically creates applications for each PR
- **KEDA HTTP Add-on**: Scales deployments to zero when idle
- **Istio**: Routes traffic and provides unique URLs
- **GitHub Actions**: Builds images and renders manifests

## The Workflow

```
Developer pushes code → GitHub Actions builds image 
→ Manifests rendered to temp branch → ArgoCD deploys 
→ KEDA manages scaling → Preview environment ready!
```

## Let's Verify Your Cluster

Check that your Kubernetes cluster is running:

```bash
kubectl get nodes
```{{exec}}

You should see your cluster nodes in a Ready state.

Now let's check the namespaces we've created:

```bash
kubectl get namespaces
```{{exec}}

You should see namespaces for `argocd`, `keda`, `keda-http-addon`, and `istio-system`.

Great! Now let's move to the next step where we'll set up our Kubernetes cluster components.
