#!/bin/sh

#Need to set variables


CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# NB: this isn't filled in by the common pipeline scripts: instead, we supply this in Jenkinsfile DEPLOYMENT_FILE
OVERLAY=${1?You must pass in the name of the overlay you wish to use}

NAMESPACE="pu-jobs-${ENV}"
OVERLAY_FOLDER="overlays/${OVERLAY}/"

cp base/template/kustomization.yaml base/kustomization.yaml
cp base/template/namespace.yaml base/namespace.yaml
cp base/template/execute-sql-in-rds-job.yaml base/execute-sql-in-rds-job.yaml
cp ${OVERLAY_FOLDER}template/kustomization.yaml ${OVERLAY_FOLDER}kustomization.yaml

echo "Running kubernetes in folder '${OVERLAY_FOLDER}', which contains:"
ls -l ${OVERLAY_FOLDER}

eval "kustomize build ${OVERLAY_FOLDER} | kubectl apply -f -"
