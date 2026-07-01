# gitops-tenants (demo)

Generic GitOps repo for a Kargo + Flux progressive-promotion demo.

Each tenant "ring" holds a trivial, non-sensitive manifest: a `ConfigMap`
carrying a `version` value. Flux watches this repo and applies each ring's
manifests. Kargo (added later) promotes a new version ring-by-ring by
updating the pins here.

```
tenants/
  canary/   # first ring (1 pilot)   -> namespace: canary
  prod/     # everything else        -> namespace: prod
```

No real infrastructure or customer data — the ConfigMap value stands in for
"the thing that changed" so the promotion pipeline can be demonstrated safely.
