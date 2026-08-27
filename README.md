# Hindsight SDK for Workshop

This SDK runs [Hindsight](https://github.com/vectorize-io/hindsight) inside a
[Workshop](https://ubuntu.com/workshop). Hindsight is an agent-memory system
that retains, recalls, and reflects on world facts, experiences, and mental
models. The SDK ships the Hindsight API server and Hindsight Control Plane
built from upstream source. Your memory data and LLM provider configuration
are persisted on the host, so they survive workshop updates.

---

## Reference workshop

A minimal workshop:

```yaml
# workshop.yaml
name: hindsight-demo
base: ubuntu@24.04
sdks:
  - name: node
    channel: 24/stable
  - name: hindsight
    channel: latest/stable
  - name: system
    plugs:
      hindsight-api:
        interface: tunnel
        endpoint: localhost:8888
      hindsight-control-plane: # requires node SDK
        interface: tunnel
        endpoint: localhost:9999
```

The two tunnel plugs on the `system` SDK auto-connect to the slots this SDK
exposes, so the API (`http://localhost:8888`) and Control Plane
(`http://localhost:9999`) are reachable from the host after `workshop launch`.

---

## Using the SDK

### Prerequisites, project layout

1. Add the `node` SDK to the same workshop. Hindsight's Control Plane is built
   into this SDK, but it uses the Node runtime provided by that SDK. To run
   Hindsight keylessly against a local model, run [Ollama](https://ollama.com)
   (or LM Studio) on the host and wire it in through the `llm-endpoint` tunnel
   (see below).
2. No specific project layout is needed.
3. The SDK payload contains Hindsight's `hindsight-api` server package and the
   built `hindsight-control-plane` Next.js standalone app, both pinned to this
   channel's version. On launch it seeds an editable provider config at
   `~/.hindsight/server.env` and starts two systemd user services:
   `hindsight-api` (REST API on `:8888`) and `hindsight-control-plane`
   (Control Plane on `:9999`).

### Configure an LLM provider

By default, this SDK starts Hindsight with `HINDSIGHT_API_LLM_PROVIDER=none`.
That is useful when Hermes owns the conversational LLM and uses Hindsight as a
memory backend: retain stores chunks and recall works, while Hindsight-only
LLM operations such as `reflect` are disabled.

If you want Hindsight itself to extract facts, reflect, or refresh mental
models, configure an LLM provider **once** in the persisted
`hindsight-data` mount:

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
HINDSIGHT_API_LLM_MODEL=gemma3:12b
```

Because the file lives on the `hindsight-data` mount, it is written once and
reused across every `workshop refresh`.

### Use the memory store

From the host, once the workshop is up and its tunnels are connected:

```bash
curl http://localhost:8888/        # REST API
# open http://localhost:9999 in a browser for the Control Plane
```

From inside the workshop, the server tools are on `PATH`:

```bash
workshop shell
hindsight-api --help
hindsight-admin --help
hindsight-worker --help
hindsight-control-plane --help
```

### Verify from the command line

```bash
workshop info                       # health line shows API/Control Plane URLs
workshop shell
systemctl --user status hindsight-api hindsight-control-plane
hindsight-api --version
```

---

## Plugs (resources this SDK consumes)

### `hindsight-data`

- Interface: `mount`
- Workshop target: `/home/workshop/.hindsight`
- Purpose: persists the memory database (embedded Postgres / `pg0`), profiles,
  and the `server.env` provider configuration across workshop updates.

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

### `hindsight-control-plane`

- Interface: `tunnel`
- Endpoint: `localhost:9999`
- Purpose: exposes the Hindsight Control Plane to the host.

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
