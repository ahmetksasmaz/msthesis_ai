# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

An MS thesis (METU / ODTÜ, Computer Engineering) written in LaTeX using the university-mandated
`metu.cls` template. Subject matter (per drafted chapters): color constancy / illumination
estimation / white balance in computer vision. Author: Ahmet Kürşad Şaşmaz, supervisor Ahmet Oğuz
Akyüz. `\title{}` in `thesis.tex` is still the placeholder "METU Thesis Template" — has not been
set to the real thesis title yet.

Not a git repo. No build scripts, Makefile, or CI exist — compile manually.

## Build commands

Root document is `thesis.tex`. Engine is **pdfLaTeX** (not XeLaTeX/LuaLaTeX — see `metu.cls`'s
`fontenc`/`inputenc` setup and `thesis.tex`'s `\usepackage[pdftex]{hyperref}`). Bibliography is
**BibTeX** (not biblatex), driven from `references.tex` (`\bibliographystyle{ieeetr}`,
`\bibliography{thesis}` against `thesis.bib`) — note `thesis.tex` itself has a dead, commented-out
alternate bibliography setup; the live one lives in `references.tex`.

Standard compile sequence:

```bash
pdflatex thesis.tex
bibtex thesis
pdflatex thesis.tex
pdflatex thesis.tex
```

## Document structure

Assembled via `\input{}` (not `\include`/`\subfile`) from `thesis.tex`, in order:

1. `abbreviations.tex` — inside the `preliminaries` environment (front matter, roman numerals)
2. `chapters/chapter1.tex` … `chapters/chapter7.tex`
3. `references.tex` — triggers the bibliography
4. Two inline appendix sections written directly in `thesis.tex` (~lines 219–228), plus
   `\input{appendix1.tex}` as a third appendix
5. `curriculumVitae.tex` — **commented out** (PhD-only front matter, not used for an MS thesis)

Chapter status (as of exploration): `chapter1.tex` (Introduction) has headings only; `chapter2.tex`
(Background Knowledge, HVS/reflectance/camera model) and `chapter3.tex` (Related Works,
statistical/gamut/learning-based color-constancy methods) are drafted; `chapter4.tex` (Datasets and
Metrics — SFU Gray Ball, Cube++, NUS8, LSMI, INTEL-TAU, MIMO, error metrics) is the largest drafted
chapter; `chapter5.tex` (Proposed Method), `chapter6.tex` (Results), `chapter7.tex` (Conclusion) are
empty stubs. **Note the file-number vs. logical order mismatch**: chapter3 ("Datasets and Metrics")
is input before chapter4 ("Related Works") even though Related Works is conceptually earlier —
don't assume chapter N's file number matches its position in the reading order; check the actual
`\input` sequence and chapter titles in `thesis.tex`/`chapters/*.tex`.

## The `metu.cls` template

`metu.cls` (not derived from `book`/`report` — that `\LoadClass` line is commented out) implements
the entire METU thesis format from scratch: title page, approval page, abstract/Öz, dedication,
acknowledgments, plagiarism statement, glossary, bibliography formatting, page numbering. Margin/
spacing specifics live in point-size-specific `metu10.def`/`metu11.def`/`metu12.def`, selected by
the `10pt`/`11pt`/`12pt` class option.

Class options in use (`\documentclass[chaparabic,ceng,ms,12pt,oneandhalf,fivejury]{metu}`):
- `chaparabic`/`chaproman` — Arabic vs. Roman chapter numerals
- `ceng` — department (many others supported via `\DeclareOption`, e.g. `ee`, `math`, `arch`)
- `ms`/`phd` — degree level (gates CV-chapter machinery, etc.)
- `10pt`/`11pt`/`12pt` — selects the matching `metuNN.def`
- `single`/`oneandhalf`/`double` — line spacing
- `threejury`/`fivejury` — number of committee members; see below

To change jury size or defense date (from `!!!-readme-!!!.txt`, the project's actual README):
- Switch `fivejury`→`threejury` in the `\documentclass` options, and comment out the 4th/5th
  `\committeemember`/`\affiliation` lines (or uncomment them when going back to `fivejury`).
- Set the defense date via `\thesisdefencedate{DD.MM.YYYY}` in `thesis.tex`.
- **Mandatory institutional requirement**: a signed `Tez_Sablonu_Onay_Formu.docx` approval form must
  be prepended to any thesis draft (file not present in this repo — obtained separately).

Bilingual Turkish/English via `babel` (`turkish`/`english`, toggled by a `turkish`/`eng`-style class
option feeding `\ifturkish`): official front matter (title, Öz, dedication, acknowledgments, month
names) has parallel Turkish macros alongside the English ones; content chapters are English-only.

### Front-matter macros to fill in (defined in `metu.cls`, invoked from `thesis.tex`)

- `\title{}` / `\turkishtitle{}`
- `\director[rank]{}`, `\headofdept[rank]{}`, `\supervisor[rank]{}` / `\turkishsupervisor{}`,
  `\cosupervisor[rank]{}` / `\departmentofcosupervisor{}` (co-supervisor block only active if used)
- `\committeememberi`…`\committeememberv` + `\affiliationi`…`\affiliationv` (and Turkish variants) —
  count must match `threejury`/`fivejury`
- `\thesisdefencedate{}`, `\keywords{}` / `\anahtarklm{}` (max 5 each), `\abstract{}` / `\oz{}`
  (redefined by the class — not the standard LaTeX `abstract` environment), `\dedication{}` /
  `\turkishdedication{}`, `\acknowledgments{}` / `\turkishacknowledgments{}`

### Non-standard environments/macros worth knowing about

- `illustration` — a third float type alongside `figure`/`table`, with its own counter and its own
  List of Illustrations (`.loi`).
- `\listofillustrations`, `\listofalgorithms` — extra auto-generated front-matter lists beyond the
  standard ToC/LoF/LoT.
- `theglossary{LONGESTABBRV}`/`endtheglossary` — custom abbreviations-list environment (not the
  `glossaries` package); column width is driven by the widest abbreviation string passed as the
  argument. Populated in `abbreviations.tex` (currently only 2 placeholder entries).
- In the appendix, `thesis.tex` (not the class) does `\renewcommand{\thesection}{\Alph{section}}`
  plus `\counterwithin{figure/table/equation}{section}` so appendix numbering reads A.1, B.1, etc.
- `curriculumvitae`/`vita` — PhD-only CV formatting, unused here since `curriculumVitae.tex` is
  commented out.

### Local helper macros (defined in `thesis.tex`'s own preamble, not the class)

- `\norm{}` — `\left\lVert...\right\rVert`
- `\ceil{}` / `\floor{}` — via `mathtools`' `\DeclarePairedDelimiter`
- `\tab` — `\hspace*{2em}` manual indent
- `\S` — `\sectionautorefname`/`\subsectionautorefname` redefined so `\autoref` prints "§"
- `\EA{}` — `\textcolor{red}{[EA: ...]}`, an inline reviewer/advisor annotation macro. **Search for
  and strip all `\EA{}` usages before final submission.**

## Known gotchas

- `\graphicspath{{./images/}}` (`thesis.tex` line 8) points at an `images/` directory that **does
  not exist**. All actual figures resolve only because chapters use the explicit `figures/...`
  prefix in `\includegraphics` (e.g. `figures/lms_cone_normalized_sensitivities.png`). Don't rely on
  `graphicspath` when adding new figures — use the `figures/` prefix explicitly, or fix the path.
- `thesis.lof`/`thesis.lot` at the repo root are stale build artifacts from a prior compile, not
  source files.
