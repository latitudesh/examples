"""
Chat orchestrator for the k8s-demo-app blog post example.

Routes chat requests to one of two llama-server pods, injects current date
into a dynamic system prompt, forces thinking mode off, and persists per-session
history in Redis with a 24h TTL.
"""
import json
import os
import uuid
from datetime import datetime, timezone
from typing import AsyncIterator

import httpx
import redis.asyncio as redis
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import JSONResponse, StreamingResponse
from pydantic import BaseModel

MODELS = {
    "qwen": os.environ.get("LLAMA_QWEN_URL", "http://llama-qwen:8080"),
    "hermes": os.environ.get("LLAMA_HERMES_URL", "http://llama-hermes:8080"),
}
REDIS_URL = os.environ.get("REDIS_URL", "redis://redis:6379/0")
SESSION_TTL_SECONDS = 86400
MAX_TOKENS = 1024
DEFAULT_MODEL = "qwen"

app = FastAPI(title="k8s-demo-app chat orchestrator", version="1.0")
r = redis.from_url(REDIS_URL, decode_responses=True)
http = httpx.AsyncClient(timeout=httpx.Timeout(connect=5.0, read=300.0, write=10.0, pool=10.0))


def system_prompt() -> str:
    now = datetime.now(timezone.utc)
    return (
        "You are a helpful assistant running on Latitude.sh bare metal Kubernetes. "
        f"Today is {now.strftime('%Y-%m-%d')} ({now.strftime('%A')}) UTC. "
        "Be concise."
    )


class ChatRequest(BaseModel):
    message: str


@app.get("/health")
async def health():
    try:
        await r.ping()
    except Exception:
        return JSONResponse({"status": "redis_unavailable"}, status_code=503)
    return {"status": "ok"}


@app.get("/models")
async def list_models():
    return {"default": DEFAULT_MODEL, "available": sorted(MODELS.keys())}


def _read_cpu_model() -> str:
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("model name"):
                    return line.split(":", 1)[1].strip()
    except Exception:
        pass
    return "bare-metal Kubernetes"


@app.get("/host-info")
async def host_info():
    return {"cpu": _read_cpu_model(), "inference": "CPU", "gpu": False}


@app.get("/history")
async def history(session_id: str = Query(...)):
    raw = await r.lrange(f"session:{session_id}:history", 0, -1)
    return {"session_id": session_id, "turns": [json.loads(t) for t in raw]}


@app.get("/sessions")
async def list_sessions():
    sessions = []
    async for key in r.scan_iter(match="session:*:history", count=200):
        sid = key.removeprefix("session:").removesuffix(":history")
        llen = await r.llen(key)
        ttl = await r.ttl(key)
        sessions.append({"id": sid, "turns": llen, "ttl_seconds": ttl})
    sessions.sort(key=lambda s: s["ttl_seconds"], reverse=True)
    return {"count": len(sessions), "sessions": sessions}


@app.post("/reset")
async def reset(session_id: str = Query(...)):
    await r.delete(f"session:{session_id}:history")
    return {"session_id": session_id, "cleared": True}


@app.post("/chat")
async def chat(
    req: ChatRequest,
    session_id: str = Query(default_factory=lambda: str(uuid.uuid4())),
    model: str = Query(default=DEFAULT_MODEL),
):
    if model not in MODELS:
        raise HTTPException(400, f"unknown model {model!r}; available: {sorted(MODELS.keys())}")
    upstream = MODELS[model]

    history_key = f"session:{session_id}:history"
    raw_history = await r.lrange(history_key, 0, -1)
    history = [json.loads(t) for t in raw_history]

    user_turn = {"role": "user", "content": req.message}
    await r.rpush(history_key, json.dumps(user_turn))
    await r.expire(history_key, SESSION_TTL_SECONDS)

    messages = [{"role": "system", "content": system_prompt()}]
    for turn in history:
        messages.append({"role": turn["role"], "content": turn["content"]})
    messages.append(user_turn)

    payload = {
        "messages": messages,
        "max_tokens": MAX_TOKENS,
        "stream": True,
        "chat_template_kwargs": {"enable_thinking": False},
    }

    async def stream() -> AsyncIterator[bytes]:
        assistant_text_parts: list[str] = []
        try:
            yield f"data: {json.dumps({'event': 'meta', 'model': model, 'session_id': session_id})}\n\n".encode()

            async with http.stream(
                "POST",
                f"{upstream}/v1/chat/completions",
                json=payload,
                headers={"Content-Type": "application/json"},
            ) as response:
                if response.status_code != 200:
                    body = await response.aread()
                    yield f"data: {json.dumps({'event': 'error', 'status': response.status_code, 'body': body.decode(errors='replace')[:500]})}\n\n".encode()
                    return

                async for line in response.aiter_lines():
                    if not line:
                        continue
                    if not line.startswith("data:"):
                        continue
                    data = line[5:].strip()
                    if data == "[DONE]":
                        yield b"data: [DONE]\n\n"
                        break
                    try:
                        obj = json.loads(data)
                    except json.JSONDecodeError:
                        continue
                    delta = obj.get("choices", [{}])[0].get("delta", {})
                    if content := delta.get("content"):
                        assistant_text_parts.append(content)
                        out = {"event": "delta", "content": content}
                        yield f"data: {json.dumps(out)}\n\n".encode()

            full_text = "".join(assistant_text_parts)
            if full_text:
                assistant_turn = {"role": "assistant", "content": full_text, "model": model}
                await r.rpush(history_key, json.dumps(assistant_turn))
                await r.expire(history_key, SESSION_TTL_SECONDS)
        except httpx.HTTPError as e:
            yield f"data: {json.dumps({'event': 'error', 'message': f'upstream error: {type(e).__name__}: {e}'})}\n\n".encode()
        except Exception as e:
            yield f"data: {json.dumps({'event': 'error', 'message': f'{type(e).__name__}: {e}'})}\n\n".encode()

    return StreamingResponse(
        stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )
