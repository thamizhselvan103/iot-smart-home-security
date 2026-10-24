#!/bin/bash
NEW=$1; SIG=$2; PUB=/etc/iot/fw-pub.pem
CUR=$(grep -o -m1 '[0-9]\+\.[0-9]\+' /opt/iot/firmware.sh | head -1)
VER=$(grep -o -m1 '[0-9]\+\.[0-9]\+' "$NEW" | head -1)
if ! openssl dgst -sha256 -verify "$PUB" -signature "$SIG" "$NEW" >/dev/null 2>&1; then
  logger -t iot-update "REJECT bad signature: $NEW"; echo "[update] REJECTED: bad signature"; exit 1
fi
if [ "$CUR" = "$VER" ] || [ "$(printf '%s\n%s\n' "$CUR" "$VER" | sort -V | tail -1)" != "$VER" ]; then
  logger -t iot-update "REJECT not newer: $CUR -> $VER"; echo "[update] REJECTED: version $VER is not newer than $CUR"; exit 1
fi
cp /opt/iot/firmware.sh /opt/iot/firmware.sh.prev; cp /opt/iot/firmware.sig /opt/iot/firmware.sig.prev
install -m 755 "$NEW" /opt/iot/firmware.sh; install -m 644 "$SIG" /opt/iot/firmware.sig
logger -t iot-update "APPLIED $CUR -> $VER"; echo "[update] APPLIED $CUR -> $VER"
