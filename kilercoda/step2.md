# Setting Up the Kubernetes Cluster

In this step, we'll prepare our Kubernetes cluster and understand the demo application.

## The Demo Application

We're using a simple TODO application built with React. The application includes:

- A frontend built with Vite and React
- A Dockerfile for containerization
- A Helm chart for Kubernetes deployment

Let's explore the project structure:

```bash
cd /root/demo
ls -la
```{{exec}}

## Understanding the Helm Chart

The Helm chart is located in `kubernetes/charts/todo-app/`. Let's examine it:

```bash
tree kubernetes/charts/todo-app/
```{{exec}}

The chart includes templates for:
- **Namespace**: Creates a unique namespace per preview environment
- **Deployment**: Runs the application pods
- **Service**: Exposes the deployment internally
- **VirtualService**: Istio routing configuration
- **DestinationRule**: Traffic routing rules for specific versions
- **HTTPScaledObject**: KEDA configuration for auto-scaling

## Key Configuration Files

Let's look at the preview environment values:

```bash
cat kubernetes/deployment-values/preview/values.yaml
```{{exec}}

Notice how we use placeholders like `{{.SKAFFOLD_IMAGE}}` and `{{.PR_NUMBER}}` that will be replaced dynamically.

## Understanding Skaffold

Skaffold helps us build and render manifests. Check the configuration:

```bash
cat skaffold.yaml
```{{exec}}

Skaffold will:
1. Build the Docker image with the correct tags
2. Render the Helm chart with dynamic values
3. Output manifests ready for deployment

## Verify Cluster Resources

Let's ensure all prerequisite namespaces exist:

```bash
kubectl get ns argocd keda keda-http-addon istio-system
```{{exec}}

Perfect! Your cluster is ready for the next steps.
