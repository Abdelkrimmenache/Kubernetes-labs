# Lab 2 — Kubernetes Services and Internal Networking

## Objective

Understand how Kubernetes Services provide a stable network endpoint for Pods and how applications can communicate through Kubernetes DNS.

## Prerequisites

The `nginx-lab` Deployment created in Lab 1 must exist and have at least one ready Pod.

## 1. Inspect Existing Services

```bash
kubectl get services
```

Example output:

```text
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP
nginx-service   ClusterIP   10.106.43.207   <none>        80/TCP
```

The `kubernetes` Service is created by Kubernetes itself and provides access to the Kubernetes API server from within the cluster.

The `nginx-service` Service was created during this lab.

## 2. Expose the Deployment

```bash
kubectl expose deployment nginx-lab \
  --name=nginx-service \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP
```

### Explanation

- `expose deployment nginx-lab`: creates a Service targeting the Deployment's Pods.
- `--name=nginx-service`: sets the Service name.
- `--port=80`: exposes port 80 on the Service.
- `--target-port=80`: forwards traffic to port 80 on the selected Pods.
- `--type=ClusterIP`: creates an internal Service accessible from within the cluster.

**Note:** Run this creation command only once. If the Service already exists, inspect it instead of creating it again.

## 3. Inspect the Service

```bash
kubectl describe service nginx-service
```

Inspect the following fields:

- `Type`: should be `ClusterIP`.
- `IP`: the Service's internal cluster IP.
- `Selector`: labels used to identify backend Pods.
- `Port`: port exposed by the Service.
- `TargetPort`: port receiving traffic on the selected Pods.
- `Endpoints`: backend Pod IP addresses and ports.

The Service provides a stable endpoint even when individual Pods are replaced and their IP addresses change.

## 4. Test Access Through Kubernetes DNS

```bash
kubectl run curl-test \
  --image=curlimages/curl:latest \
  --restart=Never \
  --rm -it \
  -- curl -sS http://nginx-service
```

### Command explanation

- `kubectl run curl-test`: creates a temporary Pod named `curl-test`.
- `--image=curlimages/curl:latest`: uses an image containing the `curl` utility.
- `--restart=Never`: creates a standalone Pod rather than a Deployment.
- `--rm`: requests removal of the Pod after the attached command finishes.
- `-it`: requests an interactive terminal connection.
- `--`: separates Kubernetes command options from the command executed inside the container.
- `curl -sS http://nginx-service`: sends an HTTP request to the Service's DNS name.

Because HTTP uses port 80 by default, the command does not need to specify the port explicitly.

### Expected result

The command returns HTML containing:

```html
<h1>Welcome to nginx!</h1>
```

This confirms that the request reached the NGINX application through the Service.

The output may contain a warning about attaching to the temporary Pod. If Kubernetes falls back to streaming logs and returns the expected HTML, the HTTP request itself has succeeded.

## 5. Understand the Request Flow

```text
Temporary curl-test Pod
          |
          | HTTP request
          v
   nginx-service
          |
          | Service selects matching Pods
          v
      NGINX Pod
          |
          v
     HTML response
```

The client uses the Service name rather than needing to know the IP address of an individual Pod.

## 6. Inspect Pods and Labels

```bash
kubectl get pods --show-labels
```

This displays the labels attached to each Pod.

Inspect the Service's selector:

```bash
kubectl describe service nginx-service
```

A selector such as `app=nginx-lab` matches Pods carrying that label.

## 7. Inspect EndpointSlices

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=nginx-service
```

EndpointSlices provide information about the backend endpoints associated with the Service.

They help verify which Pod addresses are available to receive traffic.

## Key Concepts Learned

- **Service:** provides a stable endpoint for accessing a group of Pods.
- **ClusterIP:** exposes a Service internally within the cluster.
- **Selector:** identifies Pods that belong to the Service's backend.
- **Kubernetes DNS:** allows applications to reach Services using names such as `nginx-service`.
- **EndpointSlices:** represent backend endpoints associated with a Service.
- **Pod IP versus Service address:** individual Pod IPs may change, while the Service provides a stable endpoint.

## Important Takeaway

A Service separates application clients from the lifecycle of individual Pods. Clients communicate with a stable Service name, and Kubernetes routes requests to eligible backend Pods.

A `ClusterIP` Service is internal by default. It does not expose the application directly to the public internet.
