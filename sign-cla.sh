#!/bin/bash
export PATH=$PATH:$HOME/go/bin

echo "==> Signing CLA..."
gnokey maketx call \
  -pkgpath "gno.land/r/sys/cla" \
  -func "Sign" \
  -args "de2f507e38e514eca3329f8515435e3418315c10d81f62767ac9bf8cd7c78fad" \
  -gas-fee 200000ugnot \
  -gas-wanted 15000000 \
  -broadcast \
  -remote "https://rpc.test13.testnets.gno.land" \
  -chainid "test-13" \
  -home "$HOME/.gno" \
  wallet
