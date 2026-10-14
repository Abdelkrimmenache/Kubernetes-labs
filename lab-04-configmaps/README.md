# Lab 4 — Kubernetes ConfigMaps

## Objective

Learn how to store non-sensitive application configuration in a ConfigMap and inject it into a Pod as environment variables.

## Files

- `app-config.yaml`: ConfigMap named `app-config` containing the application settings.
- `config-test.yaml`: Pod named `config-test` that loads every key from `app-config` as environment variables.

## 1. Create the ConfigMap

```bash
kubectl apply -f app-config.yaml
```

Verify it:

```bash
kubectl get configmaps
kubectl describe configmap app-config
```

The ConfigMap contains three keys:

- `APP_NAME`: `gift-app`
- `APP_ENV`: `development`
- `LOG_LEVEL`: `debug`

## 2. Run the Test Pod

```bash
kubectl apply -f config-test.yaml
```

The Pod uses `envFrom.configMapRef` to turn every key of `app-config` into an environment variable.

## 3. Check the Result

```bash
kubectl logs config-test
```

Expected output:

```text
App: gift-app
Environment: development
Log level: debug
```

You can also inspect the environment directly:

```bash
kubectl exec config-test -- env | grep -E 'APP_|LOG_'
```

## 4. Update the ConfigMap

Edit a value in `app-config.yaml` (for example `LOG_LEVEL: "info"`), then apply it again:

```bash
kubectl apply -f app-config.yaml
```

Environment variables are read only when the container starts, so the running Pod keeps the old values. Recreate the Pod to load the new ones:

```bash
kubectl delete pod config-test
kubectl apply -f config-test.yaml
kubectl logs config-test
```

## 5. Clean Up

```bash
kubectl delete -f config-test.yaml
kubectl delete -f app-config.yaml
```

## Key Concepts Learned

- **ConfigMap:** stores non-sensitive configuration as key-value pairs.
- **`envFrom`:** injects all keys of a ConfigMap as environment variables.
- **Decoupling:** the same container image can run in different environments with different configuration.
- **Update behavior:** environment variables are not refreshed in running Pods; the Pod must be restarted.

## Important Takeaway

ConfigMaps separate configuration from the container image. They are not encrypted and must not hold passwords, tokens, or keys — use Secrets for that (Lab 5).
