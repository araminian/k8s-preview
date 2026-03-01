# Creating the Istio Gateway

Now that Istio is installed, we need to create a Gateway resource that defines how external traffic enters our cluster.

## Understanding the Gateway

The Gateway is like the front door to your Kubernetes cluster. It:

- Listens on specific ports (80 for HTTP, 443 for HTTPS)
- Accepts traffic for specific hostnames
- Forwards traffic to VirtualServices

## Create the Gateway

Let's create a Gateway that accepts traffic for all our preview environments:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ingress-gateway
  namespace: istio-system
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
EOF
```{{exec}}

## What is sslip.io?

`sslip.io` is a magic DNS service that resolves:
- `127.0.0.1.sslip.io` → `127.0.0.1`
- `todo-123-pr.127.0.0.1.sslip.io` → `127.0.0.1`
- `anything.10.0.0.1.sslip.io` → `10.0.0.1`

This lets us use real hostnames without setting up DNS!

## Verify the Gateway

Check that the Gateway was created:

```bash
kubectl get gateway -n istio-system
```{{exec}}

You should see `ingress-gateway` in the list.

## Understanding the Traffic Flow

```
External Request → Istio Gateway → VirtualService → KEDA Interceptor → Application
```

The Gateway matches incoming traffic by hostname and forwards it to the appropriate VirtualService.

## Get the Gateway IP

For local testing, we need the ingress gateway's external IP:

```bash
kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```{{exec}}

**Note**: In a real cloud environment, this would be an actual Load Balancer IP. In this tutorial environment, it might show as pending or use a local IP.

## Next Steps

Now that we have our gateway configured, we can deploy preview environments! The Gateway will route traffic based on hostnames like:

- `todo-123-pr.127.0.0.1.sslip.io` (PR URL - routes through KEDA)
- `todo-123-pr-abc1234.127.0.0.1.sslip.io` (Commit URL - direct routing)

Let's deploy our first preview environment in the next step!
