# k8s-demo-app

A reproducible example of **two self-hosted LLMs running side by side on bare-metal Kubernetes**, with a chat UI, conversation history in Redis, and a MetalLB LoadBalancer in front. Companion code for [the Latitude.sh blog post](https://www.latitude.sh/blog) on Kubernetes on bare metal.

```
Internet
   │
LoadBalancer (MetalLB + BGP)
   │
Frontend (nginx + chat UI)
   │
FastAPI orchestrator   ◄─── injects system prompt + date,
   │                        routes by model param,
   │                        streams SSE back to the browser
   ├──► llama-server (Qwen3.6-35B-A3B, MoE)    — default
   ├──► llama-server (Hermes-4-14B, dense)     — alternative
   └──► Redis  ◄─── per-session conversation history (24h TTL)
```

CPU-only (no GPU). Tested on AMD EPYC 4484PX (12c / 96 GB).

## Prerequisites

- A Latitude.sh Kubernetes cluster (or any K8s cluster with at least one worker node having ≥ 96 GB RAM and local NVMe-class storage)
- [MetalLB](https://metallb.io/) configured with an address pool named `loadbalancer-pool` (already set up on Latitude.sh-managed clusters)
- `kubectl` configured (`export KUBECONFIG=./my-cluster-kubeconfig.yaml`)

## Deploy

```bash
# One-time: install local-path-provisioner (RKE2 ships without one)
make prereqs

# Apply everything
make deploy

# Watch the LoadBalancer pick up its external IP
kubectl get svc -n ai-demo llama-external --watch
```

First boot of each `llama-server` takes ~1 minute (HF download of the GGUF, then memory-map). Subsequent restarts are instant — the model lives on local NVMe via a PVC.

## Use

Open the external IP in a browser:

```
http://<EXTERNAL-IP>/
```

You'll get a chat UI with a model selector. The default is `qwen` (faster). Switch to `hermes` to compare a smaller dense model.

Or hit the OpenAI-compatible API directly:

```bash
curl http://<EXTERNAL-IP>/api/chat?model=qwen \
  -H 'Content-Type: application/json' \
  -d '{"message":"Explain Kubernetes in 5 sentences."}'
```

The `/api/*` paths are proxied through nginx to the FastAPI orchestrator, which streams SSE deltas from the chosen `llama-server`.

### Endpoints

| Path | Verb | Description |
|--|--|--|
| `/api/health` | GET | Liveness + Redis reachability |
| `/api/models` | GET | List available models (`qwen`, `hermes`) |
| `/api/chat?session_id=...&model=...` | POST | SSE chat completion |
| `/api/history?session_id=...` | GET | Full conversation history |
| `/api/reset?session_id=...` | POST | Clear history for a session |

## Smoke test

```bash
make smoke
```

Runs `smoke-test.sh` against the public LoadBalancer IP. Auto-detects the IP via `kubectl`; override with `BASE=http://1.2.3.4 ./smoke-test.sh`.

Expected output:

```
Summary: 7 passed, 0 failed
```

## Scale demos (covered in the blog post)

```bash
# Horizontal scale of the stateless backend
kubectl scale -n ai-demo deployment/backend --replicas=10

# Rolling update — image bump
kubectl set image -n ai-demo deployment/backend \
  backend=ghcr.io/latitudesh/k8s-demo-api:v1.0.1

# Multi-model concurrency — open two browser tabs, pick a different
# model in each, fire prompts simultaneously. Both pods serve in parallel
# with <1% mutual interference (validated on EPYC 4484PX).
```

## Layout

```
k8s-demo-app/
├── README.md           # This file
├── Makefile            # make deploy / smoke / teardown / image / push
├── manifests/          # Pure YAML — apply in order via `make deploy`
├── api/                # FastAPI source → built into ghcr.io/latitudesh/k8s-demo-api
├── ui/                 # Frontend assets (HTML/CSS/JS + nginx.conf), mounted via ConfigMap
├── smoke-test.sh       # End-to-end smoke test
└── .github/workflows/  # CI to build & push the k8s-demo-api image
```

The **frontend** is kept as a ConfigMap (not a Docker image) on purpose: it's a few static files, easy to inspect, easy to edit, and any change goes live with one `make frontend-config && kubectl rollout restart deployment/frontend`. The **backend** ships as a real container image — startup is fast and reproducible.

## Troubleshooting

### "Send" button does nothing in the browser

The frontend uses `crypto.getRandomValues()` (works on any context) rather than `crypto.randomUUID()` (requires HTTPS or `localhost`). If you fork this and switch back to `crypto.randomUUID()`, plain-HTTP deployments will silently break — the script crashes before event listeners attach. Test in DevTools Console; you'll see the `TypeError`.

### Model returns an empty message

Qwen3.6 and Hermes-4 are hybrid reasoning models with thinking mode **on** by default. With a low `max_tokens` cap, the model consumes the budget inside `<think>` content and the visible response is empty. The FastAPI orchestrator forces `chat_template_kwargs: {enable_thinking: false}` on every upstream call to prevent this. If you call `llama-server` directly without the orchestrator, you'll hit this footgun.

### Wrong date in answers

The orchestrator injects the current UTC date into the system prompt on every request. If you bypass the orchestrator and ask the model "what day is it?" directly, you'll get a confident hallucination. The injection is in `api/app.py::system_prompt()`.

### Pod stuck in `Init:0/1`

Check the `fetch-model` init container logs. Hugging Face may be rate-limiting or the worker may be out of disk:

```bash
kubectl logs -n ai-demo <pod-name> -c fetch-model
```

The PVC needs to be at least 30 Gi for Qwen and 15 Gi for Hermes. Both back onto local NVMe via the `local-path` StorageClass.

## Tear down

```bash
make teardown
```

Deletes the namespace and everything in it (including PVCs and their on-disk model files).
