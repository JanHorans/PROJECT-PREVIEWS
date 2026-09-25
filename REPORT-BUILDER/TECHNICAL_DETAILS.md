# REPORT BUILDER — Technical Details

## Application shape

Report Builder is a portable Windows desktop application built around independent analytical modules. Each module owns its input normalization, analysis view and exports while following common principles: local processing first, deterministic transformations where practical, and traceable output.

## Timeline

The Timeline module works with structured intervals: person, place, start, end, precision, note and source. It renders time on the horizontal axis and people on the vertical axis. Overlap and conflict calculations are deterministic.

Input can come from direct editing, bulk paste, CSV/TSV/TXT or spreadsheet files. Project state can be saved as JSON and the result exported as a standalone HTML report.

## Address analysis

The network-address module first extracts and deduplicates addresses locally. Optional public-source enrichment is performed only for data that actually needs it. Derived exports preserve the lookup time, provider identity and application version.

## Output boundary

HTML, CSV and JSON are intentional interchange boundaries. A produced report should remain reviewable even when the application is not running.

## Integration

A future bridge to FORGE should exchange structured data rather than merge both applications into one codebase.
