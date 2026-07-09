# gitops-tenants

**The desired-state repo for the Kargo + Flux progressive-delivery demo** — the `podinfo`
app manifests + the tofu config that **Flux applies** to the cluster. **Kargo** promotes new
versions *into* this repo (a commit, or a PR for prod); Flux applies them. Kargo never
touches the cluster directly — **the commit here is the hand-off.**

> ⚠️ Demo / workshop repo — **generic content only** (podinfo + dev-mode OpenBao). No real
> infrastructure. `podinfo` and the trigger-repo tags stand in for "the thing being promoted."

## The loop
```
tag a trigger repo → Kargo Warehouse → Freight → Kargo promotes
  (writes config to OpenBao + updates a manifest here) → Flux applies → podinfo shows the version
```
- **`tenant-platform-module`** tags → the **fleet** demo
- **`tf-podinfo-module`** tags → the **infra** demo

## Two demos

| Demo | Stages | tofu run by | State | Prod gate |
|---|---|---|---|---|
| **Fleet** (`tenant-a/b/c`) | canary → prod | **Kargo natively** | **committed in git** → a bump shows a **destroy/replace in the PR** | per-tenant **PR** |
| **Infra** | `infra-demo` → `infra-prod` | demo: **Kargo natively** · prod: **Flux tofu-controller** | demo: **stateless** · prod: the **controller's Secret** (not git) | **PR** |

Both sit on a **shared platform** (installed once, Flux-managed): OpenBao, External-Secrets,
Reloader, cert-manager, ingress-nginx.

**Full step-by-step walkthroughs:** see `fleet-demo.md` / `infra-demo.md` in
[**kargo-demo-config**](https://github.com/himeshpanc/kargo-demo-config) (which also holds the
Kargo + Flux control-plane config that drives all this).

## Layout
```
platform/                  shared services — Flux HelmReleases + ClusterSecretStore + CA issuer
  addons/  config/
infra/                     infra-demo: tofu/ + app/ + kubeconfig
  prod/                    infra-prod: tofu/ + app/ + kubeconfig
fleet/tenants/{a,b,c}/     per-tenant: tofu/ (+ committed terraform.tfstate) + app/ + kubeconfig
clusters/kargo-tf-demo/    Flux bootstrap — the root/platform Kustomization definitions
```

## What a promotion writes here (the PR diff)
- **ExternalSecret** `remoteRef.key` → repointed to the new versioned OpenBao path *(this is what the prod PR gates — prod keeps serving the old version until merge)*.
- **Fleet only:** the **replica count** (`kustomization.yaml`) + the **committed `terraform.tfstate`** (fleet uses git as the tofu state backend → that's why the PR shows a destroy/replace).
- **Infra-prod:** only the ExternalSecret changes here; the tofu **state lives in the tofu-controller's Secret**, not this repo.

## GitOps wiring
A root **`cluster-config`** Kustomization (`clusters/kargo-tf-demo/`) bootstraps the platform;
the app Kustomizations (infra + fleet) and the Flux install are defined in **kargo-demo-config's
`flux-apps/`**. Bootstrap seed = Flux Operator + FluxInstance + the GitRepository + the root
Kustomization; everything else is Git-managed from there.
