# GitOps Local Environment

This repository runs one app on a local kind cluster with Argo CD.

The app configuration values are generated from Terraform/Terragrunt output and injected into Argo CD at deploy time.

## Requirements

- Docker running
- kind
- kubectl
- make
- terraform
- terragrunt

## Main files

- `Makefile`: local commands
- `launch-env.sh`: one-command local startup
- `envs/dev/app/terragrunt.hcl`: input values
- `modules/app/main.tf`: generates Helm values string
- `argocd/apps/hello-world-app.yaml`: Argo CD Application base manifest
- `charts/hello-world-app/templates/`: Kubernetes templates

## Start the environment

Option 1:

```bash
./launch-env.sh
```

Option 2:

```bash
make cluster-up
make argocd-install
make argocd-deploy
```

## Access the app

```bash
make port-forward
```

Open:

`http://localhost:8080`

## Check status

```bash
make status
make verify
```

## Update the environment

1. Edit values in `envs/dev/app/terragrunt.hcl`.
2. Redeploy:

```bash
make argocd-deploy
```

This will:
- regenerate values from Terraform/Terragrunt
- inject them into a temporary Argo CD manifest
- apply the update to the cluster

## Stop and clean

```bash
make clean
```

## Notes

- `make argocd-deploy` already runs `make render` internally.
- If `terragrunt` is missing, install it with:

```bash
brew install terragrunt
```
