# Security Policy

## Reporting a vulnerability

Email **security@neptune.ly** with details and reproduction steps. Please do not open a
public issue for security reports. We aim to acknowledge within 5 business days.

## Brandprint integrity

A brandprint (`NO1-…`) is a 28-byte payload, base64url-encoded, with the final byte a
checksum (`sum(bytes[0..26]) mod 256`). Decoders **reject** any string with a bad prefix,
wrong length, failed checksum, or unsupported version — a tampered brandprint will not
silently resolve to a wrong-but-plausible theme. Registries are append-only and the format
is version-tagged (`NO1-`), so old strings keep resolving via the path they were minted on.

This is integrity (tamper-evidence), not secrecy: a brandprint encodes only public theme
inputs (seeds, shape, type, lever enums, flags) — never secrets. Do not place credentials,
PII, or any sensitive value in a config or brandprint.

## Licensing & provenance

Neptune Odyssey is source-available under the Neptune Odyssey Community License v1.0
([`LICENSE`](LICENSE)). Redistributions must retain the license, copyright, and attribution.
The Neptune.Fintech names and marks are not licensed for use beyond required attribution.
