# 🐦 Colab LLMs — Claude-class agentic coding, for $0

**This project runs frontier-quality coding models inside an agentic LLM harness (OpenCode) on
free Google Colab hardware — with the goal of matching what closed models like Claude charge
$15–20/month for.**

Closed frontier models set the bar for agentic coding: reading whole repos, planning multi-step
tasks, editing files, running tools, recovering from their own mistakes. That ability normally
comes with a subscription and a cloud bill. This project's bet: an open-weight MoE model with a
strong coding pedigree, served properly on a free T4, inside an agentic harness, gets you close
enough to that experience to do real work — at $0.

```
┌─────────────────────┐        ┌──────────────────────────────┐        ┌─────────────────┐
│  Your laptop        │        │  Free Google Colab T4 (GPU)  │        │  OpenCode /     │
│  (no GPU needed)    │◄─HTTPS─►│  Ollama serving an open      │◄─HTTPS─►│  Cursor / Cline │
│                     │ tunnel  │  coding MoE model            │  API    │  agentic tools  │
└─────────────────────┘        └──────────────────────────────┘        └─────────────────┘
```

- **No local GPU needed** — a plain laptop is the thin client; all compute is Colab's free T4
- **OpenAI-compatible API** — works with OpenCode, Cursor, Cline, Aider, or any tool that speaks
  chat-completions
- **Agentic-ready** — 32k-token context so the agent can hold real codebases, system prompts,
  tool outputs, and multi-step history in one request
- **One-click client setup** — a `.bat` that injects the provider into OpenCode

## Files

| File | What it is |
|---|---|
| `Ornith-1.5-35B-A3B_Q4_K_M_ollama.ipynb` | Complete notebook: installs Ollama, pulls the model, starts the server, opens the public API tunnel |
| `setup-opencode_Ornith-1.5-35B-A3B_Q4_K_M_ollama.bat` | One-click Windows helper: paste the tunnel URL → writes the provider into OpenCode's config (merges, never overwrites) |

## The model

- **[ornith-ai/Ornith-1.5-35B-A3B](https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B)** — a
  35B-total / ~3B-active MoE (Qwen3.5 architecture) tuned for coding, published with strong
  coding-benchmark results for its size class
- **Q4_K_M quant** (~21.7 GB) — best quality that still runs on a T4
- **Native context 262k tokens**, served at **32,768** (`OLLAMA_CONTEXT_LENGTH`) — keep agentic
  sessions under ~30k tokens, then start fresh or compact
- **~12–14 tok/s** on the free T4 — fast enough for agentic loops (plan → edit → test), slow
  enough to be patient with big generations

## Quick start

1. In [Google Colab](https://colab.research.google.com): **File → Upload notebook** → pick the `.ipynb`
2. **Runtime → Change runtime type → T4 GPU**
3. Run the cells top to bottom:
   - Cell 2: GPU + disk check
   - Cell 3: Ollama install (~2 min)
   - Cell 4: start `ollama serve` with a 32k context window
   - Cell 5: pull the model (~22 GB, ~5–10 min, resumable)
   - Cell 6: load the model onto the GPU (~4–6 min, one-time)
   - Cell 7: start the Cloudflare quick tunnel → prints a `https://…trycloudflare.com` URL
   - Cell 8: end-to-end test of the public URL
4. On Windows, double-click the `.bat`, paste the tunnel URL — done.
   In OpenCode, select the provider **“Ornith 35B (Colab)”**.
5. Other OpenAI-compatible clients: `base_url = https://<tunnel>/v1`, `api_key = ollama`
   (any non-empty string).

## Agentic use notes (OpenCode)

- Start the agent in a **fresh session per task** — agentic context grows fast (system prompt +
  file contents + tool output), and the practical request limit is ~30k tokens
- Long file reads are the main context consumer — prefer targeted reads over whole-file dumps
- If a session stalls or the request-size error appears, compact or start a new session; the
  model reloads from disk in seconds (it stays hot on the GPU for 5 min between requests)
- Expect **~4–6 min** of model-load time on the very first request after the server restarts

## File naming convention

```
<model-name>_<parameters>_<quantization>_<runner>.<ext>
```

Examples:

- `Ornith-1.5-35B-A3B_Q4_K_M_ollama.ipynb` — Ornith 35B (3B active), Q4_K_M quant, served by **Ollama**
- `Ornith-1.5-35B-A3B_Q3_K_M_llama-cpp.ipynb` — same model, Q3_K_M quant, served by **llama.cpp** *(future)*

The naming makes it trivial to add more models/quant/runners (KAT-Coder, llama.cpp builds,
full-GPU quantizations) as separate, self-contained notebooks.

## Troubleshooting

| Symptom | Cause & fix |
|---|---|
| `HTTP 403` from the API | Ollama rejects the tunnel's `Host` header — the tunnel cell already passes `--http-host-header="localhost:11434"` (per [Ollama FAQ](https://docs.ollama.com/faq.md)) |
| `request exceeds the available context size (4096)` | Server restarted without the context env var — re-run cell 4 (`OLLAMA_CONTEXT_LENGTH=32768`) |
| `…/v1/v1` in the config | Pasted a URL that already ended in `/v1` — the `.bat` now strips it before appending |

## Operational notes

- **Free tier:** Colab preempts sessions — everything on the VM (model included) is lost.
  Re-running the pull cell after a restart starts a fresh ~22 GB download.
- **Tunnel URL rotates** every time the tunnel cell re-runs or the session restarts → re-run the `.bat`.
- **No auth** on the quick tunnel — treat the URL as a secret.
- Keep the Colab browser tab open; idle sessions get disconnected.

## License

Model weights: MIT (per the model repo). Notebook/scripts in this repo: MIT.
