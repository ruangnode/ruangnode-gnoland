# [bug] `gnoland secrets get validator_key` panics when `-data-dir` flag is passed

## Summary

`gnoland secrets get validator_key` works correctly **without** `-data-dir`, but **panics** when `-data-dir` is passed pointing to the actual data directory. The flag that should point to the real secrets location is the one that crashes.

## Steps to reproduce

```bash
export GNOROOT=$HOME/gno

# This works:
gnoland secrets get validator_key

# This panics:
gnoland secrets get validator_key -data-dir $HOME/gnoland-data
```

## Error

```
panic: reflect: call of reflect.Value.Interface on zero Value
main.printKeyValue[...](...)
        gno.land/cmd/gnoland/config.go:108
main.execSecretsGet(...)
        gno.land/cmd/gnoland/secrets_get.go:89
```

## Expected behavior

Passing `-data-dir` should work at least as well as not passing it. The correct flag should never cause a crash. The `printKeyValue` function should handle nil/zero `reflect.Value` gracefully instead of panicking.

## Workaround

Run without `-data-dir` and copy the `pub_key` value manually from the plain output. Do not pipe through `jq` (also causes issues).

## Environment

- Branch: `chain/test13`
- Reported by: ruangnode (test13 validator operator)
