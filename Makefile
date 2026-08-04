.PHONY: help cluster-up cluster-down check-terragrunt argocd-install argocd-deploy verify port-forward status clean

SHELL := /bin/bash

help:
	@echo "Targets:"
	@echo "  cluster-up"
	@echo "  argocd-install"
	@echo "  argocd-deploy"
	@echo "  verify"
	@echo "  port-forward"
	@echo "  status"
	@echo "  clean"

cluster-up:
	@if ! kind get clusters | grep -qx "gitops-cod"; then kind create cluster --name gitops-cod; fi
	@kubectl cluster-info --context kind-gitops-cod >/dev/null

cluster-down:
	@kind delete cluster --name gitops-cod

check-terragrunt:
	@command -v terragrunt >/dev/null 2>&1 || { \
		echo "terragrunt not found. Install with: brew install terragrunt"; \
		exit 1; \
	}

argocd-install:
	@kubectl create namespace argocd >/dev/null 2>&1 || true
	@kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml >/dev/null
	@kubectl rollout status deployment/argocd-server -n argocd
	@kubectl rollout status statefulset/argocd-application-controller -n argocd

argocd-deploy:
	@$(MAKE) check-terragrunt
	@kubectl create namespace hello-world-app >/dev/null 2>&1 || true
	@VALUES=$$( \
		cd envs/dev/app; \
		terragrunt init >/dev/null; \
		terragrunt apply -auto-approve -input=false >/dev/null; \
		terragrunt output -raw helm_values 2>/dev/null | sed -n '/^[[:space:]]*"\?[a-zA-Z0-9_-]\+"\?:/,$$p' \
	); \
	awk '1; /path: charts\/hello-world-app/ { print "    helm:"; print "      values: |" }' argocd/apps/hello-world-app.yaml | \
	awk -v values="$$VALUES" 'BEGIN { n=split(values, a, "\\n"); for (i=1; i<=n; i++) if (length(a[i])>0) print "        " a[i] } { print }' | \
	kubectl apply -f - >/dev/null
	@kubectl get applications -n argocd

verify:
	@kubectl get pods -n hello-world-app
	@kubectl get svc -n hello-world-app

port-forward:
	@kubectl cluster-info >/dev/null 2>&1 || { echo "cluster not reachable. Run: make cluster-up"; exit 1; }
	@kubectl wait --for=jsonpath='{.status.sync.status}'=Synced application/hello-world-app -n argocd --timeout=300s
	@kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/hello-world-app -n argocd --timeout=300s
	@kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=hello-world-app -n hello-world-app --timeout=300s
	@SERVICE_NAME=$$(kubectl get svc -n hello-world-app -l app.kubernetes.io/name=hello-world-app -o jsonpath='{.items[0].metadata.name}'); \
	SERVICE_PORT=$$(kubectl get svc -n hello-world-app -l app.kubernetes.io/name=hello-world-app -o jsonpath='{.items[0].spec.ports[0].port}'); \
	if [ -z "$$SERVICE_NAME" ]; then \
		echo "service not found. Run: make argocd-deploy"; \
		exit 1; \
	fi; \
	echo "url: http://localhost:8080 (service $$SERVICE_NAME:$$SERVICE_PORT)"; \
	kubectl port-forward -n hello-world-app svc/$$SERVICE_NAME 8080:80

status:
	@kubectl cluster-info 2>/dev/null || echo "cluster: not running"
	@kubectl get applications -n argocd 2>/dev/null || echo "argocd: not installed"
	@kubectl get pods -n hello-world-app 2>/dev/null || echo "app: not deployed"
	@kubectl get svc -n hello-world-app 2>/dev/null || true

clean:
	-@kind delete cluster --name gitops-cod
	-@kubectl delete ns hello-world-app --ignore-not-found=true >/dev/null
	-@kubectl delete ns argocd --ignore-not-found=true >/dev/null

.DEFAULT_GOAL := help
