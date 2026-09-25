# FORGE — Technical Details

This document expands the public architecture preview.

## Layers

FORGE uses a typed case contract between source adapters and downstream analysis. Reproducible parsing and normalization happen before model-assisted analysis. Model outputs remain proposals until validated. Investigator-facing views consume the same verified case objects.

## Main concerns

The design emphasizes provenance, reproducibility, portability, explicit authority levels, and modular integration between collectors and the case platform.
