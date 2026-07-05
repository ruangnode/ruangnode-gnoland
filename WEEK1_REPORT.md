# Week 1 Report — Gno.land Ambassador

**Ambassador:** ruangnode  
**Period:** 2026-06-16 → 2026-06-22  
**Submitted:** 2026-07-05

---

## Summary

This week focused on validator operations for the test13 network — setting up a node from scratch, getting active in the validator set, and documenting every issue encountered with actionable feedback for the core team.

---

## Activities

### 1. Validator Node Setup (test13)

- Spun up a test13 validator node from scratch to active (voting power 1)
- Spun up a second full node separately for testing and comparison
- Registered and configured validator profile on-chain via `gno.land/r/gnops/valopers`
- Documented **10 distinct issues** with error, root cause, resolution, and suggestion for each

**On-chain transactions:**

| Action | Block | Date | Explorer |
|--------|-------|------|----------|
| `Register` | 381402 | 2026-06-22 10:55 UTC+7 | [GnoScan](https://gnoscan.io/transactions/details?txhash=djH4sWX8UfPowTziqVFD6VSxJuJlRdKPDbUUXuK8n4s=) |
| `UpdateDescription` | 381676 | 2026-06-22 11:13 UTC+7 | [GnoScan](https://gnoscan.io/transactions/details?txhash=VEs16ZtOuJDKqwuvB0RousZ3sppTW7q7EXv5ARq1e8w=) |

**Operator address:** `g1l3fmz59rw8l6h29hslxt6gtna3th8s7m5vl88d`

**Validator profile highlights (submitted on-chain):**
- Active on 6 networks: AtomOne, Avail, Union, Espresso, CrossFi, Dora Vota
- Bare-metal infrastructure with snapshot & public RPC services
- Focus: Indonesian and Southeast Asian community onboarding

**Top issues escalated to core team:**
- `secrets get` panics when `-data-dir` is passed — the correct flag shouldn't crash
- GNOROOT required by read-only commands (`config init`, `secrets get`) — should resolve lazily
- Operator vs signing address distinction unclear — error message needs to be more explicit

Full details: [`validator-setup/test13-setup-feedback.md`](./validator-setup/test13-setup-feedback.md)

---

### 2. Developer Outreach

- Monitored X, Discord, and Telegram for potential Gno.land builders
- Identified developers active in adjacent ecosystems (Cosmos, CosmWasm, Move-based chains)
- Initiated outreach to prospects

---

### 3. Community Support

- Answered developer questions in support channels
- Shared resources and pointed new developers to relevant documentation
- Escalated technical issues with reproduction steps to the core team

---

## Evidence

| Item | Link |
|------|------|
| Validator setup feedback (10 issues) | [`validator-setup/test13-setup-feedback.md`](./validator-setup/test13-setup-feedback.md) |
| Register tx details | [`evidence/week1/validator-registration-tx.md`](./evidence/week1/validator-registration-tx.md) |
| UpdateDescription tx details | [`evidence/week1/validator-update-description-tx.md`](./evidence/week1/validator-update-description-tx.md) |

---

## Next Week Plan

- Continue developer outreach and categorize prospects by background and interest
- Follow up on escalated issues with core team
- Guide newly onboarded developers through first realm deployment
- Expand community presence on Discord and Telegram
