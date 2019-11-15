# #!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}
export WHITELIST=${WHITELIST:-0.0.0.0/0}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

# TODO EE-28636 Remove this - testing numeric version numbers
VERSION=1.2

echo "deploy ${VERSION} to ${ENVIRONMENT} namespace - using Kube token stored as drone secret"

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    export KUBE_TOKEN=${PTTG_IP_PR}
    export DNS_PREFIX=
    export KC_REALM=pttg-production
    export KUBE_CERTIFICATE_AUTHORITY=https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-prod.crt
else
    export KUBE_TOKEN=${PTTG_IP_DEV}
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
    export KC_REALM=pttg-qa
    export KUBE_CERTIFICATE_AUTHORITY=https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt
fi

export DOMAIN_NAME=ipstats.${DNS_PREFIX}pttg.homeoffice.gov.uk

echo "DOMAIN_NAME is $DOMAIN_NAME"

cd kd || exit 1

kd \
    -f networkPolicy.yaml \
    -f ingress.yaml \
    -f deployment.yaml \
    -f service.yaml --debug
