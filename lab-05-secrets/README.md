# Lab 5 — Kubernetes Secrets

## Objective

Learn how to store sensitive data in a Secret and consume it from a Pod, both as an environment variable and as files mounted in a volume.

## Files

- `app-secret.yaml`: Secret named `app-secret` containing demo database credentials.
- `secret-test.yaml`: Pod named `secret-test` that reads the Secret as an environment variable and as a mounted volume.

## 1. Create the Secret

```bash
kubectl apply -f app-secret.yaml
```

The manifest uses `stringData`, so values are written in plain text and Kubernetes base64-encodes them when storing the Secret.

Verify it:

```bash
kubectl get secrets
kubectl describe secret app-secret
```

`describe` shows the keys and their sizes, but not the values.

## 2. Inspect the Stored Values

```bash
kubectl get secret app-secret -o jsonpath='{.data.DB_USER}' | base64 -d
```

This shows that Secret data is only base64-encoded, not encrypted. Anyone with read access to Secrets can decode them.

## 3. Run the Test Pod

```bash
kubectl apply -f secret-test.yaml
```

The Pod consumes the Secret in two ways:

- `env.valueFrom.secretKeyRef`: exposes the `DB_USER` key as an environment variable.
- `volumes.secret`: mounts every key of the Secret as a file under `/etc/secret`.

## 4. Check the Result

```bash
kubectl logs secret-test
```

Expected output:

```text
DB user (from env): gift_app
Files in /etc/secret:
DB_PASSWORD
DB_USER
```

Read a mounted file:

```bash
kubectl exec secret-test -- cat /etc/secret/DB_PASSWORD
```

## 5. Clean Up

```bash
kubectl delete -f secret-test.yaml
kubectl delete -f app-secret.yaml
```

## Key Concepts Learned

- **Secret:** stores sensitive data such as passwords, tokens, and keys.
- **`data` vs `stringData`:** `data` expects base64-encoded values; `stringData` accepts plain text.
- **Environment variable injection:** `secretKeyRef` exposes a single key as a variable.
- **Volume mount:** each Secret key becomes a file; mounted Secrets are refreshed automatically when the Secret changes.
- **Base64 is not encryption:** access to Secrets must be restricted with RBAC.

## Important Takeaway

Secrets keep sensitive values out of container images and Pod specs, but they are only base64-encoded by default. Never commit real credentials to git; the values in `app-secret.yaml` are demo values only.
