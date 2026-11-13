# 🐦 Colab Models — self-hosted LLM APIs on free Google Colab

Run large open-weight models on a free **Colab T4 GPU** and expose them as a
public, OpenAI-compatible API (via a Cloudflare quick tunnel) that any client
can use — [OpenCode](https://opencode.ai), Cursor, Cline, scripts using the
`openai` SDK, etc.

## Files

| File | What it is |
|---|---|
| `Ornith-1.5-35B-A3B_Q4_K_M_ollama.ipynb` | Complete notebook: installs Ollama, pulls the model, starts the server, opens the public API tunnel |
| `setup-opencode_Ornith-1.5-35B-A3B_Q4_K_M_ollama.bat` | One-click Windows helper: paste the tunnel URL → writes the provider into OpenCode's config (merges, never overwrites) |

## File naming convention

```
<model-name>_<parameters>_<quantization>_<runner>.<ext>
```

Examples:

- `Ornith-1.5-35B-A3B_Q4_K_M_ollama.ipynb` — Ornith 35B (3B active), Q4_K_M quant, served by **Ollama**
- `Ornith-1.5-35B-A3B_Q3_K_M_llama-cpp.ipynb` — same model, Q3_K_M quant, served by **llama.cpp** *(future)*

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
5. Other OpenAI-compatible clients: `base_url = https://<tunnel>/v1`, `api_key = ollama` (any non-empty string).

## Model

- **Model:** [ornith-ai/Ornith-1.5-35B-A3B](https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B) (Qwen3.5-MoE architecture, 35B total / ~3B active params)
- **Quant:** Q4_K_M (~21.7 GB)
- **Native context:** 262,144 tokens — served at **32,768** (`OLLAMA_CONTEXT_LENGTH`); keep client sessions under ~30k
- **Speed:** ~12–14 tok/s on a free T4 (hybrid GPU/CPU offload; ~80% of layers on GPU)

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
