"""Typeset the four-page research memo from its editable Markdown source.

R remains the analysis and plotting language. Python is used only for reliable
PDF typesetting with the bundled ReportLab runtime. Run after final figures are
built. No model fitting, data transformation, or numerical analysis occurs here.
"""
from pathlib import Path
import re
from html import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak, Image, Table, TableStyle,
)
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "portfolio/research_memo.md"
DESTINATION = ROOT / "portfolio/research_memo.pdf"
FONT_DIRECTORY = Path("C:/Windows/Fonts")

# Embed the document fonts so the delivered PDF preserves its pagination.
for name, filename in (
    ("Memo", "calibri.ttf"), ("MemoBold", "calibrib.ttf"),
    ("MemoItalic", "calibrii.ttf"), ("MemoBoldItalic", "calibriz.ttf"),
):
    pdfmetrics.registerFont(TTFont(name, str(FONT_DIRECTORY / filename)))
pdfmetrics.registerFontFamily("Memo", normal="Memo", bold="MemoBold",
                             italic="MemoItalic", boldItalic="MemoBoldItalic")

styles = {
    "body": ParagraphStyle("body", fontName="Memo", fontSize=10.7, leading=14.0,
                           spaceAfter=7, textColor=colors.black, allowWidows=0, allowOrphans=0),
    "title": ParagraphStyle("title", fontName="MemoBold", fontSize=21, leading=24,
                            spaceAfter=8, textColor=colors.black, keepWithNext=True),
    "subtitle": ParagraphStyle("subtitle", fontName="Memo", fontSize=12.1, leading=15,
                               spaceAfter=7, textColor=colors.black, keepWithNext=True),
    "heading": ParagraphStyle("heading", fontName="MemoBold", fontSize=13.3, leading=16,
                              spaceBefore=8, spaceAfter=6, textColor=colors.black, keepWithNext=True),
    "caption": ParagraphStyle("caption", fontName="MemoItalic", fontSize=9.0, leading=11.4,
                              spaceAfter=8, textColor=colors.black),
    "metadata": ParagraphStyle("metadata", fontName="Memo", fontSize=9.3, leading=12,
                               spaceAfter=12, textColor=colors.HexColor("#444444")),
    "reference_heading": ParagraphStyle("reference_heading", fontName="MemoBold", fontSize=9.6,
                                        leading=12, spaceBefore=7, spaceAfter=4, keepWithNext=True),
    "references": ParagraphStyle("references", fontName="Memo", fontSize=8.0, leading=10,
                                  spaceAfter=4, textColor=colors.black),
    "question": ParagraphStyle("question", fontName="Memo", fontSize=10.7, leading=14,
                                leftIndent=13, firstLineIndent=-13, spaceAfter=6),
    "cell": ParagraphStyle("cell", fontName="Memo", fontSize=9.6, leading=12),
    "cell_number": ParagraphStyle("cell_number", fontName="Memo", fontSize=9.6, leading=12,
                                   alignment=TA_CENTER),
}


def inline_markup(text):
    """Convert only the simple emphasis and hyperlinks used by this memo."""
    links = {}
    def preserve_link(match):
        token = f"LINKTOKEN{len(links)}END"
        links[token] = f'<a href="{escape(match.group(2), quote=True)}" color="#24536B">{escape(match.group(1))}</a>'
        return token
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", preserve_link, text)
    text = escape(text)
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    for token, link in links.items():
        text = text.replace(token, link)
    return text


def draw_footer(canvas, document):
    canvas.saveState()
    canvas.setFont("Memo", 8.0)
    canvas.setFillColor(colors.HexColor("#555555"))
    canvas.drawString(54, 26, "MONUSCO quarterly pilot | Research discussion memo")
    canvas.drawRightString(letter[0] - 54, 26, str(document.page))
    canvas.restoreState()


def make_table(lines):
    rows = [[cell.strip() for cell in line.strip().strip("|").split("|")] for line in lines]
    rows = [row for row in rows if not all(re.fullmatch(r"[:\-]+", cell) for cell in row)]
    content = []
    for row_index, row in enumerate(rows):
        cells = []
        for column_index, cell in enumerate(row):
            markup = inline_markup(cell)
            if row_index == 0:
                markup = f"<b>{markup}</b>"
            cells.append(Paragraph(markup, styles["cell" if column_index == 0 else "cell_number"]))
        content.append(cells)
    table = Table(content, colWidths=[280, 112, 112], hAlign="LEFT", repeatRows=1)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#DFEAF0")),
        ("GRID", (0, 0), (-1, -1), .45, colors.HexColor("#D9D9D9")),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
    ]))
    return table


def build():
    text = SOURCE.read_text(encoding="utf-8")
    # Each source block is a complete paragraph or a planned structural element.
    blocks = re.split(r"\n\s*\n", text.strip())
    story = []
    first_subtitle = True
    references = False
    for block in blocks:
        block = block.strip()
        if block == "<!-- pagebreak -->":
            story.append(PageBreak())
        elif block.startswith("# "):
            story.append(Paragraph(inline_markup(block[2:]), styles["title"]))
        elif block.startswith("### "):
            references = True
            story.append(Paragraph(inline_markup(block[4:]), styles["reference_heading"]))
        elif block.startswith("## "):
            style = "subtitle" if first_subtitle else "heading"
            first_subtitle = False
            story.append(Paragraph(inline_markup(block[3:]), styles[style]))
        elif block.startswith("Prepared for"):
            story.append(Paragraph(inline_markup(block), styles["metadata"]))
        elif block.startswith("!["):
            match = re.fullmatch(r"!\[([^\]]+)\]\(([^)]+)\)", block)
            assert match, block
            path = SOURCE.parent / match.group(2)
            assert path.exists(), f"Build final figure first: {path}"
            figure = Image(str(path), width=468, height=201.6)
            figure.hAlign = "CENTER"
            story.extend([Spacer(1, 3), figure, Spacer(1, 5)])
        elif block.startswith("|"):
            story.extend([make_table(block.splitlines()), Spacer(1, 8)])
        elif block.startswith("*") and block.endswith("*") and not block.startswith("**"):
            story.append(Paragraph(inline_markup(block[1:-1]), styles["caption"]))
        elif re.match(r"\d+\. ", block):
            for line in block.splitlines():
                story.append(Paragraph(inline_markup(line), styles["question"]))
        else:
            story.append(Paragraph(inline_markup(block.replace("\n", " ")),
                                   styles["references" if references else "body"]))
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)
    document = SimpleDocTemplate(str(DESTINATION), pagesize=letter,
        leftMargin=54, rightMargin=54, topMargin=43, bottomMargin=43,
        title="Protection or apparent protection around MONUSCO",
        subject="Research discussion memo on local violence and observation uncertainty",
        author="John Lystad", pageCompression=1)
    document.build(story, onFirstPage=draw_footer, onLaterPages=draw_footer)
    reader = PdfReader(DESTINATION)
    if len(reader.pages) != 4:
        raise RuntimeError(f"Expected four pages; rendered {len(reader.pages)}. Inspect and revise layout.")
    print(f"Created {DESTINATION} with {len(reader.pages)} pages.")


if __name__ == "__main__":
    build()
