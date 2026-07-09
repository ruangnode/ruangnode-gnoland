# Week 3 Report — Gno.land Ambassador

**Ambassador:** ruangnode  
**Period:** 2026-07-06 → 2026-07-12  
**Submitted:** 2026-07-09

---

## Summary

This week focused on converting hands-on validator experience into concrete upstream contributions — submitting GitHub issues to the `gnolang/gno` repository based on the 10 issues documented during test13 validator setup. Each issue includes reproduction steps, root cause analysis, and a suggested fix.

---

## Activities

### 1. GitHub Issues Submitted to gnolang/gno

Submitted 5 issues to `https://github.com/gnolang/gno/issues` based on real failures encountered during test13 validator setup. Each issue was documented with: reproduction steps, error output, root cause, and a concrete fix suggestion.

| # | Title | Category |
|---|-------|----------|
| 1 | Read-only commands panic on missing GNOROOT even though they don't need it | bug |
| 2 | `secrets get validator_key` panics when `-data-dir` flag is passed | bug |
| 3 | GNOROOT pointing to wrong directory gives misleading stdlib error | ux |
| 4 | `caller must equal operator address` error does not show conflicting addresses | ux |
| 5 | `secrets init` produces inconsistent on-disk layout across setups | bug |

Issue drafts: [`evidence/week3/github-issues/`](./evidence/week3/github-issues/)

> GitHub issue links will be added here once submitted.

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

## Evidence

| Item | Link |
|------|------|
| Issue drafts (5 issues) | [`evidence/week3/github-issues/`](./evidence/week3/github-issues/) |
| Source feedback doc | [`validator-setup/test13-setup-feedback.md`](./validator-setup/test13-setup-feedback.md) |

---

## Next Week Plan

- Follow up on submitted GitHub issues
- Build second realm (validator profile or guestbook)
- Expand developer outreach with tracked prospects
