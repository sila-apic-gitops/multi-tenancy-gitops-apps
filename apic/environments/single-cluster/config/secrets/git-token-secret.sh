#!/usr/bin/env bash

# Set variables
if [[ -z ${GIT_USERNAME} ]]; then
  echo "Please provide environment variable GIT_USERNAME"
  exit 1
fi
if [[ -z ${GIT_PRIV_TOKEN} ]]; then
  echo "Please provide environment variable GIT_PRIV_TOKEN"
  exit 1
fi

GIT_USERNAME=${GIT_USERNAME}
GIT_PRIV_TOKEN=${GIT_PRIV_TOKEN}

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
oc create secret docker-registry ibm-entitlement-key \
--docker-username=cp \
--docker-password=${IBM_ENTITLEMENT_KEY} \
--docker-server=cp.icr.io \
--dry-run=true -o yaml > delete-ibm-entitlement-key-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n tools --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-ibm-entitlement-key-secret.yaml > ibm-entitlement-key-secret.yaml

# NOTE, do not check delete-ibm-entitled-key-secret.yaml into git!
rm delete-ibm-entitlement-key-secret.yaml
