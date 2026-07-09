# [bug] `gnoland secrets init` produces inconsistent on-disk layout across setups

## Summary

`gnoland secrets init` produces different file layouts depending on the setup — sometimes placing secrets under `gnoland-data/secrets/`, sometimes directly under `gnoland-data/`. This inconsistency makes it hard to write reliable backup scripts or snapshot restore procedures.

## Observed behavior

**Setup A** (first node):
```
gnoland-data/
└── secrets/
    ├── priv_validator_key.json
    ├── priv_validator_state.json
    └── node_key.json
```

**Setup B** (second node, same branch, same command):
```
gnoland-data/
├── priv_validator_key.json
├── priv_validator_state.json
└── node_key.json
```

## Impact

- Operators cannot write a single backup command that works across setups
- Snapshot restore documentation cannot reliably say "do not overwrite `secrets/`" if the path varies
- New operators get confused when their layout differs from guides written for the other layout

## Expected behavior

`secrets init` should always produce the same layout regardless of environment. The layout should be documented explicitly so operators know exactly which path to back up.

## Suggested fix

Standardize the layout (either always use `secrets/` subdirectory or always write to data-dir root) and document it in `gnoland secrets --help` and the operator guide.

## Environment

- Branch: `chain/test13`
- Reproduced across two separate validator setups
- Reported by: ruangnode (test13 validator operator)
