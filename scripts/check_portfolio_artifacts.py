"""Check final portfolio structure and record hashes without rerunning analysis.

Python is used only for PDF/OOXML inspection; the analytical workflow remains R.
Run from any directory with Python, pypdf, and the standard library available.
Structural checks supplement visual review; they do not establish scientific
validity, independent human readability, or native PowerPoint compatibility.
"""

from pathlib import Path
import csv
import hashlib
import json
import re
import xml.etree.ElementTree as element_tree
import zipfile

from pypdf import PdfReader


project_root = Path(__file__).resolve().parents[1]
analysis_commit = "8510728538026e8e3da1910360c0671b96dd0c2c"


def require(condition, message):
    """Fail explicitly even if Python runs with optimization enabled."""
    if not condition:
        raise ValueError(message)


def file_sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    memo_path = project_root / "portfolio/research_memo.pdf"
    deck_path = project_root / "portfolio/scott_discussion.pptx"
    page_count = len(PdfReader(memo_path).pages)
    require(page_count == 4, f"Expected four memo pages; found {page_count}.")

    # Count only actual OOXML parts, excluding relationship and master files.
    with zipfile.ZipFile(deck_path) as deck:
        parts = deck.namelist()
        slide_parts = [name for name in parts if re.fullmatch(r"ppt/slides/slide\d+\.xml", name)]
        notes_parts = [name for name in parts if re.fullmatch(r"ppt/notesSlides/notesSlide\d+\.xml", name)]
        # Chart-part placement varies by producer; this deck nests them under slides.
        chart_parts = [name for name in parts if re.fullmatch(r"ppt/(?:slides/)?charts/chart\d+\.xml", name)]
        workbook_parts = [name for name in parts if name.startswith("ppt/embeddings/") and name.endswith(".xlsx")]
        table_count = sum(
            len(element_tree.fromstring(deck.read(name)).findall(
                ".//{http://schemas.openxmlformats.org/drawingml/2006/main}tbl"
            ))
            for name in slide_parts
        )
        deck_counts = {
            "slides": len(slide_parts), "notes": len(notes_parts),
            "charts": len(chart_parts), "embedded_workbooks": len(workbook_parts),
            "tables": table_count,
        }
        expected_counts = {"slides": 5, "notes": 5, "charts": 3,
                           "embedded_workbooks": 3, "tables": 2}
        require(deck_counts == expected_counts, f"Unexpected deck structure: {deck_counts}")

    # Recompute each previously recorded figure hash; do not silently refresh it.
    figure_manifest_path = project_root / "portfolio/figures/figure_manifest.csv"
    with figure_manifest_path.open(encoding="utf-8-sig", newline="") as stream:
        figure_records = list(csv.DictReader(stream))
    require(len(figure_records) == 16, "Expected 16 figure manifest entries.")
    require(len({row["file"] for row in figure_records}) == 16, "Duplicate figure paths.")
    for row in figure_records:
        figure_path = (project_root / row["file"]).resolve()
        require(figure_path.is_relative_to(project_root), "Figure path leaves repository.")
        require(file_sha256(figure_path) == row["sha256"], f"Figure hash mismatch: {row['file']}")

    # Optional descriptive supplement added after the original portfolio freeze.
    # Keep its checks separate from the sixteen core exports and review packet.
    supplement_path = project_root / "portfolio/figures/descriptive_panel_manifest.csv"
    supplement_count = 0
    if supplement_path.exists():
        with supplement_path.open(encoding="utf-8-sig", newline="") as stream:
            supplement = list(csv.DictReader(stream))
        require(len(supplement) == 2, "Expected two descriptive supplement exports.")
        require(len({row["file"] for row in supplement}) == 2, "Duplicate supplement paths.")
        for row in supplement:
            path = (project_root / row["file"]).resolve()
            require(path.is_relative_to(project_root), "Supplement leaves repository.")
            require(file_sha256(path) == row["sha256"], "Descriptive supplement hash mismatch.")
        supplement_count = len(supplement)

    # Hash final artifacts only. No self-hash or claim of unperformed human review.
    manifest = {
        "analysis_commit": analysis_commit,
        "original_analysis_commit": "36f4b09adcddb954db3de59975155fc95659f513",
        "portfolio_revision_date": "2026-11-07",
        "corrected_panel_findings_included": True,
        "corrected_panel_predictive_validation_rerun": False,
        "human_review": False,
        "native_powerpoint_tested": False,
        "validation_scope": "Automated structural and hash checks; agent visual QA is documented separately.",
        "checks": {"memo_pages": page_count, "deck": deck_counts,
                   "verified_figure_hashes": len(figure_records),
                   "verified_supplement_hashes": supplement_count},
        "artifacts": [
            {"file": path.relative_to(project_root).as_posix(),
             "bytes": path.stat().st_size, "sha256": file_sha256(path)}
            for path in (memo_path, deck_path)
        ],
    }
    output_path = project_root / "portfolio/artifact_manifest.json"
    output_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest["checks"], indent=2))
    print("Verified artifacts and wrote portfolio/artifact_manifest.json")


if __name__ == "__main__":
    main()
