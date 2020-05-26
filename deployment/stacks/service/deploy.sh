#!/bin/sh
set -e

echo "given arguments:"
echo "$0,  $1,  $2,  $3,  $4"

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

pwd

print_red() {
 printf '%b' "\033[91m$1\033[0m\n"
}

print_green() {
 printf '%b' "\033[92m$1\033[0m\n"
}

# NB: this isn't filled in by the common pipeline scripts: instead, we supply this in Jenkinsfile DEPLOYMENT_FILE
OVERLAY=${1?You must pass in the name of the overlay you wish to use}
# NB: this relates to PIPELINE_ID in the common pipeline scripts
#     it is autobuilt by the common pipeline, using JIRA_TICKET_PREFIX and the current git branch name.
#     it's an important one, as it ends up being your kubernetes namespace name
ENV=${2?You must pass in the name of the environment to deploy into}
# NB: this relates to VERSION in the common pipeline scripts
SUPPLIED_EXTRACT_IMAGE_TAG=${3?You must specify the tag of the extract image you want to deploy}
SUPPLIED_UPLOAD_IMAGE_TAG=${4?You must specify the tag of the upload image you want to deploy}
EXTRACT_JOB_SCHEDULE=${5?You must specify the cronjob schedule for the extract job}
UPLOAD_JOB_SCHEDULE=${6?You must specify the cronjob schedule for the upload job}

NAMESPACE="pu-jobs-${ENV}"
OVERLAY_FOLDER="overlays/${OVERLAY}/"

# we need to replace values in the template files, without affecting source control
# so copy the templates into the base folder. do replacements. then point kubernetes at these base folder files instead
cp base/template/kustomization.yaml base/kustomization.yaml
cp base/template/namespace.yaml base/namespace.yaml
cp base/template/extract-job-deployment.yaml base/extract-job-deployment.yaml
cp base/template/upload-job-deployment.yaml base/upload-job-deployment.yaml
cp ${OVERLAY_FOLDER}template/kustomization.yaml ${OVERLAY_FOLDER}kustomization.yaml

sed -i "s/EXTRACT_IMAGE_TAG/${SUPPLIED_EXTRACT_IMAGE_TAG}/g" base/kustomization.yaml
sed -i "s/UPLOAD_IMAGE_TAG/${SUPPLIED_UPLOAD_IMAGE_TAG}/g" base/kustomization.yaml
sed -i "s/NAMESPACE_TO_BE_REPLACED/${NAMESPACE}/g" base/namespace.yaml
sed -i "s/NAMESPACE_TO_BE_REPLACED/${NAMESPACE}/g" base/namespace.yaml
sed -i "s/NAMESPACE_TO_BE_REPLACED/${NAMESPACE}/g" ${OVERLAY_FOLDER}kustomization.yaml
sed -i "s/EXTRACT_SCHEDULE/${EXTRACT_JOB_SCHEDULE}/g" base/extract-job-deployment.yaml
sed -i "s/UPLOAD_SCHEDULE/${UPLOAD_JOB_SCHEDULE}/g" base/upload-job-deployment.yaml

print_green "Deploying into namespace ${NAMESPACE}..."

# NB: we point k8s just at the overlay base folder.  but the overlay file imports the other base/* files as parents
echo "Running kubernetes in folder '${OVERLAY_FOLDER}', which contains:"
ls -l ${OVERLAY_FOLDER}

eval "kustomize build ${OVERLAY_FOLDER} | kubectl apply -f -"

# remove the base files that we created
eval "rm base/kustomization.yaml"
eval "rm base/namespace.yaml"
eval "rm base/extract-job-deployment.yaml"
eval "rm base/upload-job-deployment.yaml"
eval "rm ${OVERLAY_FOLDER}kustomization.yaml"

# output some useful debug info
print_green "Checking results ..."
print_green "Get Namespaces"
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=${NAMESPACE}"
eval "${KUBECTL} get namespaces --show-labels"
print_green "Get cronjobs"
eval "${KUBECTL} get cronjobs --show-labels"
print_green "Get network policies"
eval "${KUBECTL} get networkpolicies  --show-labels"
print_green "Get configmaps"
eval "${KUBECTL} get configmaps  --show-labels"

print_green "---Complete---"

