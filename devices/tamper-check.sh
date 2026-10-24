#!/bin/bash
BASE=/etc/iot/baseline.sha256
P=/home/vboxuser/pki
alert() {
  logger -p auth.crit -t tamper-detect "ALERT: $1"
  mosquitto_pub -h 10.10.30.10 -p 8883 --cafile $P/ca.crt --cert $P/thermo01.crt --key $P/thermo01.key \
    -t home/security/alerts/thermo01 -m "{\"device\":\"thermo01\",\"type\":\"tamper\",\"detail\":\"$1\"}"
}
if [ -e /run/iot/case-open ]; then alert "enclosure opened (case switch)"; fi
if ! sha256sum -c --quiet "$BASE" > /tmp/tamper.out 2>&1; then
  alert "integrity check failed: $(grep FAILED /tmp/tamper.out | cut -d: -f1 | tr '\n' ' ')"
fi
