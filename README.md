# dashr-nova-policies

Authorization rules for dashr-nova, published as an OPA bundle and loaded by
the platform OPA server (`policy` namespace, dashr-platform-gitops). Policy
changes ship independently of the application: no app build or rollout.

```
policy/                   the bundle
  .manifest               roots: ["dashr/authz"], the only paths this bundle may own
  dashr/authz/*.rego      rules, queried at /v1/data/dashr/authz/allow
  dashr/authz/*_test.rego tests (excluded from the bundle)
.github/workflows/ci.yaml lint, test, build, push
```

## Contract with dashr-nova

dashr-nova (`lib/opa.ts`) sends `{"input": {...}}` and treats anything other
than `result: true` as deny, including OPA errors. A policy that stops
matching the app's input therefore locks users out rather than letting them in.

- Only add input fields. To rename one, accept both names, release the app,
  then drop the old name.
- Add a test for every input shape the app sends.

## Develop

```bash
make test     # fmt check, opa check --strict, tests, 100% coverage
make build    # bundle.tar.gz, as CI builds it
make fmt      # rewrite files with opa fmt
```

`make` uses a local `opa` if installed, otherwise the `openpolicyagent/opa` image.

Try a decision against a built bundle:

```bash
opa eval -b bundle.tar.gz -I 'data.dashr.authz.allow' <<< '{"user":{"roles":["researcher"]},"action":"read"}'
```

## Release

| Event | Published as | Picked up by |
|---|---|---|
| Pull request | nothing (tests only) | |
| Merge to `main` | `ghcr.io/chandrakaladhar/dashr-nova-policies:main` and `:sha-<commit>` | local clusters, within about a minute |
| Tag `v1.2.3` | `:1.2.3` | production, after bumping `opa_bundle_dashr_nova` in `clusters/production/cluster-vars.yaml` |

OPA polls the registry and activates a new bundle without restarting. It keeps
serving the last good bundle if a download fails. Check what is live:

```bash
kubectl -n policy port-forward svc/opa 8181:8181
curl -s localhost:8181/v1/status | jq '.result.bundles'
```

The GHCR package must be readable by the cluster. Either make the package
public (Package settings → Change visibility), or give OPA registry
credentials (see the OPA section of the dashr-platform-gitops README).
