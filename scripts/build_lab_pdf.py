#!/usr/bin/env python3
"""Build the student PKI lab PDF from its Markdown source."""

from __future__ import annotations

import argparse
import html
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    KeepTogether,
    ListFlowable,
    ListItem,
    NextPageTemplate,
    PageBreak,
    PageTemplate,
    Paragraph,
    Preformatted,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "lab" / "PKI-LAB.md"
OUTPUT = ROOT / "output" / "pdf" / "Three-VM-PKI-Lab.pdf"
DOCUMENT_HEADER = "Three-VM Public-Key Infrastructure Lab"
DOCUMENT_SUBTITLE = "Ubuntu 24.04 LTS - Certificate Authority, HTTPS Server, and Web Client"

PAGE_W, PAGE_H = letter
LEFT = 0.72 * inch
RIGHT = 0.72 * inch
TOP = 0.72 * inch
BOTTOM = 0.68 * inch
CONTENT_W = PAGE_W - LEFT - RIGHT

NAVY = colors.HexColor("#17365D")
BLUE = colors.HexColor("#2F75B5")
LIGHT_BLUE = colors.HexColor("#D9EAF7")
PALE = colors.HexColor("#F4F7FA")
DARK = colors.HexColor("#202A35")
MUTED = colors.HexColor("#596775")
RULE = colors.HexColor("#B8C7D6")


def inline_markup(value: str) -> str:
    """Convert the small Markdown inline subset used by the manual."""
    value = html.escape(value, quote=False)
    value = re.sub(r"`([^`]+)`", r'<font name="Courier">\1</font>', value)
    value = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", value)
    value = re.sub(r"\[([^]]+)\]\(([^)]+)\)", r'<link href="\2" color="#2F75B5">\1</link>', value)
    return value


def make_styles():
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "LabTitle", parent=base["Title"], fontName="Helvetica-Bold",
            fontSize=25, leading=29, textColor=NAVY, alignment=TA_CENTER,
            spaceAfter=18,
        ),
        "subtitle": ParagraphStyle(
            "Subtitle", parent=base["Normal"], fontName="Helvetica",
            fontSize=12, leading=17, textColor=MUTED, alignment=TA_CENTER,
            spaceAfter=18,
        ),
        "phase": ParagraphStyle(
            "Phase", parent=base["Heading1"], fontName="Helvetica-Bold",
            fontSize=20, leading=24, textColor=NAVY, spaceBefore=0,
            spaceAfter=12, keepWithNext=True,
        ),
        "section": ParagraphStyle(
            "Section", parent=base["Heading2"], fontName="Helvetica-Bold",
            fontSize=15, leading=19, textColor=BLUE, spaceBefore=14,
            spaceAfter=7, keepWithNext=True,
        ),
        "subsection": ParagraphStyle(
            "Subsection", parent=base["Heading3"], fontName="Helvetica-Bold",
            fontSize=11.5, leading=15, textColor=DARK, spaceBefore=10,
            spaceAfter=5, keepWithNext=True,
        ),
        "body": ParagraphStyle(
            "Body", parent=base["BodyText"], fontName="Helvetica",
            fontSize=9.4, leading=13.2, textColor=DARK, spaceAfter=6,
            allowWidows=0, allowOrphans=0,
        ),
        "bullet": ParagraphStyle(
            "Bullet", parent=base["BodyText"], fontName="Helvetica",
            fontSize=9.2, leading=12.6, textColor=DARK, leftIndent=14,
            firstLineIndent=0, spaceAfter=2.5,
        ),
        "code": ParagraphStyle(
            "Code", parent=base["Code"], fontName="Courier", fontSize=7.3,
            leading=9.5, textColor=colors.HexColor("#17202A"),
            backColor=PALE, borderColor=RULE, borderWidth=0.5,
            borderPadding=7, leftIndent=2, rightIndent=2, spaceBefore=3,
            spaceAfter=7,
        ),
        "table": ParagraphStyle(
            "TableText", parent=base["BodyText"], fontName="Helvetica",
            fontSize=7.8, leading=10, textColor=DARK,
        ),
        "table_header": ParagraphStyle(
            "TableHeader", parent=base["BodyText"], fontName="Helvetica-Bold",
            fontSize=7.8, leading=10, textColor=colors.white,
        ),
        "footer": ParagraphStyle(
            "Footer", parent=base["Normal"], fontName="Helvetica",
            fontSize=7.5, leading=9, textColor=MUTED,
        ),
    }


STYLES = make_styles()


def draw_page(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(RULE)
    canvas.setLineWidth(0.5)
    canvas.line(LEFT, PAGE_H - 0.46 * inch, PAGE_W - RIGHT, PAGE_H - 0.46 * inch)
    canvas.setFont("Helvetica", 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(LEFT, PAGE_H - 0.35 * inch, DOCUMENT_HEADER)
    canvas.drawRightString(PAGE_W - RIGHT, 0.36 * inch, f"Page {doc.page}")
    canvas.restoreState()


class LabDocTemplate(BaseDocTemplate):
    def __init__(self, filename: str, title: str, subject: str):
        super().__init__(
            filename,
            pagesize=letter,
            leftMargin=LEFT,
            rightMargin=RIGHT,
            topMargin=TOP,
            bottomMargin=BOTTOM,
            title=title,
            author="Penn State PKI Lab",
            subject=subject,
        )
        frame = Frame(LEFT, BOTTOM, CONTENT_W, PAGE_H - TOP - BOTTOM, id="normal")
        self.addPageTemplates(PageTemplate(id="all", frames=[frame], onPage=draw_page))


def parse_table(lines: list[str]) -> Table:
    rows = []
    for index, line in enumerate(lines):
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if index == 1 and all(re.fullmatch(r":?-{3,}:?", cell) for cell in cells):
            continue
        style = STYLES["table_header"] if not rows else STYLES["table"]
        rows.append([Paragraph(inline_markup(cell), style) for cell in cells])

    column_count = max(len(row) for row in rows)
    for row in rows:
        row.extend([Paragraph("", STYLES["table"])] * (column_count - len(row)))
    widths = [CONTENT_W / column_count] * column_count
    table = Table(rows, colWidths=widths, repeatRows=1, hAlign="LEFT")
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), NAVY),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.35, RULE),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, PALE]),
    ]))
    return table


def markdown_to_story(text: str):
    lines = text.splitlines()
    story = []
    paragraph_buffer: list[str] = []
    first_title = True
    in_code = False
    code_lines: list[str] = []
    list_items: list[tuple[str, str]] = []

    def flush_paragraph():
        if paragraph_buffer:
            joined = " ".join(item.strip() for item in paragraph_buffer)
            story.append(Paragraph(inline_markup(joined), STYLES["body"]))
            paragraph_buffer.clear()

    def flush_list():
        if not list_items:
            return
        ordered = list_items[0][0] == "number"
        items = [
            ListItem(Paragraph(inline_markup(text), STYLES["bullet"]), leftIndent=9)
            for _, text in list_items
        ]
        list_options = {
            "bulletType": "1" if ordered else "bullet",
            "leftIndent": 18,
            "bulletFontName": "Helvetica",
            "bulletFontSize": 8,
            "spaceAfter": 5,
        }
        if ordered:
            list_options["start"] = "1"
        story.append(ListFlowable(items, **list_options))
        list_items.clear()

    index = 0
    while index < len(lines):
        line = lines[index]

        if in_code:
            if line.startswith("```"):
                story.append(Preformatted("\n".join(code_lines), STYLES["code"], maxLineLength=110))
                code_lines.clear()
                in_code = False
            else:
                code_lines.append(line)
            index += 1
            continue

        if line.startswith("```"):
            flush_paragraph()
            flush_list()
            in_code = True
            index += 1
            continue

        if line.startswith("|") and index + 1 < len(lines) and lines[index + 1].startswith("|"):
            flush_paragraph()
            flush_list()
            table_lines = []
            while index < len(lines) and lines[index].startswith("|"):
                table_lines.append(lines[index])
                index += 1
            story.extend([parse_table(table_lines), Spacer(1, 7)])
            continue

        if list_items and line[:1].isspace() and line.strip():
            kind, existing = list_items[-1]
            list_items[-1] = (kind, f"{existing} {line.strip()}")
            index += 1
            continue

        heading = re.match(r"^(#{1,3})\s+(.+)$", line)
        if heading:
            flush_paragraph()
            flush_list()
            level = len(heading.group(1))
            title = heading.group(2)
            if level == 1:
                if first_title:
                    story.append(Spacer(1, 0.6 * inch))
                    story.append(Paragraph(inline_markup(title), STYLES["title"]))
                    story.append(Paragraph(
                        DOCUMENT_SUBTITLE,
                        STYLES["subtitle"],
                    ))
                    story.append(Spacer(1, 0.15 * inch))
                    first_title = False
                else:
                    story.extend([PageBreak(), Paragraph(inline_markup(title), STYLES["phase"])])
            elif level == 2:
                story.append(Paragraph(inline_markup(title), STYLES["section"]))
            else:
                story.append(Paragraph(inline_markup(title), STYLES["subsection"]))
            index += 1
            continue

        bullet = re.match(r"^\s*-\s+(.+)$", line)
        numbered = re.match(r"^\s*\d+\.\s+(.+)$", line)
        if bullet or numbered:
            flush_paragraph()
            kind = "number" if numbered else "bullet"
            content = (numbered or bullet).group(1)
            if list_items and list_items[0][0] != kind:
                flush_list()
            list_items.append((kind, content))
            index += 1
            continue

        if not line.strip():
            flush_paragraph()
            flush_list()
        else:
            paragraph_buffer.append(line)
        index += 1

    flush_paragraph()
    flush_list()
    if in_code:
        raise ValueError("Unclosed Markdown code fence")
    return story


def main():
    global DOCUMENT_HEADER, DOCUMENT_SUBTITLE
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--header", default=DOCUMENT_HEADER)
    parser.add_argument("--subtitle", default=DOCUMENT_SUBTITLE)
    parser.add_argument("--subject", default="Student laboratory instructions")
    args = parser.parse_args()

    DOCUMENT_HEADER = args.header
    DOCUMENT_SUBTITLE = args.subtitle
    args.output.parent.mkdir(parents=True, exist_ok=True)
    source_text = args.source.read_text(encoding="utf-8")
    story = markdown_to_story(source_text)
    title_match = re.search(r"^#\s+(.+)$", source_text, re.MULTILINE)
    title = title_match.group(1) if title_match else args.header
    LabDocTemplate(str(args.output), title, args.subject).build(story)
    print(args.output.resolve())


if __name__ == "__main__":
    main()
