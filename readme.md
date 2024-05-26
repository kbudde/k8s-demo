# k8s manifests

Rendered manifests using [github.com/mykso/myks](https://github.com/mykso/myks).
It's using a pre-release version.

## Secret management

Secrets are managed using sops with age and [argocd-vault-plugin](https://argocd-vault-plugin.readthedocs.io/).

Secrets are stored in yaml files in `secrets/.*\.yaml`. They are encrypted using sops with age. Recipient is configured in .sops.yaml.

Editing files is simple: `sops secrets/demo.yaml`

Rendering kubernetes resources: `argocd-vault-plugin generate rendered/envs/demo` will spit out manifests with secrets.

### How are secrets configured

Special syntax: "<path:static/file.yaml#key>"

```yaml
apiVersion: v1
kind: Secret
metadata:
  annotations:
    a8r.io/repository: ""
  labels:
    app.kubernetes.io/name: argocd-secret
    app.kubernetes.io/part-of: argocd
  name: argocd-secret
  namespace: argocd
type: Opaque
stringData:
  foo: bar
  encrypted: <path:static/demo.yaml#myKey>
```

Warning: sops as [backend](https://argocd-vault-plugin.readthedocs.io/en/stable/backends/#sops) in argocd-vault-plugin does not support nested keys or versions like vault.

```yaml
parent:
  child: value
```

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: test-secret
type: Opaque
stringData:
  password: <path:example.yaml#parent | jsonPath {.child}>
```

## deployment

It's using argocd

# bootstrap in-cluster

## generate age key

```shell
age-keygen
```
put the public key in `.sops.yaml`
export the `AGE-SECRET-KEY-...` as `SOPS_AGE_KEY`

```shell
kubectl create ns argocd
kubectl -n argocd create secret generic argo-sops-secret --from-literal SOPS_AGE_KEY=${SOPS_AGE_KEY} --from-literal AVP_TYPE=SOPS
# The secret is referenced in `prototypes/argocd/ytt/argocd-vault-plugin.ytt.yaml`

## install argo cd

```shell
export AVP_TYPE=sops
cd rendered/envs/demo/argocd/
find . \
  -regextype egrep \
  -iregex '.*\.(yaml|yml)' \
  -not -path "./static/*" \
  -printf '---\n' \
  -exec cat {} \; \
| argocd-vault-plugin generate - | kubectl apply -n argocd -f - 
```

