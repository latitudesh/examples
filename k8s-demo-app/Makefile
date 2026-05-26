NS         ?= ai-demo
IMAGE_REPO ?= ghcr.io/latitudesh/k8s-demo-api
IMAGE_TAG  ?= v1
IMAGE      := $(IMAGE_REPO):$(IMAGE_TAG)
KUBECTL    ?= kubectl

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: prereqs
prereqs: ## One-time: install local-path-provisioner (RKE2 ships without one)
	$(KUBECTL) apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml

.PHONY: namespace
namespace: ## Create the demo namespace
	$(KUBECTL) apply -f manifests/namespace.yaml

.PHONY: frontend-config
frontend-config: namespace ## Regenerate the frontend ConfigMaps from ui/
	$(KUBECTL) create cm frontend-assets -n $(NS) \
	  --from-file=index.html=ui/index.html \
	  --from-file=chat.css=ui/chat.css \
	  --from-file=chat.js=ui/chat.js \
	  --dry-run=client -o yaml | $(KUBECTL) apply -f -
	$(KUBECTL) create cm frontend-nginx -n $(NS) \
	  --from-file=nginx.conf=ui/nginx.conf \
	  --dry-run=client -o yaml | $(KUBECTL) apply -f -

.PHONY: deploy
deploy: namespace frontend-config ## Apply every manifest in order
	$(KUBECTL) apply -f manifests/llama-qwen.yaml
	$(KUBECTL) apply -f manifests/llama-hermes.yaml
	$(KUBECTL) apply -f manifests/redis.yaml
	$(KUBECTL) apply -f manifests/backend.yaml
	$(KUBECTL) apply -f manifests/frontend.yaml
	$(KUBECTL) apply -f manifests/loadbalancer.yaml
	@echo
	@echo "Watch the LoadBalancer pick up its IP:"
	@echo "  $(KUBECTL) get svc -n $(NS) llama-external --watch"

.PHONY: status
status: ## Show pods, services, and recent events
	$(KUBECTL) get pod,svc,pvc -n $(NS)
	@echo
	$(KUBECTL) get events -n $(NS) --sort-by=.lastTimestamp | tail -15

.PHONY: smoke
smoke: ## Run the end-to-end smoke test against the LoadBalancer IP
	./smoke-test.sh

.PHONY: image
image: ## Build the k8s-demo-api Docker image locally
	docker build -t $(IMAGE) ./api

.PHONY: push
push: image ## Push the image to the configured registry (requires auth)
	docker push $(IMAGE)

.PHONY: rollout
rollout: ## Force a rolling restart of the backend (after pushing a new image tag)
	$(KUBECTL) rollout restart deployment/backend -n $(NS)
	$(KUBECTL) rollout status  deployment/backend -n $(NS) --timeout=120s

.PHONY: teardown
teardown: ## Delete the demo namespace (everything goes with it)
	$(KUBECTL) delete namespace $(NS) --wait=false
