#!/bin/bash
# Build the SAM TT030 fork for the TT's 68030: highwire.prg and the MiNTnet overlay (modules/mintnet.ovl).
#   packaging/build-tt030.sh SIDE_REPO        SIDE_REPO = the atari-tt030-enhancement checkout (cross toolchain,
#                                             cflib, zlib sysroot). Output stays in this tree (dist/, modules/).
# WERROR=-Wno-error: gcc 15 warns where upstream's compiler did not (see Makefile).
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd); S=${1:?usage: build-tt030.sh SIDE_REPO}
C=$S/tools/cflib-src; Z=$S/tools/rpm-src/sysroot/usr
export PATH=$S/tools/cross-mint/usr/bin:$PATH
make -C "$here" clean >/dev/null 2>&1 || true
make -C "$here" -j16 CPU=68030 WERROR=-Wno-error CC="m68k-atari-mint-gcc -g -I$C -I$Z/include" \
     LD="m68k-atari-mint-gcc -L$C/.build/m68020 -L$Z/lib" >/dev/null
make -C "$here/modules/network.src" CPU=68030 CC="m68k-atari-mint-gcc -g -I$C" >/dev/null
ls -l "$here/dist/highwire.prg" "$here/modules/mintnet.ovl"
