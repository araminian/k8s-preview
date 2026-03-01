# Installing KEDA and HTTP Add-on

KEDA (Kubernetes Event-Driven Autoscaling) is crucial for keeping our preview environments cost-effective by scaling them to zero when not in use.

## What is KEDA?

KEDA is an event-driven autoscaler that:

- Scales applications based on various metrics (HTTP requests, queue depth, etc.)
- Can scale to zero (unlike native HPA which only goes to 1)
- Uses custom metrics without requiring a complex setup
- Integrates seamlessly with Kubernetes

## What is the HTTP Add-on?

The KEDA HTTP Add-on:

- Acts as a proxy between incoming requests and your application
- Holds requests while scaling up from zero
- Forwards traffic once pods are ready
- Automatically scales down after inactivity

## Install KEDA

First, add the KEDA Helm repository:

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```{{exec}}

Now install KEDA:

```bash
helm install keda kedacore/keda \
  --namespace keda \
  --set resources.operator.limits.cpu=100m \
  --set resources.operator.limits.memory=128Mi \
  --set resources.operator.requests.cpu=10m \
  --set resources.operator.requests.memory=64Mi \
  --set resources.metricServer.limits.cpu=100m \
  --set resources.metricServer.limits.memory=128Mi \
  --set resources.metricServer.requests.cpu=10m \
  --set resources.metricServer.requests.memory=64Mi \
  --set resources.webhooks.limits.cpu=50m \
  --set resources.webhooks.limits.memory=64Mi \
  --set resources.webhooks.requests.cpu=10m \
  --set resources.webhooks.requests.memory=32Mi \
  --wait
```{{exec}}

## Install KEDA HTTP Add-on

Install the HTTP Add-on:

```bash
helm install http-add-on kedacore/keda-add-ons-http \
  --namespace keda-http-addon \
  --set operator.resources.limits.cpu=100m \
  --set operator.resources.limits.memory=128Mi \
  --set operator.resources.requests.cpu=10m \
  --set operator.resources.requests.memory=64Mi \
  --set interceptor.resources.limits.cpu=100m \
  --set interceptor.resources.limits.memory=128Mi \
  --set interceptor.resources.requests.cpu=10m \
  --set interceptor.resources.requests.memory=64Mi \
  --set scaler.resources.limits.cpu=100m \
  --set scaler.resources.limits.memory=128Mi \
  --set scaler.resources.requests.cpu=10m \
  --set scaler.resources.requests.memory=64Mi \
  --wait
```{{exec}}

## Verify KEDA Installation

Check that KEDA components are running:

```bash
kubectl get pods -n keda
```{{exec}}

You should see:
- keda-operator
- keda-metrics-apiserver

## Verify HTTP Add-on Installation

Check the HTTP Add-on components:

```bash
kubectl get pods -n keda-http-addon
```{{exec}}

You should see:
- keda-add-ons-http-interceptor-proxy
- keda-add-ons-http-controller-manager

## Understanding HTTPScaledObject

The HTTP Add-on uses a custom resource called `HTTPScaledObject`. Here's what it looks like:

```yaml
apiVersion: http.keda.sh/v1alpha1
kind: HTTPScaledObject
metadata:
  name: preview-todo-app
spec:
  hosts:
    - todo-123-pr.example.com
  replicas:
    min: 0  # Scale to zero!
    max: 2
  scaleTargetRef:
    deployment: preview-todo-app
    service: preview-todo-app
    port: 80
  scaledownPeriod: 300  # 5 minutes of inactivity
```

This tells KEDA:
- Which hostname to monitor
- What deployment to scale
- How long to wait before scaling down

## How It Works

```
User Request → Istio Gateway → KEDA Interceptor Proxy
                                    ↓
                              Is deployment scaled to 0?
                                    ↓
                    Yes: Hold request, scale up, then forward
                    No: Forward immediately
                                    ↓
                              Application Pod
```

Perfect! KEDA is now ready to manage our auto-scaling. Let's set up Istio next.
