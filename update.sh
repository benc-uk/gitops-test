#!/bin/bash

KUST_NAME=demo-env
GIT_NAME=gitops-test

git add -A && git commit --amend --no-edit \
&& git push --force \
&& sleep 2 \
&& flux reconcile source git -n flux-system $GIT_NAME \
&& flux reconcile kustomization -n flux-system $KUST_NAME