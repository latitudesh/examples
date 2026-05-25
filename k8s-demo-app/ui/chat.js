(() => {
  const SESSION_KEY = "k8s-demo-app:session_id";
  const MODEL_KEY   = "k8s-demo-app:model";
  const DEFAULT_MODEL = "qwen";

  const thread     = document.getElementById("thread");
  const composer   = document.getElementById("composer");
  const msgInput   = document.getElementById("msg");
  const sendBtn    = document.getElementById("send");
  const segOpts    = [...document.querySelectorAll(".seg-opt[data-model]")];
  const resetBtn   = document.getElementById("reset");
  const hostEl     = document.getElementById("host");

  // ─── session id (crypto.randomUUID is secure-context only → fallback) ──
  function newSessionId() {
    if (typeof crypto !== "undefined" && typeof crypto.randomUUID === "function") {
      return crypto.randomUUID();
    }
    const b = new Uint8Array(16);
    crypto.getRandomValues(b);
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    const h = [...b].map(x => x.toString(16).padStart(2, "0"));
    return `${h.slice(0,4).join("")}-${h.slice(4,6).join("")}-${h.slice(6,8).join("")}-${h.slice(8,10).join("")}-${h.slice(10,16).join("")}`;
  }
  let sessionId = localStorage.getItem(SESSION_KEY);
  if (!sessionId) {
    sessionId = newSessionId();
    localStorage.setItem(SESSION_KEY, sessionId);
  }

  // ─── model selection ─────────────────────────────────────────────────
  let activeModel = localStorage.getItem(MODEL_KEY) || DEFAULT_MODEL;
  function setActiveModel(m) {
    activeModel = m;
    localStorage.setItem(MODEL_KEY, m);
    for (const o of segOpts) {
      o.setAttribute("aria-checked", o.dataset.model === m ? "true" : "false");
    }
  }
  setActiveModel(activeModel);
  for (const o of segOpts) {
    o.addEventListener("click", () => setActiveModel(o.dataset.model));
  }

  // ─── empty state ─────────────────────────────────────────────────────
  function hideEmpty() {
    const e = document.getElementById("empty");
    if (e) e.remove();
  }
  function restoreEmpty() {
    if (document.getElementById("empty")) return;
    const e = document.createElement("div");
    e.id = "empty";
    e.className = "empty";
    e.innerHTML = `
      <p class="kicker"><span class="kicker-dot"></span>ready</p>
      <h1 class="hed">Two open-source LLMs.<br>One bare-metal node.<br>No GPU.</h1>
      <p class="sub">Type below to chat. Pick a model in the top bar — your choice persists across page reloads. History lives in Redis for 24 hours.</p>
    `;
    thread.prepend(e);
  }

  // ─── DOM helpers ─────────────────────────────────────────────────────
  function el(tag, cls, text) {
    const e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function addUserTurn(text) {
    hideEmpty();
    const turn = el("article", "turn user");
    const bubble = el("div", "bubble", text);
    turn.append(bubble);
    thread.append(turn);
    scrollEnd();
    return turn;
  }

  function addAssistantTurn(model) {
    hideEmpty();
    const turn = el("article", "turn assistant");
    const bubble = el("div", "bubble cursor");
    turn.append(bubble);
    const meta = el("div", "meta");
    const badge = el("span", "badge", model);
    const sep = el("span", "sep", "·");
    const stat = el("span", "stat", "thinking…");
    meta.append(badge, sep, stat);
    turn.append(meta);
    thread.append(turn);
    scrollEnd();
    return { turn, bubble, stat };
  }

  function scrollEnd() {
    requestAnimationFrame(() => {
      thread.scrollTop = thread.scrollHeight;
    });
  }

  function renderMarkdown(node) {
    const src = node.textContent;
    if (typeof marked === "undefined" || typeof DOMPurify === "undefined") return;
    const html = DOMPurify.sanitize(
      marked.parse(src, { gfm: true, breaks: false }),
      { ADD_ATTR: ["target", "rel"] }
    );
    node.innerHTML = html;
    node.classList.add("md");
    node.querySelectorAll("a").forEach(a => {
      a.setAttribute("target", "_blank");
      a.setAttribute("rel", "noopener noreferrer");
    });
  }

  // ─── load existing history ───────────────────────────────────────────
  async function loadHistory() {
    try {
      const res = await fetch(`/api/history?session_id=${encodeURIComponent(sessionId)}`);
      if (!res.ok) return;
      const data = await res.json();
      const turns = data.turns ?? [];
      if (turns.length === 0) return;
      hideEmpty();
      for (const t of turns) {
        if (t.role === "user") {
          addUserTurn(t.content);
        } else if (t.role === "assistant") {
          const { bubble, stat } = addAssistantTurn(t.model || activeModel);
          bubble.classList.remove("cursor");
          bubble.textContent = t.content;
          stat.textContent = "done";
          renderMarkdown(bubble);
        }
      }
    } catch (e) {
      console.warn("history load failed", e);
    }
  }

  // ─── host info → footer ──────────────────────────────────────────────
  async function loadHostInfo() {
    try {
      const res = await fetch("/api/host-info");
      if (!res.ok) return;
      const d = await res.json();
      if (d.cpu) {
        hostEl.textContent = `running on ${d.cpu.toLowerCase()} · ${(d.inference || "cpu").toLowerCase()} inference · no gpu`;
      }
    } catch { /* keep static fallback */ }
  }

  // ─── send ────────────────────────────────────────────────────────────
  async function send(message) {
    const model = activeModel;
    sendBtn.disabled = true;
    addUserTurn(message);
    const { turn, bubble, stat } = addAssistantTurn(model);

    const started = performance.now();
    let firstTokenAt = null;
    let tokens = 0;

    try {
      const res = await fetch(
        `/api/chat?session_id=${encodeURIComponent(sessionId)}&model=${encodeURIComponent(model)}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ message }),
        }
      );
      if (!res.ok || !res.body) throw new Error(`HTTP ${res.status}`);
      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let buf = "";

      while (true) {
        const { value, done } = await reader.read();
        if (done) break;
        buf += decoder.decode(value, { stream: true });
        let idx;
        while ((idx = buf.indexOf("\n\n")) !== -1) {
          const frame = buf.slice(0, idx);
          buf = buf.slice(idx + 2);
          for (const line of frame.split("\n")) {
            if (!line.startsWith("data:")) continue;
            const payload = line.slice(5).trim();
            if (payload === "[DONE]") continue;
            let obj;
            try { obj = JSON.parse(payload); } catch { continue; }
            if (obj.event === "delta" && obj.content) {
              if (firstTokenAt == null) firstTokenAt = performance.now();
              bubble.textContent += obj.content;
              tokens += 1;
              if (tokens % 4 === 0) {
                const secs = (performance.now() - firstTokenAt) / 1000;
                if (secs > 0.25) stat.textContent = `${(tokens / secs).toFixed(1)} tok/s`;
              }
              scrollEnd();
            } else if (obj.event === "error") {
              throw new Error(obj.message ?? `upstream ${obj.status ?? "error"}`);
            }
          }
        }
      }

      const totalSecs = (performance.now() - started) / 1000;
      const genSecs = firstTokenAt ? (performance.now() - firstTokenAt) / 1000 : totalSecs;
      const rate = genSecs > 0 ? tokens / genSecs : 0;
      stat.textContent = `${rate.toFixed(1)} tok/s · ${totalSecs.toFixed(1)}s`;
      renderMarkdown(bubble);
    } catch (e) {
      turn.classList.remove("assistant");
      turn.classList.add("error");
      bubble.textContent = e.message;
    } finally {
      bubble.classList.remove("cursor");
      sendBtn.disabled = false;
      msgInput.focus();
    }
  }

  composer.addEventListener("submit", (e) => {
    e.preventDefault();
    const message = msgInput.value.trim();
    if (!message) return;
    msgInput.value = "";
    send(message);
  });

  resetBtn.addEventListener("click", async () => {
    if (!confirm("Clear this conversation?")) return;
    await fetch(`/api/reset?session_id=${encodeURIComponent(sessionId)}`, { method: "POST" });
    thread.replaceChildren();
    restoreEmpty();
  });

  // ─── API reference modal ─────────────────────────────────────────────
  const apiModal = document.getElementById("api-modal");
  const apiOpen  = document.getElementById("api-open");
  const apiClose = document.getElementById("api-close");

  function substituteBase(node) {
    const base = `${location.protocol}//${location.host}`;
    node.querySelectorAll(".snippet code").forEach(c => {
      c.textContent = c.textContent
        .replaceAll("${BASE}", base)
        .replaceAll("${SESSION}", sessionId);
    });
  }

  function execCopy(text) {
    // Plain-HTTP fallback. The textarea must live inside the open <dialog>,
    // otherwise the modal's focus trap prevents selection from sticking.
    const host = apiModal.querySelector(".modal-card") || document.body;
    const ta = document.createElement("textarea");
    ta.value = text;
    ta.readOnly = true;
    ta.setAttribute("aria-hidden", "true");
    Object.assign(ta.style, {
      position: "fixed",
      top: "0",
      left: "0",
      width: "1px",
      height: "1px",
      padding: "0",
      border: "0",
      opacity: "0",
      pointerEvents: "none",
    });
    host.appendChild(ta);
    ta.focus({ preventScroll: true });
    ta.select();
    ta.setSelectionRange(0, text.length);
    let ok = false;
    try { ok = document.execCommand("copy"); } catch { ok = false; }
    ta.remove();
    return ok;
  }

  function copyText(text, btn) {
    const flash = (label, ok) => {
      btn.classList.toggle("ok", !!ok);
      btn.textContent = label;
      setTimeout(() => { btn.classList.remove("ok"); btn.textContent = "copy"; }, 1400);
    };

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text)
        .then(() => flash("copied", true))
        .catch(() => flash(execCopy(text) ? "copied" : "blocked", execCopy(text)));
      return;
    }
    flash(execCopy(text) ? "copied" : "blocked", execCopy(text));
  }

  function attachCopyButtons() {
    apiModal.querySelectorAll(".snippet").forEach(pre => {
      if (pre.querySelector(".copy")) return;
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "copy";
      btn.textContent = "copy";
      btn.addEventListener("click", () => {
        const text = pre.querySelector("code").textContent;
        copyText(text, btn);
      });
      pre.append(btn);
    });
  }

  substituteBase(apiModal);
  attachCopyButtons();

  const sessionIdEl   = document.getElementById("session-id");
  const sessionCopyEl = document.getElementById("session-copy");
  if (sessionIdEl)   sessionIdEl.textContent = sessionId;
  if (sessionCopyEl) sessionCopyEl.addEventListener("click", () => copyText(sessionId, sessionCopyEl));

  apiOpen.addEventListener("click", () => apiModal.showModal());
  apiClose.addEventListener("click", () => apiModal.close());
  apiModal.addEventListener("click", (e) => {
    if (e.target === apiModal) apiModal.close();
  });

  loadHistory();
  loadHostInfo();
})();
