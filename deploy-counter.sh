#!/bin/bash
export PATH=$PATH:$HOME/go/bin

echo "==> Registering namespace nym-ruangnode001..."
gnokey maketx call \
  -pkgpath "gno.land/r/sys/namereg/v1" \
  -func "Register" \
  -args "nym-ruangnode001" \
  -gas-fee 1000000ugnot \
  -gas-wanted 50000000 \
  -broadcast \
  -chainid "test-13" \
  -remote "https://rpc.test13.testnets.gno.land" \
  -home "$HOME/.gno" \
  wallet

echo ""
echo "==> Deploying counter realm..."
gnokey maketx addpkg \
  -pkgpath "gno.land/r/nym-ruangnode001/counter" \
  -pkgdir "$HOME/gnoland/realms/counter" \
  -gas-fee 1000000ugnot \
  -gas-wanted 50000000 \
  -broadcast \
  -chainid "test-13" \
  -remote "https://rpc.test13.testnets.gno.land" \
  -home "$HOME/.gno" \
  wallet
