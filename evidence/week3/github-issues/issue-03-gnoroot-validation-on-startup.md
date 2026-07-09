# [ux] GNOROOT pointing to wrong directory gives misleading stdlib error

## Summary

When `GNOROOT` is set to the **data directory** instead of the **gno source repo**, the node fails with a confusing stdlib error that does not mention `GNOROOT` as the cause. This is the single most common operator mistake during initial setup.

## Steps to reproduce

```bash
# Mistake: point GNOROOT at data dir instead of source repo
export GNOROOT=$HOME/gnoland-data

gnoland start --chainid test-13 --data-dir $HOME/gnoland-data
```

## Error

```
panic: failed loading stdlib "errors": does not exist
```

## Why this is confusing

- The error mentions `stdlib "errors"` — operators look for a stdlib issue, not a path issue
- `GNOROOT` is not mentioned anywhere in the error
- The data directory and source repo have similar names (`gnoland-data` vs `gno`), making the mistake easy
- The correct log line `InitChainer: standard libraries loaded` only appears on success, so there is no "almost right" feedback

## Expected behavior

At startup, validate that `$GNOROOT/gnovm/stdlibs/` exists. If it does not, fail fast with a clear message:

```
GNOROOT is set to "/home/user/gnoland-data" but gnovm/stdlibs/ was not found there.
GNOROOT must point to the gno source repository (the folder you cloned from github.com/gnolang/gno),
not the node data directory.
```

## Suggested fix

Add an early check in the startup path:

```go
stdlibPath := filepath.Join(gnoroot, "gnovm", "stdlibs")
if _, err := os.Stat(stdlibPath); os.IsNotExist(err) {
    return fmt.Errorf("GNOROOT=%q does not contain gnovm/stdlibs/; GNOROOT must point to the gno source repo", gnoroot)
}
```

## Environment

- Branch: `chain/test13`
- Reported by: ruangnode (test13 validator operator)
