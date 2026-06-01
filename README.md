# Hindsight SDK for Workshop

This SDK runs [Hindsight](https://github.com/vectorize-io/hindsight) inside a
[Workshop](https://ubuntu.com/workshop). Hindsight is an agent-memory system
that retains, recalls, and reflects on world facts, experiences, and mental
models. The SDK serves the Hindsight REST API and web UI and installs the
Python and Node client libraries for building against them. Your memory data
and LLM provider configuration are persisted on the host, so they survive
workshop updates.

---

## Reference workshop

A minimal workshop:

```yaml
# workshop.yaml
name: hindsight-demo
base: ubuntu@24.04
sdks:
  - name: hindsight
    channel: latest/stable
  - name: system
    plugs:
      hindsight-api:
        interface: tunnel
        endpoint: localhost:8888
      hindsight-webui:
        interface: tunnel
        endpoint: localhost:9999
```

The two tunnel plugs on the `system` SDK auto-connect to the slots this SDK
exposes, so the API (`http://localhost:8888`) and web UI
(`http://localhost:9999`) are reachable from the host after `workshop launch`.

---

## Using the SDK

### Prerequisites, project layout

1. No prerequisite SDKs are required. To run Hindsight keylessly against a local
   model, run [Ollama](https://ollama.com) (or LM Studio) on the host and wire
   it in through the `llm-endpoint` tunnel (see below).
2. No specific project layout is needed.
3. On launch the SDK installs the Hindsight server (`hindsight-all`) and the
   Python and Node clients pinned to this channel's version, seeds an editable
   provider config at `~/.hindsight/server.env`, and starts two systemd user
   services: `hindsight-api` (REST API on `:8888`) and `hindsight-webui` (web UI
   on `:9999`).

### Configure an LLM provider

Hindsight needs an LLM to reflect on memories. There is no Workshop "secret"
interface, so credentials are supplied the workshop-native way: configured
**once** into a file on the persisted `hindsight-data` mount:

```bash
workshop shell
# Edit ~/.hindsight/server.env, then apply it:
exit
workshop refresh
```

Cloud provider:

```bash
# ~/.hindsight/server.env
HINDSIGHT_API_LLM_PROVIDER=openai
HINDSIGHT_API_LLM_API_KEY=sk-...
HINDSIGHT_API_LLM_MODEL=gpt-4o-mini
```

Keyless local provider, reached over the `llm-endpoint` tunnel (no API key):

```bash
# ~/.hindsight/server.env
HINDSIGHT_API_LLM_PROVIDER=ollama
HINDSIGHT_API_LLM_BASE_URL=http://127.0.0.1:11434/v1
HINDSIGHT_API_LLM_MODEL=llama3.1
```

Because the file lives on the `hindsight-data` mount, it is written once and
reused across every `workshop refresh`.

### Use the memory store

From the host, once the workshop is up:

```bash
curl http://localhost:8888/        # REST API
# open http://localhost:9999 in a browser for the web UI
```

From inside the workshop, the clients and the embedded CLI are on `PATH`:

```bash
workshop shell
hindsight-embed --help                  # local CLI against the running server
python3 -c "import hindsight_client"     # Python client
node   -e "require('@vectorize-io/hindsight-client')"  # Node client
```

### Verify from the command line

```bash
workshop info                       # health line shows the API/Web UI URLs
workshop shell
systemctl --user status hindsight-api hindsight-webui
hindsight-api --version
```

---

## Plugs (resources this SDK consumes)

### `hindsight-data`

- Interface: `mount`
- Workshop target: `/home/workshop/.hindsight`
- Purpose: persists the memory database (embedded Postgres / `pg0`), profiles,
  and the `server.env` provider configuration across workshop updates.

### `pip-cache`

- Interface: `mount`
- Workshop target: `/home/workshop/.cache/pip`
- Purpose: caches Python wheels so re-installing the server on update is fast.

### `npm-cache`

- Interface: `mount`
- Workshop target: `/home/workshop/.npm`
- Purpose: caches npm downloads for the web UI and Node client.

### `llm-endpoint`

- Interface: `tunnel`
- Endpoint: `localhost:11434`
- Purpose: optional. Lets the server reach a host-side LLM (Ollama/LM Studio) so
  Hindsight can run without a cloud API key. Connect it manually after refresh:
  `workshop connect <workshop>/hindsight:llm-endpoint <workshop>/system:llm-endpoint`.

## Slots (resources this SDK provides)

### `hindsight-api`

- Interface: `tunnel`
- Endpoint: `localhost:8888`
- Purpose: exposes the Hindsight REST API to the host.

### `hindsight-webui`

- Interface: `tunnel`
- Endpoint: `localhost:9999`
- Purpose: exposes the Hindsight web UI (control plane) to the host.

---

## Documentation and guidance

- [Hindsight documentation](https://hindsight.vectorize.io/)
- [Hindsight on GitHub](https://github.com/vectorize-io/hindsight)
- [Workshop documentation](https://documentation.ubuntu.com/workshop/)

---

## Community and support

- Hindsight community:
  [GitHub issues and discussions](https://github.com/vectorize-io/hindsight/issues)
- Workshop forum:
  [Discourse](https://discourse.ubuntu.com/)
- Please review our
  [Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct) before
  participating.

---

## Contributions

All contributions, including code, documentation updates, and issue reports,
are welcome!

- See `CONTRIBUTING.md` for guidelines.
- Open issues or pull requests on the official repository.

---

## License and copyright

Copyright 2026 Canonical Ltd.

This SDK is licensed under the
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Hindsight is licensed under the
[Apache License 2.0](https://github.com/vectorize-io/hindsight/blob/main/LICENSE).
