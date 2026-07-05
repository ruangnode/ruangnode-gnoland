# Gno.land test13 — Complete Validator Setup Guide

A practical, end-to-end guide to running a **gno.land test13** validator, from a fresh server to an active validator in the set. Written by **ruangnode**, based on a real setup — including every issue hit along the way and how to fix it.

> Assumes basic familiarity with Linux, systemd, and the command line. Commands use example paths; adjust them to your own environment.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Install Go](#2-install-go)
3. [Build the binaries](#3-build-the-binaries)
4. [Understand GNOROOT vs data-dir](#4-understand-gnoroot-vs-data-dir)
5. [Genesis](#5-genesis)
6. [Initialize config and secrets](#6-initialize-config-and-secrets)
7. [Configure the node](#7-configure-the-node)
8. [Optional: bootstrap from a snapshot](#8-optional-bootstrap-from-a-snapshot)
9. [Create the systemd service](#9-create-the-systemd-service)
10. [Start and sync](#10-start-and-sync)
11. [Create/import your wallet](#11-createimport-your-wallet)
12. [Register as a valoper candidate](#12-register-as-a-valoper-candidate)
13. [Submit onboarding evidence](#13-submit-onboarding-evidence)
14. [Monitoring](#14-monitoring)
15. [Log management](#15-log-management)
16. [Troubleshooting](#16-troubleshooting)
17. [Key concepts recap](#17-key-concepts-recap)

---

## 1. Prerequisites

- A Linux server (Ubuntu/Debian recommended). Dedicated bare-metal or a decent VPS.
- Root or sudo access.
- Install base packages:

```bash
sudo apt update && sudo apt install -y git make curl jq wget zstd build-essential
```

---

## 2. Install Go

gno.land is built from source, so you need Go.

```bash
cd $HOME
VER="1.23.1"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
source ~/.bash_profile
go version
```

---

## 3. Build the binaries

Everything is built from the **`chain/test13`** branch.

```bash
cd $HOME
git clone https://github.com/gnolang/gno.git
cd gno
git checkout chain/test13
make -C gno.land install.gnoland install.gnokey
```

Verify:

```bash
gnoland version
gnokey version
```

---

## 4. Understand GNOROOT vs data-dir

This is the single most common source of confusion. Get it right and most failures disappear.

- **GNOROOT** must point to the **gno source repo** (the folder you cloned, e.g. `$HOME/gno`). It contains `gnovm/stdlibs/`, which the node loads at startup.
- **`--data-dir`** points to your **data directory** (e.g. `$HOME/gnoland-data`), which holds `config/`, `db/`, and your secrets.

They are **different things**. Pointing GNOROOT at the data directory is the classic mistake and causes `failed loading stdlib "errors"`.

> **Tip:** Keep `gnoland-data` **outside** the `gno` folder. That way you can delete/rebuild `gno` during upgrades without touching your data or keys.

Set GNOROOT for your shell now (the systemd service will set it separately):

```bash
export GNOROOT=$HOME/gno
```

---

## 5. Genesis

```bash
mkdir -p $HOME/gnoland-data/config
cd $HOME/gnoland-data/config
wget -O genesis.json https://github.com/gnolang/gno/releases/download/chain/test13/genesis.json
shasum -a 256 genesis.json
# Expected:
# 56f56e135174feff9f93283d5ec7e4ec955cd5155108aff5009d4fd51c5adaf2  genesis.json
```

If the checksum doesn't match, re-download — a corrupt genesis will not start.

---

## 6. Initialize config and secrets

> `gnoland config init` and `secrets init` require GNOROOT to be set (see Troubleshooting #4), so make sure you ran `export GNOROOT=$HOME/gno` first.

```bash
D=$HOME/gnoland-data
gnoland config init -config-path $D/config/config.toml
gnoland secrets init -data-dir $D
```

Verify your secrets exist:

```bash
ls $D/secrets 2>/dev/null || ls $D
# You should see priv_validator_key.json, priv_validator_state.json, node_key.json
```

**Back up your secrets now**, offline and securely. Losing `priv_validator_key.json` means losing your validator identity.

---

## 7. Configure the node

```bash
D=$HOME/gnoland-data
```

**Required (chain-wide — must match exactly):**

```bash
gnoland config set -data-dir $D p2p.persistent_peers "g142k7zc2qym3c0u6jmkf6rv26llgr2f4nakmlmt@sentry-1.test13.testnets.gno.land:26656,g1lxkf9gn7kddrr26c640ww5wg3ezsm22we8cjpc@sentry-2.test13.testnets.gno.land:26656"
gnoland config set -data-dir $D application.prune_strategy syncable
gnoland config set -data-dir $D consensus.timeout_commit 3s
gnoland config set -data-dir $D consensus.peer_gossip_sleep_duration 10ms
gnoland config set -data-dir $D p2p.flush_throttle_timeout 10ms
```

**Per-node (set to your own values):**

```bash
gnoland config set -data-dir $D moniker "your-node-name"
gnoland config set -data-dir $D p2p.external_address "YOUR_PUBLIC_IP:26656"
gnoland config set -data-dir $D p2p.pex true
```

**Advised:**

```bash
gnoland config set -data-dir $D mempool.size 10000
gnoland config set -data-dir $D p2p.max_num_outbound_peers 40
```

> If you run multiple nodes on one server, use custom ports and make sure the P2P port is open in your firewall. Bind RPC/proxy to `127.0.0.1` and expose only P2P externally.

---

## 8. Optional: bootstrap from a snapshot

Syncing from genesis is slow. A snapshot gets you near the chain tip quickly. Snapshot sources are community-provided; verify the source before using.

```bash
D=$HOME/gnoland-data
cd $D

# download (example URL — replace with a current snapshot)
wget https://snapshots.luckystar.asia/gnolandtest/gnoland_data.tar.zst

# inspect structure BEFORE extracting
zstd -d --stdout gnoland_data.tar.zst | tar -tf - | head

# if it starts with db/..., extract in place:
zstd -d --stdout gnoland_data.tar.zst | tar -xf -

# verify
ls $D/db   # should contain blockstore.db, state.db, gnolang.db
```

> The snapshot replaces the `db/` folder. **Never overwrite your `secrets`.** If the archive contains `secrets/`, extract to a temp dir and move only `db/` into place.

---

## 9. Create the systemd service

```bash
sudo tee /etc/systemd/system/gnoland13.service > /dev/null <<EOF
[Unit]
Description=Gnoland node
After=network-online.target

[Service]
Environment="GNOROOT=$HOME/gno"
User=$USER
WorkingDirectory=$HOME
ExecStart=$(which gnoland) start \\
  --chainid test-13 \\
  --genesis $HOME/gnoland-data/config/genesis.json \\
  --data-dir $HOME/gnoland-data/ \\
  --skip-genesis-sig-verification \\
  --log-level error
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

Key flags:
- `--chainid test-13` — required, or you won't peer correctly.
- `--skip-genesis-sig-verification` — **required** for test13. The genesis replays historical transactions whose signatures a fresh node can't re-verify, so it panics on startup without this flag.
- `--log-level error` — keeps logs from flooding the disk (see Log management).

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable gnoland13
sudo systemctl start gnoland13
```

---

## 10. Start and sync

Watch the logs:

```bash
sudo journalctl -u gnoland13 -f
```

You'll see stdlib loading (takes ~5 seconds), then block execution. **Do not restart repeatedly during init** — let it finish (see Troubleshooting #5).

Check sync status:

```bash
curl -s localhost:26657/status | jq '.result.sync_info'
```

- `catching_up: true` → still syncing, let it run.
- `catching_up: false` → fully synced and at the chain tip.

Check peers:

```bash
curl -s localhost:26657/net_info | jq '.result.n_peers'
```

Wait until `catching_up: false` before registering.

---

## 11. Create/import your wallet

Your **operator wallet** signs registration transactions. This is different from your node's consensus key.

Create a new wallet:

```bash
gnokey add wallet -home $HOME/gnoland-data
```

Or import an existing one from a seed phrase:

```bash
gnokey add --recover wallet -home $HOME/gnoland-data
```

Verify and note your `g1...` address:

```bash
gnokey list -home $HOME/gnoland-data
```

> Use the same `-home` for every gnokey command, or your keys won't be found.
> You'll need testnet ugnot for gas — request it from the test13 faucet if your balance is zero.

---

## 12. Register as a valoper candidate

You need two different values — **do not mix them up**:

- **Operator address** (`g1...`) — from `gnokey list` (your wallet, the tx signer).
- **Consensus pubkey** (`gpub1...`) — from your node's validator key:

```bash
gnoland secrets get validator_key
# copy the "pub_key" value (gpub1...)
```

Set your variables:

```bash
export VAL_ADDRESS="g1...your-wallet-address"          # from gnokey list
export VAL_PUB_KEY="gpub1...your-consensus-pubkey"      # from secrets get validator_key
export MONIKER="your-node-name"
export DETAILS="short description of your validator"
```

Register (server type: `cloud`, `on-prem`, or `data-center`):

```bash
gnokey maketx call \
  -pkgpath "gno.land/r/gnops/valopers" \
  -func "Register" \
  -args "$MONIKER" \
  -args "$DETAILS" \
  -args "data-center" \
  -args "$VAL_ADDRESS" \
  -args "$VAL_PUB_KEY" \
  -gas-fee 1000000ugnot -gas-wanted 50000000 \
  -broadcast -chainid "test-13" \
  -remote "https://rpc.test13.testnets.gno.land" \
  -home $HOME/gnoland-data \
  wallet
```

A successful call returns `OK!` with a TX HASH.

To update your description later:

```bash
gnokey maketx call \
  -pkgpath "gno.land/r/gnops/valopers" \
  -func "UpdateDescription" \
  -args "$VAL_ADDRESS" \
  -args "$DETAILS" \
  -gas-fee 1000000ugnot -gas-wanted 50000000 \
  -broadcast -chainid "test-13" \
  -remote "https://rpc.test13.testnets.gno.land" \
  -home $HOME/gnoland-data \
  wallet
```

Verify your registration:

- Valoper candidates: https://test13.testnets.gno.land/r/gnops/valopers
- Active set: https://test13.testnets.gno.land/r/sys/validators/v3

Registering only makes you a **candidate**. Joining the active set requires GovDAO approval and available capacity. New external validators start with **voting power 1**.

---

## 13. Submit onboarding evidence

In the `testnet-onboarding` Discord channel, run:

```
/submit-request
```

Fill in:
- **Operator address** (`g1...`) — your wallet address.
- **Architecture** — your setup (hardware, region, monitoring, port setup).
- **Backup / failover plan** — how you back up secrets and handle recovery.

The team reviews your submission. If approved, you receive the `Testnet Validator` role.

**Safe to share:** validator address, consensus pubkey, public valoper links.
**Never share:** seed phrases, private keys, validator signing keys, passwords, private IPs.

---

## 14. Monitoring

Set up a simple liveness check that pushes to Uptime Kuma and alerts via Telegram.

Create a Push monitor in Uptime Kuma and grab its token. Then a small script:

```bash
#!/bin/bash
HOST="https://your-uptime-kuma-host"
TOKEN="your-push-token"
RPC="http://127.0.0.1:26657"

STATUS=$(curl -s "${RPC}/status")
CATCHING_UP=$(echo "$STATUS" | jq -r '.result.sync_info.catching_up')
HEIGHT=$(echo "$STATUS" | jq -r '.result.sync_info.latest_block_height')

if [ -z "$STATUS" ]; then
  curl -s "${HOST}/api/push/${TOKEN}?status=down&msg=Node%20Down"
elif [ "$CATCHING_UP" = "true" ]; then
  curl -s "${HOST}/api/push/${TOKEN}?status=up&msg=Syncing%20${HEIGHT}"
else
  curl -s "${HOST}/api/push/${TOKEN}?status=up&msg=Synced%20${HEIGHT}"
fi
```

Schedule it via cron (every minute) and set the Uptime Kuma heartbeat interval higher than 60s to avoid false alarms:

```bash
* * * * * cd /path/to/monit && ./gno-active >/dev/null 2>&1
```

---

## 15. Log management

gno.land defaults to very verbose logging. Without care, `/var/log/syslog` can grow to many GB and fill the disk, which can cause missed blocks.

1. Keep `--log-level error` in your service (already set in step 9).
2. Stop gnoland from duplicating into syslog (it's already in journald):

```bash
sudo tee /etc/rsyslog.d/00-gnoland-exclude.conf > /dev/null <<'EOF'
if $programname == 'gnoland' then stop
EOF
sudo systemctl restart rsyslog
```

3. Cap journald size:

```bash
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/size.conf > /dev/null <<'EOF'
[Journal]
SystemMaxUse=300M
EOF
sudo systemctl restart systemd-journald
```

4. If syslog already grew large, truncate it:

```bash
sudo truncate -s 0 /var/log/syslog
```

> Note: routine p2p errors (peer disconnects, dial timeouts, "connection reset by peer", "already stopped") are normal network churn on a busy testnet. As long as your node stays synced with a healthy peer count, they're safe to ignore.

---

## 16. Troubleshooting

**1. `panic: unable to determine GNOROOT`**
GNOROOT isn't set. Set it in your shell (`export GNOROOT=$HOME/gno`) or in the systemd unit (`Environment="GNOROOT=..."`).

**2. `panic: failed loading stdlib "errors": does not exist`**
GNOROOT points to the wrong directory — usually the data dir instead of the source repo. Point it at the folder that contains `gnovm/stdlibs/` (your cloned `gno`). Confirm success with the log line `InitChainer: standard libraries loaded`.

**3. `config set` fails: `no such file or directory ... config.toml`**
You ran the command from a directory without `gnoland-data/`. Pass `-data-dir $HOME/gnoland-data` explicitly, or run from the right directory.

**4. `config init` / `secrets get` panics on GNOROOT**
These read-only commands still require GNOROOT to be set even though they don't use it. Workaround: `export GNOROOT=$HOME/gno` before running them.

**5. Node keeps restarting: `Current command vanished from the unit file`**
You ran `daemon-reload`/`restart` while the node was mid-init (stdlib load takes ~5s). Restart **once**, then leave it alone until init finishes.

**6. `Key wallet not found` / `gnokey list` empty**
The key doesn't exist in the `-home` you used, or `-home` points elsewhere. Create/import it with the correct `-home`, and reuse the same `-home` everywhere.

**7. `caller must equal operator address` when registering**
Your operator address argument is wrong. It must be your **wallet** address (`g1...` from `gnokey list`) — the tx signer — **not** the signing address from `secrets`. Both are `g1...`, so they're easy to confuse.

**8. `gnoland secrets get validator_key | jq` panics**
Piping this command through `jq` can panic. Read the plain output instead and copy the `pub_key` (`gpub1...`) manually. Also: passing `-data-dir` to `secrets get` can trigger a panic — running it without `-data-dir` (with GNOROOT set) works.

**9. `invalid checksum` (bech32) when registering**
An address or pubkey was mistyped or truncated. Re-copy the `g1...` from `gnokey list` and the `gpub1...` from `secrets get validator_key` in full — don't type them by hand.

**10. Missing blocks / 0% uptime after registering**
Common cause: the wrong pubkey type was registered (wallet pubkey instead of the node's consensus pubkey), so the network rejects your signatures. Make sure `gpub1...` comes from `gnoland secrets get validator_key`. Also verify the node is synced (`catching_up: false`), has peers, and the system clock is NTP-synced.

**11. Disk filling up from logs**
See [Log management](#15-log-management). Lower the log level, stop syslog duplication, and cap journald.

---

## 17. Key concepts recap

| Concept | What it is | Where it comes from |
| --- | --- | --- |
| **GNOROOT** | Path to the gno source repo (for stdlib) | your cloned `gno` folder |
| **data-dir** | Path to node data (config, db, secrets) | e.g. `$HOME/gnoland-data` |
| **Operator address** (`g1...`) | Wallet that owns the valoper; signs txs | `gnokey list` |
| **Signing address** (`g16...`) | Node identity that signs blocks | `gnoland secrets get validator_key` |
| **Consensus pubkey** (`gpub1...`) | Pubkey registered in the valset | `gnoland secrets get validator_key` |

Rules of thumb:
- GNOROOT = source repo, **not** the data dir.
- Operator address = **wallet** (`gnokey list`), not the validator key.
- Consensus pubkey = from **secrets**, not the wallet.
- Keep `gnoland-data` outside `gno` so upgrades don't wipe your data.
- Back up `secrets` offline, and never run two nodes with the same validator key (double-signing risk).

---

*Built from a real ruangnode test13 validator setup. Contributions and corrections welcome.*
