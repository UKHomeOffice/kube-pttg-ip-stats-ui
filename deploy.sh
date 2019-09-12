# #!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}
export WHITELIST=${WHITELIST:-0.0.0.0/0}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

echo "deploy ${VERSION} to ${ENVIRONMENT} namespace - using Kube token stored as drone secret"

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    export KUBE_TOKEN=${PTTG_IP_PR}
    export DNS_PREFIX=
    export KC_REALM=pttg-production
    export CLUSTER_NAME="acp-prod"
else
    export KUBE_TOKEN=${PTTG_IP_DEV}
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
    export KC_REALM=pttg-qa
    export CLUSTER_NAME="acp-notprod"
fi

export DOMAIN_NAME=ipstats.${DNS_PREFIX}pttg.homeoffice.gov.uk

echo "DOMAIN_NAME is $DOMAIN_NAME"

export KUBE_CERTIFICATE_AUTHORITY=/tmp/cert.crt
if ! curl --silent --fail --retry 5 \
    https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/$CLUSTER_NAME.crt -o $KUBE_CERTIFICATE_AUTHORITY; then
  echo "[error] failed to download ca for kube api"
  exit 1
fi

cd kd || exit 1

kd \
    -f networkPolicy.yaml \
    -f ingress.yaml \
    -f deployment.yaml \
    -f service.yaml
