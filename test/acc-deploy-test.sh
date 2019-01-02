#!/bin/bash

set -e

if [[ -z "${SUBSCRIPTION_ID:-}" ]]; then echo "Must specify SUBSCRIPTION_ID"; exit 1; fi
if [[ -z "${TENANT:-}" ]]; then echo "Must specify TENANT"; exit 1; fi

if [[ -z "${SERVICE_PRINCIPAL_ID:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_ID"; exit 1; fi
if [[ -z "${SERVICE_PRINCIPAL_PASSWORD:-}" ]]; then echo "Must specify SERVICE_PRINCIPAL_PASSWORD"; exit 1; fi

if [[ -z "${IMAGE:-}" ]]; then echo "Must specify IMAGE"; exit 1; fi
if [[ -z "${LOCATION:-}" ]]; then echo "Must specify LOCATION"; exit 1; fi

if [[ -z "${KV_NAME:-}" ]]; then echo "Must specify KV_NAME"; exit 1; fi
if [[ -z "${KV_SECRET_SSH_PUB:-}" ]]; then echo "Must specify KV_SECRET_SSH_PUB"; exit 1; fi
if [[ -z "${KV_SECRET_WIN_PWD:-}" ]]; then echo "Must specify KV_SECRET_WIN_PWD"; exit 1; fi

az login --service-principal -u ${SERVICE_PRINCIPAL_ID} -p ${SERVICE_PRINCIPAL_PASSWORD} --tenant $TENANT
az account set --subscription ${SUBSCRIPTION_ID}

if [ -z "${OE_ENGINE_BIN}" ]; then
  echo "Download oe-engine binary from the cloud"
  wget -q https://oejenkinsciartifacts.blob.core.windows.net/oe-engine/latest/bin/oe-engine
  chmod 755 oe-engine
  OE_ENGINE_BIN="./oe-engine"
fi

if [ "$IMAGE" = "Ubuntu16.04" ]; then
  SSH_PUB_KEY=$(az keyvault secret show --vault-name ${KV_NAME} --name ${KV_SECRET_SSH_PUB} | jq -r .value | base64 -d)
  sed -i "/\"keyData\":/c \"keyData\": \"${SSH_PUB_KEY}\"" oe-ub1604.json
  ${OE_ENGINE_BIN} generate --api-model oe-ub1604.json
elif [ "$IMAGE" = "Ubuntu18.04" ]; then
  SSH_PUB_KEY=$(az keyvault secret show --vault-name ${KV_NAME} --name ${KV_SECRET_SSH_PUB} | jq -r .value | base64 -d)
  sed -i "/\"keyData\":/c \"keyData\": \"${SSH_PUB_KEY}\"" oe-ub1804.json
  ${OE_ENGINE_BIN} generate --api-model oe-ub1804.json
elif [ "$IMAGE" = "Windows" ]; then
  ADMIN_PASSWORD=$(az keyvault secret show --vault-name ${KV_NAME} --name ${KV_SECRET_WIN_PWD} | jq -r .value)
  sed -i "/\"adminPassword\":/c \"adminPassword\": \"${ADMIN_PASSWORD}\"" oe-win.json
  ${OE_ENGINE_BIN} generate --api-model oe-win.json
else
  echo "Unsupported IMAGE $IMAGE"
  exit 1
fi

RGNAME="acc-${IMAGE}-${LOCATION}-${BUILD_NUMBER}"
az group create --name $RGNAME --location $LOCATION
trap 'az group delete --name $RGNAME --yes --no-wait' EXIT
az group deployment create -n acc-lnx -g $RGNAME --template-file _output/azuredeploy.json --parameters _output/azuredeploy.parameters.json
