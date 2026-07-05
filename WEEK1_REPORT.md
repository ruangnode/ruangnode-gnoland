# Week 1 Report — Gno.land Ambassador

**Ambassador:** ruangnode  
**Period:** Week 1  
**Date:** 2026-07-05

---

## Summary

This week focused on hands-on validator operations and technical feedback for the test13 network. I set up a validator node from scratch, documented every issue encountered, and submitted structured feedback to the core team.

---

## Activities

### 1. Validator Node Setup (test13)

- Spun up a test13 validator node from scratch to active in the validator set (voting power 1)
- Separately spun up a second full node for testing and comparison
- Successfully registered as validator on-chain via `gno.land/r/gnops/valopers`
- Documented **10 distinct issues** encountered during setup, each with: error, root cause, resolution, and improvement suggestion
- Full report: [`validator-setup/test13-setup-feedback.md`](./validator-setup/test13-setup-feedback.md)

**On-chain transactions:**

| Action | Tx Hash | Block | Explorer |
|--------|---------|-------|----------|
| Register validator | `djH4sWX8UfPowTziqVFD6VSxJuJlRdKPDbUUXuK8n4s=` | 381402 | [GnoScan](https://gnoscan.io/transactions/details?txhash=djH4sWX8UfPowTziqVFD6VSxJuJlRdKPDbUUXuK8n4s=) |
| UpdateDescription | `VEs16ZtOuJDKqwuvB0RousZ3sppTW7q7EXv5ARq1e8w=` | 381676 | [GnoScan](https://gnoscan.io/transactions/details?txhash=VEs16ZtOuJDKqwuvB0RousZ3sppTW7q7EXv5ARq1e8w=) |

**Operator Address:** `g1l3fmz59rw8l6h29hslxt6gtna3th8s7m5vl88d`

**Validator profile submitted on-chain:**
- Active on 6 networks: AtomOne, Avail, Union, Espresso, CrossFi, Dora Vota
- Bare-metal infrastructure with snapshot & public RPC services
- Focus: Indonesian and Southeast Asian community onboarding

**Key issues surfaced:**
- GNOROOT detection and validation gaps
- Read-only commands unnecessarily requiring GNOROOT
- `secrets get` panic when passing `-data-dir`
- Operator vs signing address confusion during validator registration
- Inconsistent secrets directory layout across setups

---

### 2. Developer Outreach

- Monitored X (Twitter), Discord, and Telegram for potential Gno.land builders
- Identified developers active in adjacent ecosystems (Cosmos, CosmWasm, Move-based chains)
- Initiated outreach to prospects

---

### 3. Community Support

- Answered developer questions in support channels
- Shared resources and pointed new developers to relevant documentation
- Escalated technical issues with clear reproduction steps to the core team

---

## Evidence

| Item | Details |
|------|---------|
| Validator setup feedback (10 issues) | [`validator-setup/test13-setup-feedback.md`](./validator-setup/test13-setup-feedback.md) |
| Validator registration tx | `djH4sWX8UfPowTziqVFD6VSxJuJlRdKPDbUUXuK8n4s=` — [view on gnoscan](https://gnoscan.io/transactions/details?txhash=djH4sWX8UfPowTziqVFD6VSxJuJlRdKPDbUUXuK8n4s=) |
| Validator registration tx | [`evidence/week1/validator-registration-tx.md`](./evidence/week1/validator-registration-tx.md) |
| Validator UpdateDescription tx | [`evidence/week1/validator-update-description-tx.md`](./evidence/week1/validator-update-description-tx.md) |

---

## Blockers / Escalations

The following issues from validator setup were escalated to the core team with full reproduction steps:

1. `secrets get` panic with `-data-dir` flag — correct flag shouldn't crash
2. GNOROOT required by read-only commands (`config init`, `secrets get`) — should be lazy-resolved
3. Operator vs signing address error message needs to be more explicit

---

## Next Week Plan

- Continue developer outreach and categorize prospects
- Follow up on escalated issues
- Guide newly onboarded developers through their first realm deployment
- Expand community presence on Discord and Telegram
