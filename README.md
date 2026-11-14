# 🐦 Colab LLMs — Claude-class agentic coding, for $0

**This project runs frontier-quality coding models inside an agentic LLM harness (OpenCode) on
free Google Colab hardware — with the goal of matching what closed models like Claude charge
$15–20/month for.**

Closed frontier models set the bar for agentic coding: reading whole repos, planning multi-step
tasks, editing files, running tools, recovering from their own mistakes. That ability normally
comes with a subscription and a cloud bill. This project's bet: an open-weight model with a
strong coding pedigree, served properly on a free T4, inside an agentic harness, gets you close
enough to that experience to do real work — at $0.

```
┌─────────────────────┐        ┌────────────────────────────────┐        ┌─────────────────┐
│  Your laptop        │        │  Free Google Colab T4 (GPU)    │        │  OpenCode /     │
│  (no GPU needed)    │◄─HTTPS─►│  Ollama / llama.cpp serving an │◄─HTTPS─►│  Cursor / Cline │
│                     │  tunnel │  open coding model + API key   │  API    │  agentic tools  │
└─────────────────────┘        └────────────────────────────────┘        └─────────────────┘
```

- **No local GPU needed** — a plain laptop is the thin client; all compute is Colab's free T4
- **OpenAI-compatible API** — works with OpenCode, Cursor, Cline, Aider, or any tool that speaks
  chat-completions
- **Agentic-ready** — up to **128k-token context** (Bonsai) so the agent can hold real codebases,
  system prompts, tool outputs, and multi-step history in one request
- **Secured public API** — each session generates an **API key**; the tunnel is useless without it
- **One-click client setup** — a `.bat` that injects the provider (URL + key) into OpenCode

## Repository layout

```
colab model/
├── README.md                                 ← you are here (kept outside the model folders)
├── setup-opencode_…ollama.bat                ← shared OpenCode setup — works for BOTH models
├── Ornith-1.5-35B-A3B/                       ← folder: everything for model 1
│   └── Ornith-1.5-35B-A3B_Q4_K_M_ollama.ipynb
└── Ternary-Bonsai-2-27B/                     ← folder: everything for model 2
    ├── Ternary-Bonsai-2-27B_Q2_0_llama-cpp_v3.ipynb     (7.63 GB packing)
    └── Ternary-Bonsai-2-27B_PTQ1_0_little.ipynb         (5.95 GB packing — "little")
```

## Files

| File | What it is |
|---|---|
| `Ornith-1.5-35B-A3B/Ornith-1.5-35B-A3B_Q4_K_M_ollama.ipynb` | Complete notebook: installs Ollama, pulls the model, starts the server (32k context), opens the public API tunnel |
| `Ternary-Bonsai-2-27B/Ternary-Bonsai-2-27B_Q2_0_llama-cpp_v3.ipynb` | Complete notebook: **prebuilt** llama-server (PrismML fork + bundled CUDA libs, no compile), ternary model **100% on GPU**, **128K context**, secured public API, speed benchmark, optional speculative-decoding auto-tune, API-key fix cell, keep-alive monitor |
| `Ternary-Bonsai-2-27B/Ternary-Bonsai-2-27B_PTQ1_0_little.ipynb` | Same pipeline as the v3 notebook, for the **little** packing (PTQ1_0, 5.95 GB): ~2 GB less VRAM → more headroom for context/KV on the T4 |
| `setup-opencode_Ornith-1.5-35B-A3B_Q4_K_M_ollama.bat` | One-click Windows helper for **all three notebooks**: paste the tunnel URL → paste the API key → pick which model is running (Ornith / Bonsai / both) → writes the provider into OpenCode's config (merges, never overwrites) |

## The models

### Model 1: Ornith-1.5-35B-A3B (Ollama)

- **[ornith-ai/Ornith-1.5-35B-A3B](https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B)** — a
  35B-total / ~3B-active MoE (Qwen3.5 architecture) tuned for coding, with strong
  coding-benchmark results for its size class
- **Q4_K_M quant** (~21.7 GB) — best quality that still runs on a T4
- Native context 262k, served at **32,768** (`OLLAMA_CONTEXT_LENGTH`)
- **~12–14 tok/s** on the free T4 — fast enough for agentic loops (plan → edit → test)

### Model 2: Ternary-Bonsai-2-27B (llama.cpp)

- **[prism-ml/Ternary-Bonsai-2-27B-gguf](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf)**
  — a dense 27B hybrid-attention model (base: Qwen3.8-27B) re-trained/re-quantized into
  **ternary weights** ({−1, 0, +1}) — 98.2% of the full-precision model's benchmark average at
  ~1/9th the size
- Two packings, quality-identical benchmarks (coding ~level with the FP model, LiveCodeBench
  90.07, agentic tool-calling BFCL v3 74.92):
  - **Q2_0** (7.63 GB) — `…_Q2_0_llama-cpp_v3.ipynb`
  - **PTQ1_0 "little"** (5.95 GB, 1.75 bpw) — `…_PTQ1_0_little.ipynb`; the smaller footprint
    buys VRAM headroom, which is what makes **128K context + q8_0 KV cache** fit on the T4
- Served by a **prebuilt PrismML-fork llama-server** — stock llama.cpp cannot run these ternary
  tensors, and the fork ships binaries (no compiling)
- **Reasoning model** — thinks by default; the notebooks let you set `THINKING = False` for
  faster coding replies
- Served id: `bonsai-2-27b` · context up to **131,072** (128K; native 262k)

## Quick start

1. In [Google Colab](https://colab.research.google.com): **File → Upload notebook** → pick the
   `.ipynb` for the model you want (from its folder above)
2. **Runtime → Change runtime type → T4 GPU**
3. Run the cells top to bottom — the tunnel cell prints a `https://…trycloudflare.com` URL and
   the **API key** (plus a ready-to-paste OpenCode config)
4. On Windows, double-click the `.bat` at the repo root: paste the **URL**, paste the **API
   key**, and pick **which model is running** (`1` Ornith / `2` Bonsai / `3` both)
5. In OpenCode, select the matching provider (e.g. **"Bonsai 2 27B (Colab)"**)
6. Other OpenAI-compatible clients: `base_url = https://<tunnel>/v1`, `api_key = <the printed
   key>`, model id `bonsai-2-27b` (Bonsai) or the Ornith model tag

## Agentic use notes (OpenCode)

- Start the agent in a **fresh session per task** — agentic context grows fast (system prompt +
  file contents + tool output)
- Bonsai serves 128k, but very large prompts still **process slowly** on a free T4 — compact or
  start fresh when a session bloats; Ornith's practical limit is ~30k tokens
- Long file reads are the main context consumer — prefer targeted reads over whole-file dumps
- Run the **keep-alive cell** (last optional cell in the Bonsai notebooks) if you leave the
  session unattended — it restarts the server automatically if it dies

## File naming convention

```
<model-name>_<parameters>_<quantization>_<runner>.<ext>
```

Examples:

- `Ornith-1.5-35B-A3B_Q4_K_M_ollama.ipynb` — Ornith 35B (3B active), Q4_K_M quant, **Ollama**
- `Ternary-Bonsai-2-27B_Q2_0_llama-cpp_v3.ipynb` — Bonsai 27B (dense), Q2_0 ternary quant, **llama.cpp** (v3)
- `Ternary-Bonsai-2-27B_PTQ1_0_little.ipynb` — Bonsai 27B (dense), PTQ1_0 ternary quant, **llama.cpp**, "little" = the 5.95 GB packing

The naming (one folder per model) makes it trivial to add more models/quants/runners as
separate, self-contained notebooks.

## Troubleshooting

| Symptom | Cause & fix |
|---|---|
| `Invalid API Key` | The server only accepts the key it was started with — run the **FIX / CHANGE THE API KEY** cell in the Bonsai notebook (keeps the tunnel URL), then re-run the `.bat` with the printed key |
| `HTTP 502` from the tunnel | llama-server on the VM died — run the keep-alive cell or restart the server cell; the tunnel URL survives, only the server needs restarting |
| OOM / `cudaMalloc failed` at startup | Context too big for the VRAM budget — lower `CTX` in cell 1 (each 32k of fp16 KV ≈ 2 GB) or keep the q8_0 KV flags (`-ctk q8_0 -ctv q8_0`) |
| `HTTP 403` on the Ornith API | Ollama rejects the tunnel's `Host` header — the tunnel cell already passes `--http-host-header="localhost:11434"` (per [Ollama FAQ](https://docs.ollama.com/faq.md)) |
| `request exceeds the available context size` (Ornith) | Server restarted without the context env var — re-run cell 4 (`OLLAMA_CONTEXT_LENGTH=32768`) |
| `…/v1/v1` in the config | Pasted a URL that already ended in `/v1` — the `.bat` strips it before appending |

## Operational notes

- **Free tier:** Colab preempts sessions — everything on the VM (model included) is lost.
  Re-running the notebooks brings it back in ~5–10 min (no compiling anywhere).
- **Tunnel URL rotates** every time the tunnel cell re-runs or the session restarts → re-run
  the `.bat`. The **API key survives server restarts** within a session (it lives in
  `config.json`); only a NEW Colab session generates a different one.
- **Auth is required** on the Bonsai API — the URL alone is not enough; treat both as secrets.
- Keep the Colab browser tab open; idle sessions get disconnected.

## License

Model weights: MIT (per the model repos). Notebook/scripts in this repo: MIT.
