# [bug] Read-only commands panic on missing GNOROOT even though they don't need it

## Summary

`gnoland config init` and `gnoland secrets get validator_key` both panic with `unable to determine GNOROOT` when `GNOROOT` is unset — even though neither command reads the stdlib or needs the source repo at all.

## Steps to reproduce

```bash
# Unset GNOROOT
unset GNOROOT

# Both of these panic:
gnoland config init -config-path ./config.toml
gnoland secrets get validator_key
```

## Error

```
panic: gno was unable to determine GNOROOT. Please set the GNOROOT environment variable
github.com/gnolang/gno/gnovm/pkg/gnoenv.RootDir(...)
        gnovm/pkg/gnoenv/gnoroot.go:24
main.(*startCfg).RegisterFlags(...)
        gno.land/cmd/gnoland/start.go:81
main.newStartCmd(...) -> main.newRootCmd(...) -> main.main()
```

## Root cause

GNOROOT resolution happens during the `start` command's flag registration at command-tree init (`newRootCmd`), so it fires for **all** subcommands — including ones that never use it.

## Confirmation

Both commands succeed once GNOROOT is set to **any** path, even an incorrect one (e.g. the data dir). This proves the value is never actually consumed by these commands.

## Expected behavior

`config init` and `secrets get` should work without GNOROOT set. GNOROOT should be resolved lazily, only when the `start` command actually needs it.

## Suggested fix

Move GNOROOT resolution out of `newRootCmd`/flag registration and into the `start` command's `RunE` or pre-run hook, so read-only subcommands are unaffected.

## Environment

- Branch: `chain/test13`
- Reported by: ruangnode (test13 validator operator)
