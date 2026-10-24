#!/bin/bash
PUB=/etc/iot/fw-pub.pem
FW=${1:-/opt/iot/firmware.sh}
SIG=${2:-/opt/iot/firmware.sig}
if openssl dgst -sha256 -verify "$PUB" -signature "$SIG" "$FW" >/dev/null 2>&1; then
  logger -t secure-boot "OK firmware verified sha256=$(sha256sum "$FW" | cut -c1-16)"
  echo "[secure-boot] signature VALID, starting firmware"
  exec bash "$FW"
else
  logger -t secure-boot "FAIL signature invalid, firmware refused: $FW"
  echo "[secure-boot] signature INVALID, boot REFUSED"
  exit 1
fi
