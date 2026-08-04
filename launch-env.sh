#!/usr/bin/env bash
set -euo pipefail

make cluster-up
make argocd-install
make argocd-deploy
make port-forward
