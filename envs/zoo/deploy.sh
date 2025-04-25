#!/usr/bin/env bash
set -e

base=rendered/envs/zoo

export AVP_TYPE=sops

apply_app(){
  local app=$1
  local app_name=${app#"$base/"}
  (
    cd "$app" || exit 1
    echo "Apply $app_name"

    find . \
        -regextype egrep \
        -iregex '.*\.(yaml|yml)' \
        -not -path "./static/*" \
        -printf '---\n' \
        -exec cat {} \; |
        argocd-vault-plugin generate - >> /dev/null || (echo "❌Error generating $MYKS_APP failed" && exit 1)

    find . \
        -regextype egrep \
        -iregex '.*\.(yaml|yml)' \
        -not -path "./static/*" \
        -printf '---\n' \
        -exec cat {} \; |
        argocd-vault-plugin generate - | \
        kapp deploy -y -c -a "$app_name" -f - --apply-default-update-strategy fallback-on-replace

    echo "✔️ passed"
  )
}


echo -n "check secrets: "
if [ -z "$SOPS_AGE_KEY" ]; then
    echo "SOPS_AGE_KEY is not set"
    exit 1
fi

# check if parameter are passed
if [ $# -eq 0 ]; then
    myks all zoo ALL
  for app in "$base"/*; do
    apply_app "$app"
  done
else
  for app in "$@"; do
    myks all zoo $app
    apply_app "$base/$app"
  done
fi

