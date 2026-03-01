# Creating the Istio Gateway

Now that Istio is installed, we need to create a Gateway resource that defines how external traffic enters our cluster.

## Understanding the Gateway

The Gateway is like the front door to your Kubernetes cluster. It:

- Listens on specific ports (80 for HTTP, 443 for HTTPS)
- Accepts traffic for specific hostnames
- Forwards traffic to VirtualServices

## Configure Istio Ingress Gateway NodePort

The Istio ingress gateway is already exposed as NodePort, but with random port assignments. Let's configure it to use port 30080 for HTTP traffic:

```bash
kubectl patch svc istio-ingressgateway -n istio-system -p '{
  "spec": {
    "ports": [
      {
        "name": "status-port",
        "port": 15021,
        "protocol": "TCP",
        "targetPort": 15021,
        "nodePort": 30021
      },
      {
        "name": "http2",
        "port": 80,
        "protocol": "TCP",
        "targetPort": 8080,
        "nodePort": 30080
      },
      {
        "name": "https",
        "port": 443,
        "protocol": "TCP",
        "targetPort": 8443,
        "nodePort": 30443
      }
    ]
  }
}'
```{{exec}}

Verify the NodePort configuration:

```bash
kubectl get svc istio-ingressgateway -n istio-system
```{{exec}}

You should see:
- Port 80 (HTTP) → NodePort 30080
- Port 443 (HTTPS) → NodePort 30443

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
    - "*"
EOF
```{{exec}}

**Note**: We're using `"*"` for hosts to accept all traffic, which is suitable for this tutorial environment.

## Verify the Gateway

Check that the Gateway was created:

```bash
kubectl get gateway -n istio-system
```{{exec}}

You should see `ingress-gateway` in the list.

## Understanding the Traffic Flow

```
Killercoda Traffic → NodePort 30080 → Istio Gateway → VirtualService → KEDA Interceptor → Application
```

The Gateway matches incoming traffic and forwards it to the appropriate VirtualService based on request path or headers.

## Test Gateway Connectivity

Let's verify the gateway is accessible:

```bash
curl -I http://localhost:30080
```{{exec}}

You should see a response from Istio (likely a 404, which is expected since we haven't deployed any apps yet).

## Next Steps

Now that we have our gateway configured and exposed, we can deploy preview environments! The Gateway will route traffic from NodePort 30080 to our applications.

Let's deploy our first preview environment in the next step!
