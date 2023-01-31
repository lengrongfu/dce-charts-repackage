#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$CURRENT_FILENAME" || exit; pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice, prometheus CRD has been deployed , so you no need to =============

set -x

helm repo add jetstack https://charts.jetstack.io
helm install \
  cert-manager jetstack/cert-manager \
  ${HELM_MUST_OPTION} \
  --create-namespace \
  --version v1.11.0 \
  --set installCRDs=true

sleep 3

# deploy cert-manager
# shellcheck disable=SC2086
kubectl --kubeconfig ${KIND_KUBECONFIG} create ${CHART_DIR}/templates/crds.yaml
helm install harbor-operator "${CHART_DIR}" ${HELM_MUST_OPTION} \
    --set installCRDs=false

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, failed to deploy $CHART_DIR"
  exit 1
fi