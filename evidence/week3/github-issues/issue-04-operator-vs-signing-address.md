# [ux] `caller must equal operator address` error does not show the conflicting addresses

## Summary

When registering as a validator, the error `post-genesis: caller must equal operator address` does not show the two addresses being compared. This makes it very hard to diagnose — especially because both the wallet address and the signing address start with `g1`, making them easy to confuse.

## Steps to reproduce

```bash
# Mistake: pass signing address (from `secrets get`) as operator address
# instead of wallet address (from `gnokey list`)
gnokey maketx call \
  -pkgpath "gno.land/r/gnops/valopers" \
  -func "Register" \
  -args "moniker" \
  -args "description" \
  -args "data-center" \
  -args "g16..."   # <-- signing address, wrong
  -args "gpub1..." \
  ...
```

## Error

```
post-genesis: caller must equal operator address
```

## Why this is confusing

- Both the wallet address (`g1...` from `gnokey list`) and the signing address (`g16...` from `gnoland secrets get validator_key`) look similar — both start with `g1`
- The error does not show which address was provided vs which address called the tx
- There is no documentation side-by-side explaining which value comes from which command
- This was the single most common failure point among operators on test13

## Expected behavior

The error should show both addresses:

```
caller must equal operator address: caller is g1abc... but operator address provided is g16xyz...
```

## Suggested fix

In the Register function, replace the generic error with an explicit comparison message that includes both addresses.

## Environment

- Branch: `chain/test13`
- Reported by: ruangnode (test13 validator operator)
