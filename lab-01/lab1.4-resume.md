# Lab 1.4 — Kubernetes ConfigMaps

## 1. Objective

Learn how to store application configuration separately from container images and inject it into Pods using environment variables.

## 2. What Is a ConfigMap?

A ConfigMap is a Kubernetes resource used to store non-sensitive configuration as key-value pairs.

Examples include:
- Application name and environment
- Logging level
- API URLs
- Feature flags

ConfigMaps are managed at the cluster level through the Kubernetes API but are **namespaced resources**. A Pod normally references a ConfigMap in its own namespace.

## 3. Create a ConfigMap Using the CLI

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=development \
  --from-literal=APP_NAME=gift-app \
  --from-literal=LOG_LEVEL=debug
```

This creates a ConfigMap named `app-config` containing three configuration values.

Verify it:

```bash
kubectl get configmaps
kubectl describe configmap app-config
```

## 4. Create a ConfigMap Using YAML

Create `app-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_NAME: gift-app
  APP_ENV: development
  LOG_LEVEL: debug
```

Apply it:

```bash
kubectl apply -f app-config.yaml
```

Inspect its values:

```bash
kubectl get configmap app-config -o yaml
```

**Note:** If you already created `app-config` with the CLI, use the YAML to manage that same resource rather than attempting to create a duplicate.

## 5. Consume a ConfigMap in a Pod

Create `config-test.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-test
spec:
  restartPolicy: Never
  containers:
    - name: config-test
      image: busybox:1.36
      envFrom:
        - configMapRef:
            name: app-config
      command:
        - sh
        - -c
        - |
          echo "App: $APP_NAME"
          echo "Environment: $APP_ENV"
          echo "Log level: $LOG_LEVEL"
          sleep 3600
```

Apply the manifest:

```bash
kubectl apply -f config-test.yaml
```

Verify the Pod and its logs:

```bash
kubectl get pod config-test
kubectl logs config-test
```

Expected output:

```text
App: gift-app
Environment: development
Log level: debug
```

The `envFrom.configMapRef` field imports all key-value pairs from the referenced ConfigMap as environment variables.

## 6. Update a ConfigMap

Change the configuration in `app-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_NAME: gift-app
  APP_ENV: staging
  LOG_LEVEL: info
```

Apply the change:

```bash
kubectl apply -f app-config.yaml
```

Verify the updated resource:

```bash
kubectl describe configmap app-config
```

The ConfigMap now contains the new values. However, the environment variables in the existing `config-test` Pod still contain the values injected when its container started.

## 7. Apply the Updated Configuration

For the standalone Pod used in this lab, delete and recreate it:

```bash
kubectl delete -f config-test.yaml
kubectl apply -f config-test.yaml
```

Check the logs:

```bash
kubectl logs config-test
```

Expected output:

```text
App: gift-app
Environment: staging
Log level: info
```

The new container reads the latest values from the ConfigMap when it starts.

## 8. Important Concepts

### ConfigMap scope

- ConfigMaps are Kubernetes API resources stored in the cluster's backing datastore.
- They are namespaced, not created separately for each node.
- Multiple Pods in the same namespace can reference the same ConfigMap.
- A Pod can consume multiple ConfigMaps.

### Environment variables versus mounted files

- Environment variables sourced from a ConfigMap do not update in an existing container.
- ConfigMap volumes can receive updates eventually, but the application may need to reload the files.
- ConfigMap volumes mounted using `subPath` do not receive automatic updates.

### ConfigMaps versus Secrets

ConfigMaps are intended for non-sensitive settings. Passwords, tokens, and other sensitive values belong in Secrets, which also require appropriate access controls and security configuration.

## 9. Cleanup

Remove the resources created for this lab:

```bash
kubectl delete -f config-test.yaml
kubectl delete -f app-config.yaml
```

Only delete these resources if they belong to this lab and are no longer needed by other workloads.

## 10. Key Takeaway

A ConfigMap separates application configuration from the container image. You can update configuration independently, but environment-variable consumers need new containers to load changed values.

This helps make applications easier to configure across development, staging, and production environments without rebuilding their images.
