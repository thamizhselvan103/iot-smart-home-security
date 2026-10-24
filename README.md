# Securing IoT Devices in Smart Home Environments

Hands-on project for First Quadrant Labs (project 6, October 2026).
I built a small smart home lab in VirtualBox, attacked it in its default state, then hardened it layer by layer and tested each control again.

The full write-up with every screenshot is in [`docs/IoT-Security-Report.pdf`](docs/IoT-Security-Report.pdf). This repo holds the configs and scripts behind it.

> Everything here ran on my own VMs in a closed lab. No real devices, no real home network.

## Lab

| VM | Role | Network | IP |
|----|------|---------|----|
| gw | Router, nftables firewall, Suricata sensor | iot-net, trusted-net, cloud-net | 10.10.10.1, 10.10.20.1, 10.10.30.1 |
| broker | Mosquitto 2.0.22 MQTT broker (TLS on 8883) | cloud-net | 10.10.30.10 |
| devices | Simulated IoT device (thermo01) | iot-net | 10.10.10.20 |
| kali | Attacker | iot-net | 10.10.10.2 |

Ubuntu 26.04.1 LTS on gw, broker and devices. Kali is the attacker.

## What is in the repo

```
docs/       final report (PDF)
gateway/    nftables.conf (default-drop firewall), lab.rules (Suricata custom rules)
broker/     mosquitto.conf, conf.d/ (TLS, ACL, logging), mosquitto-acl
devices/    iot-update.sh, secure-boot.sh, tamper-check.sh, firmware/
pki/        public certificates only (CA, thermo01) and the CSR
```

Where the files go on the VMs:

| File | Goes to |
|------|---------|
| `gateway/nftables.conf` | `/etc/nftables.conf` on gw |
| `gateway/lab.rules` | `/etc/suricata/rules/lab.rules` on gw |
| `broker/mosquitto.conf`, `broker/conf.d/*` | `/etc/mosquitto/` on broker |
| `broker/mosquitto-acl` | `/etc/mosquitto/acl` on broker |
| `devices/*.sh` | `/usr/local/bin/` on devices |
| `devices/firmware/fw-pub.pem` | `/etc/iot/fw-pub.pem` on devices |

## Controls and how I tested them

| Area | What I did | Test |
|------|-----------|------|
| Network | Three segments, default-drop firewall. iot-net may reach the broker on tcp 8883 only | Kali scan of the gateway: all filtered. Connection to 1883 times out |
| Authentication | MQTT over TLS on 8883, client certificates required, own CA (IoT-Lab-CA) | No certificate and wrong CA are both rejected |
| Authorization | Mosquitto ACL, two roles (device, admin) | thermo01 cannot publish to the door lock topic ("messages delivered: 0") |
| Data at rest | LUKS2 vault on the broker, encrypted cache on the device | Encrypted file is not readable JSON |
| Firmware | Signed updates (OpenSSL), rollback refused, simulated secure boot | Tampered file, bad signature and older version all rejected |
| Physical | Simulated case switch and integrity check, alert sent over TLS | Alert arrives on `home/security/alerts/thermo01` |
| Monitoring | Suricata with three custom rules plus firewall drop logs | Rule 1000001 fires in real time during a Kali scan |
| Incident response | Contain, revoke (CRL), reissue, recover | Old certificate refused, new one works |

## Limits

- Secure boot and tamper detection are software simulations. A real product needs hardware (secure element, tamper switch).
- One simulated device in a VM lab. Real devices have constrained hardware and vendor firmware I did not test.
- Certificates come from my own CA. A real deployment needs a managed PKI.
- Private keys are not in this repo and never should be. `.gitignore` blocks them.

## Author

Thamizh Selvan M.R. — cybersecurity intern at First Quadrant Labs.
