# Week 2 Report — Gno.land Ambassador

**Ambassador:** ruangnode  
**Period:** 2026-06-23 → 2026-07-05  
**Submitted:** 2026-07-05

---

## Summary

This week focused on hands-on realm development — building and deploying a Gno realm to the test13 network from scratch. The full process was documented including namespace registration, CLA signing, and on-chain deployment.

---

## Activities

### 1. Realm Development & Deployment (test13)

**What is a Realm?**

A realm is Gno.land's equivalent of a smart contract, written in Gnolang (a deterministic, interpreted variant of Go). Unlike smart contracts on other chains that are only accessible via ABI calls, realms are also accessible directly via a URL in any browser — they can render content like a web page while maintaining on-chain state.

For example, the counter realm deployed this week is live at:
`https://test13.testnets.gno.land/r/nym-ruangnode001/counter`

Anyone can open this URL and see the current count. Anyone can call `Increment()` via a transaction and the state updates permanently on-chain — transparent and tamper-proof.

**Why this matters for ambassador work:**

Realm development is a core skill for onboarding builders to Gno.land. As an ambassador, being able to demo a working realm makes it significantly easier to explain Gno.land's value proposition to developers from other ecosystems (Ethereum, Cosmos, Solana). It also validates that the developer experience works end-to-end — from local setup to on-chain deployment.

Built and deployed a counter realm to test13 — the first on-chain realm under the `ruangnode` identity.

**Steps completed:**
- Set up local Gno development environment on macOS (Go, gno, gnodev, gnokey)
- Built `counter` realm with `Increment`, `Decrement`, `Reset`, and `Render` functions
- Tested locally via `gnodev` with live preview at `http://127.0.0.1:8888`
- Registered namespace `nym-ruangnode001` on-chain
- Signed Contributor License Agreement (CLA) on-chain
- Deployed realm to test13 — live at https://test13.testnets.gno.land/r/nym-ruangnode001/counter

**On-chain transactions:**

| Action | Block | Explorer |
|--------|-------|----------|
| Register namespace `nym-ruangnode001` | 654550 | [GnoScan](https://gnoscan.io/transactions/details?txhash=xgRjFQGH6a6RnMxIKKwcqueDwvcWgxbL8R3YGrpNxkw=) |
| Sign CLA | 654603 | [GnoScan](https://gnoscan.io/transactions/details?txhash=F3yrxSTlwmFT6nJjqrtkgBMN17ijMio/R79mqEChPxE=) |
| Deploy `counter` realm | 654620 | [GnoScan](https://gnoscan.io/transactions/details?txhash=UbYtlRXyGPmajilMQkEzz1gXiiYu2I7s/DVj4e1YsLs=) |

**Operator address:** `g1l3fmz59rw8l6h29hslxt6gtna3th8s7m5vl88d`

**Issues surfaced during realm deployment (developer feedback):**
- Namespace registration requires `nym-<stem><3digits>` format — custom names need governance approval, which is not obvious for new developers
- CLA signing gas cost is high (~9.5M gas) and the original system-suggested gas (2M) is too low — misleading for first-time deployers
- `addpkg` gas requirements are not documented clearly; trial and error needed

---

### 2. Developer Outreach

- Monitored X, Discord, and Telegram for potential Gno.land builders
- Identified developers active in adjacent ecosystems
- Initiated outreach to prospects

---

### 3. Community Support

- Answered developer questions in support channels
- Shared resources and pointed new developers to relevant documentation

---

## Public Services Published

| Service | URL |
|---------|-----|
| Validator monitor (all networks) | https://ruangnode.com/monitor |
| Gno.land test13 setup guide (web) | https://ruangnode.com/testnet-networks/gnoland |

The monitor page shows ruangnode's live validator infrastructure across 8 networks including Gno.land test-13 (block 729,074+, 12 peers, ACTIVE).

The web guide makes the test13 validator setup process publicly accessible to Indonesian and SEA developers who find it via search or community links.

---

## Evidence

| Item | Link |
|------|------|
| Counter realm source | [`realms/counter/counter.gno`](./realms/counter/counter.gno) |
| Deployment tx details | [`evidence/week2/realm-deployment-tx.md`](./evidence/week2/realm-deployment-tx.md) |
| Live realm on test13 | https://test13.testnets.gno.land/r/nym-ruangnode001/counter |
| Validator monitor | https://ruangnode.com/monitor |
| Web guide | https://ruangnode.com/testnet-networks/gnoland |

---

## Next Week Plan

- Build a more complex realm (profile page or guestbook)
- Expand developer outreach and categorize prospects
- Follow up on escalated issues from Week 1
