# CLAUDE.md

Guidance for Claude Code in this repo. Written to be enough context to act **without re-scanning
the tree** — trust the maps below, open only the one file a task touches.

## What this is

MS thesis (METU/ODTÜ, Computer Engineering) in LaTeX on the university-mandated `metu.cls`.
Topic: **color constancy / illumination estimation / white balance**, covering both global
(single-illuminant) and spatially varying (multi-illuminant) estimation.
Author: Ahmet Kürşad Şaşmaz. Supervisor: Prof. Ahmet Oğuz Akyüz. Target date: January 2027.

Git repo, single branch `main`. No Makefile, no CI — compile manually.

## Build

```bash
pdflatex thesis.tex && bibtex thesis && pdflatex thesis.tex && pdflatex thesis.tex
```

pdfLaTeX only (`\usepackage[pdftex]{hyperref}`, `fontenc`/`inputenc` in the class) — **not**
XeLaTeX/LuaLaTeX. BibTeX, **not** biblatex. Bibliography is driven from `references.tex`
(`\bibliographystyle{ieeetr}` + `\bibliography{thesis}` → `thesis.bib`); the commented-out
bibliography lines in `thesis.tex` are dead. Build artifacts are gitignored (incl. `*.pdf`).

## File → content map (chapter *files* are NOT in reading order)

| File | Chapter | Lines | State |
|---|---|---|---|
| `chapters/chapter1.tex` | 1. Introduction | 14 | **stub** — 4 empty sections: Motivation & Problem Definition, Proposed Methods and Models, Contributions and Novelties, Outline |
| `chapters/chapter2.tex` | 2. Background Knowledge | 152 | drafted — Perception (HVS/LMS cones, reflectance & illumination, dichromatic model, camera model), Chromatic Adaptation & White Balance, von Kries Coefficient Law, Wrong von Kries |
| `chapters/chapter3.tex` | 3. **Datasets and Metrics** | 138 | drafted — 10 datasets (SFU Gray Ball, Cube++, Shi-Gehler/ColorChecker, NUS8, LSMI, INTEL-TAU, MIMO, Rendered WB, sRGB-LSMI, Multi-Illumination in the Wild); metrics (recovery / reproduction / mean angular error, ΔE2000) |
| `chapters/chapter4.tex` | 4. **Related Works** | 637 | drafted, largest — Global Illumination Estimation {Statistical, Gamut Based, Learning Based} + Spatially Varying Illumination Estimation {Spatial Analysis, Physics Based, Deep Learning}; 46 `\subsubsection`s, one per paper/algorithm |
| `chapters/chapter5.tex` | 5. Proposed Method | 2 | **stub** (heading + label only) |
| `chapters/chapter6.tex` | 6. Results | 2 | **stub** |
| `chapters/chapter7.tex` | 7. Conclusion & Discussions | 2 | **stub** |

Note the inversion: Datasets and Metrics (ch3) precedes Related Works (ch4). Do not assume a file
number matches a topic — use this table.

Other sources: `thesis.tex` (preamble + all front-matter macro values + inline appendices A/B),
`abbreviations.tex` (only `2D`/`3D` placeholders), `appendix1.tex` (appendix C), `references.tex`,
`curriculumVitae.tex` (commented out — PhD-only).
Assets: `figures/` holds 3 images (`lms_cone_normalized_sensitivities.png`,
`reflection_and_illumination.png`, `bilim_agaci.jpg`).

## Writing conventions (match these when adding content)

- **Prose**: formal academic English, third person / "we", long explanatory paragraphs. Every
  equation is introduced by a sentence naming its `Eq.~\ref{}` and followed by a sentence defining
  its terms ("The term $X$ represents ..."). Related-works subsubsections follow a fixed shape:
  *what the authors propose* → *why it works / what it improves* → *"However, ..." limitations*.
  Attribution reads `Author et al. (YEAR) ...~\cite{key}`.
- **Labels**: `chp:` chapters, `sec:` sections, `subsec:` subsections, `algorithm:` per-method
  subsubsections in ch4, `eq:` equations, `fig:` figures — all `snake_case`. Every chapter/section
  gets a label; cross-reference with `~\ref{}` (a tilde before `\ref`, not a space).
- **Citations**: `\cite{key}` against `thesis.bib` (60 entries, all currently cited). Keys are
  inconsistent by design — some semantic (`gray_world`, `white_patch`), some authorYear
  (`kim2021lsmi`), some camelCase (`finlaysonReproductionAngularError`). Reuse the existing key for
  a paper; for a new one match the neighbouring style in that section.
- **Figures**: always `\includegraphics[width=0.X\linewidth]{figures/name.png}` — the explicit
  `figures/` prefix is required (see gotchas). Caption ends with
  `\textit{Source:}~\cite{key}` when reproduced from a source.
- **Math**: `\begin{equation}` + `\label`; `\begin{subequations}`/`align` for grouped derivations,
  `gathered` for multi-line single-numbered blocks, `\[ \]` for the short unnumbered
  coefficient-triples in ch4. `\norm{}` for `‖·‖`. Notation in use: $L_{est}$/$L_{gt}$ (global
  illuminant RGB vectors), $I_{p,est}$/$I_{p,gt}$ (per-pixel, spatially varying), $\mathcal{P}$
  (pixel set), $\mathbf{I}(\lambda)\mathbf{R}(\lambda)\mathbf{S}_c(\lambda)$ (camera model).
- **No tables exist yet** — ch6 Results will introduce the first ones; `booktabs`, `longtable`,
  `adjustbox`, `rotating` are already loaded.
- Paragraphs are unindented with vertical spacing (`\parindent=0em`, `\parskip=10pt`, set in
  `thesis.tex`) — do not add manual `\\` between paragraphs.

## `metu.cls` (44 KB, hand-rolled — read only if a formatting task demands it)

Not derived from `book`/`report`. Implements title/approval pages, abstract & Öz, dedication,
acknowledgments, plagiarism statement, glossary, bibliography formatting, page numbering.
Margins/spacing live in `metu10.def`/`metu11.def`/`metu12.def`, picked by the point-size option.

Active options: `\documentclass[chaparabic,ceng,ms,12pt,oneandhalf,fivejury]{metu}` —
chapter numerals (`chaparabic`/`chaproman`), department (`ceng`, many others declared),
degree (`ms`/`phd`), size (`10pt`/`11pt`/`12pt`), spacing (`single`/`oneandhalf`/`double`),
committee size (`threejury`/`fivejury`).

Bilingual via `babel` + `\ifturkish`: official front matter has parallel Turkish macros; content
chapters are English-only.

### Front matter — all values live in `thesis.tex`, still mostly PLACEHOLDERS

Unfilled as of now: `\title{METU Thesis Template}` / `\turkishtitle` (real title never set),
`\abstract{}` / `\oz{}` (max 250 words each), `\keywords{}` / `\anahtarklm{}` (max 5 each),
`\acknowledgments{}` (max 300 words), `\thesisdefencedate{01.01.2000}`, `\director`,
`\headofdept`, and committee members i–iii + v (`Name Surname` / `Jüri`).
Filled: `\author`, `\supervisor{Ahmet Oğuz Akyüz}`, `\departmentofsupervisor`, `\dedication`,
`\committeememberiv{Gülşah Tümüklü Özyer}`. `\cosupervisor` block is commented out.

Jury size change (per `!!!-readme-!!!.txt`): swap `fivejury`↔`threejury` **and**
comment/uncomment the 4th & 5th `\committeemember`/`\affiliation` lines. Institutional
requirement: a signed `Tez_Sablonu_Onay_Formu.docx` must be prepended to any draft (not in repo).

### Non-standard class features

- `illustration` — third float type beside `figure`/`table`, with its own `.loi` list.
- `\listofillustrations`, `\listofalgorithms` — extra front-matter lists.
- `theglossary{LONGESTABBRV}` — custom abbreviations env (not the `glossaries` package); the
  argument string sets the column width. Populated in `abbreviations.tex`.
- Appendices: `thesis.tex` (not the class) sets `\thesection` to `\Alph{section}` and
  `\counterwithin{figure/table/equation}{section}`, so appendix numbering reads A.1, B.1, …
  Appendices A and B are written inline in `thesis.tex` (~lines 219–228, placeholder text);
  C comes from `\input{appendix1.tex}`.

### Local macros defined in `thesis.tex`'s preamble

`\norm{}`, `\ceil{}`/`\floor{}` (mathtools paired delimiters), `\tab` (`\hspace*{2em}`),
`\S` (`\sectionautorefname`/`\subsectionautorefname` → "§"),
`\EA{}` → `\textcolor{red}{[EA: ...]}` reviewer annotation — **strip all `\EA{}` before final
submission** (currently zero usages).

## Known gotchas / open defects

- `\graphicspath{{./images/}}` (`thesis.tex:8`) points at a non-existent `images/` dir. Figures
  resolve only because chapters write `figures/...` explicitly. Always use the `figures/` prefix.
- Typos worth fixing if touching those lines: `\label{algoritm:shades_of_gray}`
  (`chapters/chapter4.tex:44`, missing `h` — no `\ref` targets it yet);
  ``Figure`\ref{fig:reflection_and_illumination}`` (`chapters/chapter2.tex:32`, backtick instead
  of `~`); `chapters/chapter2.tex:13` is missing a period before "These are the three types".
- `thesis.lof`/`thesis.lot` may reappear at root — stale build artifacts, gitignored, not sources.
