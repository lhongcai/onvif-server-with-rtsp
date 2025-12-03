#!/usr/bin/env bash
# Helper script: cross-compile repo to MIPSel Linux single executable.
# Usage: ./scripts/build-mipsel.sh
set -euo pipefail

# Ensure cross toolchain is installed: mipsel-linux-gnu-gcc, mipsel-linux-gnu-strip (optional)
CC=${CC:-mipsel-linux-gnu-gcc}
CFLAGS="-O2 -DWITH_NONAMESPACES -DSOAP_DEBUG -DDEBUG -I."
OUTDIR=build
mkdir -p "$OUTDIR"

echo "Using compiler: $CC"
SRC="soapC.c stdsoap2.c duration.c wsaapi.c soapClient.c soapServer.c onvif_server_interface.c onvif_server.c config.c"

echo "Trying static build..."
if $CC $CFLAGS $SRC -o "$OUTDIR/deviceserver.mipsel" -static -static-libgcc -static-libstdc++ -lpthread -lm; then
  echo "Static build succeeded: $OUTDIR/deviceserver.mipsel"
else
  echo "Static build failed; retrying without -static..."
  $CC $CFLAGS $SRC -o "$OUTDIR/deviceserver.mipsel" -lpthread -lm
  echo "Non-static build result: $OUTDIR/deviceserver.mipsel"
fi

# Attempt to strip
if command -v mipsel-linux-gnu-strip >/dev/null 2>&1; then
  echo "Stripping binary..."
  mipsel-linux-gnu-strip "$OUTDIR/deviceserver.mipsel" || true
fi

file "$OUTDIR/deviceserver.mipsel" || true
ls -lh "$OUTDIR/deviceserver.mipsel"
echo "Done. Copy build/deviceserver.mipsel to your MIPSel Linux target to test."
