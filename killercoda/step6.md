# Creating the Istio Gateway

Now that Istio is installed, we need to create a Gateway resource that defines how external traffic enters our cluster.

## Understanding the Gateway

The Gateway is like the front door to your Kubernetes cluster. It:

- Listens on specific ports (80 for HTTP, 443 for HTTPS)
- Accepts traffic for specific hostnames
- Forwards traffic to VirtualServices

## Expose Istio Ingress Gateway via NodePort

To access services in Killercoda, we need to expose the Istio Ingress Gateway using a NodePort:

```bash
kubectl patch svc istio-ingressgateway -n istio-system --type='json' -p='[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"add","path":"/spec/ports/0/nodePort","value":30080}]'
```{{exec}}

Verify the NodePort is set:

```bash
kubectl get svc istio-ingressgateway -n istio-system
```{{exec}}

You should see the service type changed to `NodePort` with port `30080`.

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
