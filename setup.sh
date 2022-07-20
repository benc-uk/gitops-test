#!/bin/bash

#
# Setup Flux with a git repo and kustomization(s)
#

FLUX_NS=flux-system

# Change these
GIT_URL=https://github.com/benc-uk/gitops-test.git
GIT_BRANCH=main
GIT_NAME=gitops-test

# Also change these
KUST_NAME=demo-env
KUST_PATH=./envs/demo
KUST_INTERVAL=2m

# Check we have Flux CLI
flux -v > /dev/null 2>&1 || { echo >&2 "💥 Flux is not installed. Aborting."; exit 1; }

# Check flux is installed in cluster
if (( $(kubectl get po -n $FLUX_NS | wc -l) < 5 )); then
  echo "😲 Flux is not installed in cluster. Running 'flux install'..."
  flux install
fi

echo -e "\e[32m>>> ✅ Flux is installed in cluster, whoo!\e[0m"
echo -e "\e[32m>>> 🔨 Configuring git source $GIT_URL\e[0m"

flux create source git $GIT_NAME \
    --url=$GIT_URL \
    --branch=$GIT_BRANCH 

# Create a Kustomization resource from a source at a given path
echo -e "\e[32m>>> 🔨 Configuring Kustomization path $KUST_PATH\e[0m"
flux create kustomization $KUST_NAME \
  --source=GitRepository/$GIT_NAME \
  --path="$KUST_PATH" \
  --prune=true \
  --interval=$KUST_INTERVAL \
  --wait=true \
  --health-check-timeout=3m

echo -e "\e[32m>>> 🔎 Checking status\e[0m"
flux get sources git
flux get kustomizations