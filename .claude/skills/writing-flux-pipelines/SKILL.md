---
name: writing-flux-pipelines
description: Use when building a flux-pipelines (PhysicsX AI-Workbench) pipeline or component from scratch - creating projects, reusing/writing quark components, wiring pipeline YAML + conf, verifying locally one component at a time, and running on the cloud. Triggers on "flux-pipelines", "pipeline", "component".
version: 0.4.0
---

# Writing a flux-pipelines pipeline from scratch

`flux-pipelines` (PhysicsX AI-Workbench CLI): **components** (quark Python steps)
wired into **pipelines** (YAML DAGs), configured by **conf**, sharing code via
**libraries**. Data flows through named **ports**, each backed by a
**Materializer** (`load`/`save`/`schema`/`from_dict`/`to_dict`).

**Don't reinvent the structure - derive it from the shipped examples:**

- **Easy:** the `hello_world` component + `pipelines/hello_world.yaml` +
  `conf/hello_world/example.yaml` (single side-effect component).
- **Advanced:** scaffold `e2e_training` and read it -
  `flux-pipelines pipeline create -n ref -t e2e_training` - a multi-component DAG
  showing artifact passing (`mapping: <port>: <producer>.<port>`), per-component
  `profile`s, and reuse of prebuilt component images. Delete `ref` after
  studying (it also scaffolds the referenced components into `components/`).

These are the source of truth for the quark contract, custom materializers,
`pyproject.toml` entry points, pipeline YAML, and conf layout. Copy from them.

## Process

1. **Reuse first.** `flux-pipelines component list`, `flux-pipelines templates show`,
   and existing/prebuilt components. Only write new components for new logic:
   `flux-pipelines component create -n <name> -t <template> -d cpu`.
2. **Wire** the pipeline YAML + conf by mirroring the examples; register in `pipelines.json`.
3. **Verify locally, one component at a time** (below). When the whole pipeline
   passes locally, **PING THE USER**.
4. **Cloud run** the images; when it succeeds, **PING THE USER** again.

## Run a component locally (the real cluster entry point)

```bash
uv run --no-sync --project components/<c> python -m physicsx.quark -c <name> -f payload.json
# payload.json = one key per port (inputs AND outputs); each value is that port's
# materializer config (for DictMaterializer the value is the dict itself).
# Use --list / --schema to inspect.
```

Commit a `scripts/run_pipeline_locally.py` that chains the stages (each stage's
output file feeds the next stage's input) so the local run is reproducible:

```python
#!/usr/bin/env python3
"""Run this project's pipeline locally, one component at a time. Edit STAGES."""
import json, os, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "output"; OUT.mkdir(parents=True, exist_ok=True)

# In execution order. payload = one key per port; point artifact ports at files
# under OUT so a producer's output becomes the next stage's input.
STAGES = [
    {"dir": "comp-a", "name": "comp-a",
     "payload": {"config": {}, "result": {"path": str(OUT / "a.txt")}}},
    {"dir": "comp-b", "name": "comp-b",
     "payload": {"config": {}, "data": {"path": str(OUT / "a.txt")},
                 "result": {"path": str(OUT / "b.txt")}}},
]

for s in STAGES:
    pf = OUT / f"{s['name']}.payload.json"; pf.write_text(json.dumps(s["payload"]))
    env = os.environ.copy(); env.pop("VIRTUAL_ENV", None)  # use the component's .venv
    print(f"==> {s['name']}")
    subprocess.run(["uv", "run", "--no-sync", "--project", f"components/{s['dir']}",
                    "python", "-m", "physicsx.quark", "-c", s["name"], "-f", str(pf)],
                   cwd=ROOT, env=env, check=True)
print("==> local pipeline OK - PING THE USER")
```

## Cloud run (airgap mode)

```bash
(cd components/<c> && flux-pipelines component build)   # in-cluster build + push
flux-pipelines pipeline run -p <name> -e <exp> --data-path conf/<name>/example.yaml --await
```

Input files/data must live on the shared `/flux/vault` mount (pods don't have
the repo) - stage them there and use absolute paths in conf.
