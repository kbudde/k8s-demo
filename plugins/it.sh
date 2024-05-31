#!/usr/bin/env bash

set -e

# "MYKS_ENV":              a.e.Id,
# "MYKS_APP":              a.Name,
# "MYKS_APP_PROTOTYPE":    a.Prototype,
# "MYKS_ENV_DIR":          a.e.Dir,
# "MYKS_RENDERED_APP_DIR": "rendered/envs/" + a.e.Id + "/" + a.Name, // TODO: provide func and use it everywher

myks all "$MYKS_ENV" "$MYKS_APP"
echo "MYKS_RENDERED_APP_DIR: $MYKS_RENDERED_APP_DIR"



# check secrets
(
    echo -n "check secrets: "
    if [ -z "$SOPS_AGE_KEY" ]; then
        echo "SOPS_AGE_KEY is not set"
        exit 1
    fi
    export AVP_TYPE=sops
    cd "$MYKS_RENDERED_APP_DIR"
    find . \
        -regextype egrep \
        -iregex '.*\.(yaml|yml)' \
        -not -path "./static/*" \
        -printf '---\n' \
        -exec cat {} \; \
    | argocd-vault-plugin generate -  >> /dev/null || (echo "❌Error generating $MYKS_APP failed" && exit 1)
    echo "✔️ passed"
)

# check manifests
 echo -n "lint manifests: "
kube-linter lint --config .kubelint.yaml --with-color "$MYKS_RENDERED_APP_DIR" \
    --ignore-paths "./$MYKS_RENDERED_APP_DIR/static/*" \
    # --fail-on-invalid-resource # CRDs are not supported
    # --fail-if-no-objects-found # if only CRs are shipped, it will fail
