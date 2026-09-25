# REPORT BUILDER — Technical Preview

## What it is

Report Builder is a portable Windows analytical helper for converting messy operational or investigative data into structured, readable outputs.

It is deliberately narrower than FORGE and remains useful as a standalone analyst tool.

Current stable baseline in the private repository: **v0.3.0**.

## Implemented modules

### Timeline

Supports editable presence intervals, X=time / Y=person visualization, filtering, deterministic overlap/conflict views, bulk paste, CSV/TSV/TXT/XLSX/XLSM import, JSON project import/export and standalone HTML reports with printable/PDF layout.

### IP intelligence

Extracts IPv4/IPv6 addresses and DNS names locally from pasted text. Public IPs can then be enriched using PTR, RDAP, WHOIS and external VPN/proxy/Tor context.

Exports retain provider provenance and lookup timestamps. External enrichment is treated as context rather than proof of identity or wrongdoing.

## Typical flow

```text
INPUT
  CSV / XLSX / pasted text / future connectors
      |
      v
LOCAL PARSING + NORMALIZATION
      |
      v
ANALYTICAL MODULE
  timeline / IP / future focused modules
      |
      v
VISUALIZATION + TRACEABLE ENRICHMENT
      |
      v
EXPORT
  HTML / CSV / JSON / printable output
```

See [STRUCTURE.md](STRUCTURE.md) and [ROADMAP.md](ROADMAP.md).
