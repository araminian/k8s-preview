# Setting Up Istio

Istio is our service mesh and ingress controller. It provides sophisticated traffic management capabilities that are perfect for routing to preview environments.

## What is Istio?

Istio is a service mesh that provides:

- **Traffic Management**: Advanced routing, load balancing, and traffic splitting
- **Observability**: Metrics, logs, and distributed tracing
- **Security**: mTLS, authentication, and authorization
- **Ingress Gateway**: Entry point for external traffic

## Install Istio

We'll use the minimal profile for this tutorial:

```bash
curl -L https://istio.io/downloadIstio | sh -
```{{exec}}

Move to the Istio directory and add it to PATH:

```bash
cd istio-*
export PATH=$PWD/bin:$PATH
cd /root/demo
```{{exec}}

Install Istio with the default profile:

```bash
istioctl install --set profile=default -y
```{{exec}}

## Verify Istio Installation

Check that Istio components are running:

```bash
kubectl get pods -n istio-system
```{{exec}}

You should see:
- istiod (Istio control plane)
- istio-ingressgateway (handles incoming traffic)

## Understanding Istio Components

### Gateway
Defines how external traffic enters the mesh:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ingress-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*.sslip.io"
```

### VirtualService
Routes traffic to services based on rules:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: todo-preview
spec:
  hosts:
  - "todo-123-pr.127.0.0.1.sslip.io"
  gateways:
  - ingress-gateway
  http:
  - route:
    - destination:
        host: keda-add-ons-http-interceptor-proxy.keda-http-addon
```

### DestinationRule
Defines subsets for version-specific routing:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: todo-preview
spec:
  host: preview-todo-app
  subsets:
  - name: preview-abc123
    labels:
      version: abc123
```

## Why Istio for Preview Environments?

1. **Dynamic Routing**: Route traffic based on hostname, headers, or paths
2. **Version-Specific Routing**: Direct traffic to specific commit versions
3. **Traffic Splitting**: A/B testing capabilities (bonus feature!)
4. **Observability**: Built-in metrics and tracing

## Check Ingress Gateway Service

Get the ingress gateway service details:

```bash
kubectl get svc istio-ingressgateway -n istio-system
```{{exec}}

Note the type (LoadBalancer) and ports. In the next step, we'll create a Gateway resource.

Excellent! Istio is now ready to route traffic to our preview environments.
