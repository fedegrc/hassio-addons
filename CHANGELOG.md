# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.28] - 2026-10-08

### Fixed

- Re-resolve the server endpoint when the handshake goes stale, so the tunnel
  recovers after the server's dynamic IP (e.g. DuckDNS) changes. Previously
  the add-on stayed disconnected until it was restarted.
- Status API reported a stale `handshake_age` from a previous request.
- Stop writing to `/ssl/wireguard`, which belongs to the WireGuard server add-on.

### Changed

- Upgrade base image to `ghcr.io/hassio-addons/base:21.0.8`.
- Upgrade wireguard-tools to 1.0.20260223, iptables to 1.8.13,
  openresolv to 3.17.4 and Go to 1.26.8.
- Print `wg show` status every hour instead of every 30 seconds.
- Drop armv7 from `build.yaml` (it was never listed in `config.yaml`).
- Fix repository URL in `config.yaml`.

