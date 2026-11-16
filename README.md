# fsr-agentic-assistant

One repository, two distributions with separate release cadences.

| Path | What | Published as |
|---|---|---|
| `framework/` | `fsr_playbooks`: playbook compiler, LLM co-authoring, MCP server tools | PyPI `fsr-playbooks` (tags `vX.Y.Z`) |
| `connector/` | the FortiSOAR Agentic Assistant connector and its dev/deploy loop | connector tgz (tags `connector-vX.Y.Z`) |

The connector depends on the framework at a pinned PyPI version for shipping
(`connector/connector-fsr-agentic-assistant/requirements.txt`) and on `./framework`
(editable) for development and tests, so both are tested together in every commit.

```
make setup             # the one dev env (connector/scripts/dev_env.sh; framework editable)
make verify            # framework gates + connector suite
make loop BOX=<alias>  # edit, test, push both trees to a lab box, live sanity
make fw-<target>       # any framework Makefile target
make conn-<target>     # any connector Makefile target
```

Framework location for scripts: `connector/scripts/framework_dir.sh` (one resolver).
Hygiene: `scripts/check_infra_leaks.py` runs in CI over the whole tree; lab-specific
patterns live in the gitignored `scripts/infra_patterns.local.json` overlay.
