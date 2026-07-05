# Gno.land test13 — Validator Setup Feedback

**From:** ruangnode

**Context:** Feedback based on setting up a test13 validator node from scratch to active in the validator set (voting power 1), and separately spinning up a second full node for testing. Every issue below was encountered directly during setup. For each: the error, the cause, how it was resolved, and a suggestion.

---

## 1. GNOROOT not detected on startup

- **Error:** `panic: gno was unable to determine GNOROOT. Please set the GNOROOT environment variable`
- **Cause:** The `GNOROOT` environment variable was not set.
- **Resolution:** Set `GNOROOT` in the systemd unit / shell (`export GNOROOT=/path/to/gno`).
- **Suggestion:** Auto-detect GNOROOT relative to the binary where possible, or include the expected directory layout in the panic message.

## 2. stdlib fails to load — GNOROOT pointing to the wrong directory

- **Error:** `panic: failed loading stdlib "errors": does not exist`
- **Cause:** GNOROOT was pointing at the **data directory** (`gnoland-data`) instead of the **gno source repo** (which contains `gnovm/stdlibs/`).
- **Resolution:** Repointed GNOROOT to the source repo; confirmed by the log line `InitChainer: standard libraries loaded`.
- **Suggestion:** Validate GNOROOT at startup — if `gnovm/stdlibs/` is missing, fail fast with a clear message like "GNOROOT must point to the gno source repo, not the data directory."

## 3. GNOROOT vs data-dir is genuinely confusing

- **Issue:** The two directories have similar names but completely different roles: `GNOROOT` -> gno source repo (stdlib); `--data-dir` -> `gnoland-data` (config, db, secrets). It's very easy to point GNOROOT at the data dir by mistake, and the resulting stdlib error (see #2) doesn't reveal GNOROOT as the cause.
- **Suggestion:** Document the two paths side by side with a one-line explanation of each and an explicit warning not to confuse them; ideally auto-detect or validate GNOROOT so operators rarely have to reason about it.

## 4. Read-only commands panic on missing GNOROOT (they don't need it)

- **Errors:** Both `gnoland config init` and `gnoland secrets get validator_key` panic with `unable to determine GNOROOT` when GNOROOT is unset — even though neither command needs the stdlib.
- **Stack trace (same root for both):**
  ```
  panic: gno was unable to determine GNOROOT. Please set the GNOROOT environment variable
  github.com/gnolang/gno/gnovm/pkg/gnoenv.RootDir(...)
          gnovm/pkg/gnoenv/gnoroot.go:24
  main.(*startCfg).RegisterFlags(...)
          gno.land/cmd/gnoland/start.go:81 (also seen at start.go:86)
  main.newStartCmd(...) -> main.newRootCmd(...) -> main.main()
  ```
- **Cause:** GNOROOT resolution happens during the `start` command's flag registration at command-tree init, so it fires for unrelated subcommands too.
- **Confirmation:** These commands succeed once GNOROOT is set to *any* path — even an incorrect one (the data dir) — proving the value isn't actually consumed by them.
- **Suggestion:** Resolve GNOROOT lazily, only for the commands that need it (e.g. `start`), so read-only commands like `config init` and `secrets get` work without it.

## 5. `gnoland secrets get validator_key` panics when passing `-data-dir`

- **Behavior:** Without `-data-dir`, the command succeeds and prints the JSON (`address`, `pub_key`). With `-data-dir` pointing to the actual data directory, it panics.
- **Error:**
  ```
  panic: reflect: call of reflect.Value.Interface on zero Value
  main.printKeyValue[...](...)
          gno.land/cmd/gnoland/config.go:108
  main.execSecretsGet(...)
          gno.land/cmd/gnoland/secrets_get.go:89
  ```
- **Workaround:** Run without `-data-dir` (with GNOROOT exported) and read the plain output; do not pipe through `jq`.
- **Suggestion:** This is backwards — the flag that points to the real secrets location is the one that crashes. Field/output printing should handle nil/zero values gracefully instead of panicking.

## 6. `gnoland config set` fails with "no such file or directory"

- **Error:** `unable to load config ... open gnoland-data/config/config.toml: no such file or directory`
- **Cause:** The command was run from a directory that didn't contain `gnoland-data/`.
- **Resolution:** Passed an explicit `-data-dir`, or ran from the correct directory.
- **Suggestion:** When the config isn't found, print the resolved absolute path being checked and hint at `-data-dir`.

## 7. Node repeatedly restarts during init

- **Log:** `Current command vanished from the unit file` / `Stopping Gnoland node`
- **Cause:** Running `daemon-reload`/`restart` repeatedly while the node was still mid-init (stdlib loading takes ~5 seconds), so it never reached the sync phase.
- **Resolution:** Restart once, then leave it alone until init completes.
- **Suggestion:** Note in the docs that init takes several seconds; optionally log an "initialization in progress" line.

## 8. Wallet key not found / wrong `-home`

- **Errors:** `Key wallet not found`; `gnokey list` empty.
- **Cause:** The key hadn't been created/imported in the `-home` keybase being used (or `-home` pointed elsewhere).
- **Resolution:** Created/imported with `gnokey add [--recover] <name> -home <path>`; verified with `gnokey list -home <path>`.
- **Suggestion:** In the "Key ... not found" error, mention the keybase `-home` path being searched.

## 9. Register fails — operator vs signing address confusion

- **Error:** `post-genesis: caller must equal operator address`
- **Cause:** The operator address argument was filled with the **signing address** (`g16...`, from `gnoland secrets get validator_key`) instead of the **wallet/operator address** (`g1...`, from `gnokey list`) that signs the transaction. Both are `g1...` addresses, so the distinction is easy to miss.
- **Resolution:** Set the operator address to the wallet address (the tx signer); re-broadcast succeeded (`OK!`).
- **Suggestion:** This was the single most confusing step. Make the error explicit (e.g. "caller <g1...> is not the operator address you provided <g1...>"), and clarify in the guide which address comes from `gnokey list` vs `gnoland secrets`.

## 10. `secrets init` output layout differs between setups

- **Observation:** On one node the secrets landed under `gnoland-data/secrets/`, while on another they were written directly under `gnoland-data/` (`priv_validator_key.json`, `node_key.json`, `priv_validator_state.json` at the top level). This inconsistency is confusing when backing up or bootstrapping from a snapshot.
- **Suggestion:** Standardize and document the exact on-disk layout `secrets init` produces, so operators know precisely which files/folders to back up and to avoid overwriting when restoring snapshots.

---

## Summary of highest-impact suggestions

1. **Validate/auto-detect GNOROOT** and fail fast with a clear message if `stdlibs` is missing (fixes #1, #2, #3).
2. **Don't require GNOROOT for read-only commands** (`config init`, `secrets get`) — resolve it lazily (fixes #4).
3. **Fix the `secrets get` panic with `-data-dir`** (#5) — the correct flag shouldn't crash.
4. **Improve the `caller must equal operator address` error** and document operator vs signing address side by side (#9).
5. **Make config/keybase errors path-aware** and **standardize/document the secrets layout** (#6, #8, #10).
