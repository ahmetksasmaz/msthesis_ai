#!/usr/bin/env bash
#
# Build thesis.pdf.
#
#   ./build.sh          full build (pdflatex, bibtex, pdflatex x2)
#   ./build.sh quick    single pdflatex pass, for checking a small text edit
#   ./build.sh clean    remove build artefacts (keeps thesis.pdf)
#
# pdfLaTeX only -- the class uses fontenc/inputenc and hyperref[pdftex], so
# XeLaTeX and LuaLaTeX will not work. BibTeX, not biblatex.

set -u
cd "$(dirname "$0")"

JOB=thesis
ARTEFACTS=(aux bbl blg log lof lot loi toc out synctex.gz fls fdb_latexmk)

red()  { printf '\033[31m%s\033[0m\n' "$*"; }
grn()  { printf '\033[32m%s\033[0m\n' "$*"; }
ylw()  { printf '\033[33m%s\033[0m\n' "$*"; }

clean() {
    for e in "${ARTEFACTS[@]}"; do rm -f "$JOB.$e"; done
    grn "cleaned build artefacts"
}

case "${1:-}" in
    clean) clean; exit 0 ;;
esac

# ---------------------------------------------------------------- prereqs ---
for bin in pdflatex bibtex; do
    command -v "$bin" >/dev/null || { red "missing: $bin"; exit 1; }
done

# metu.cls pulls in LGR (Greek) encoding and Turkish babel; thesis.tex loads
# algorithm/algorithmic and siunitx. Missing any of these aborts the run with a
# message that does not name the Debian package, so check up front.
declare -A NEEDS=(
    [lgrenc.def]=texlive-lang-greek
    [turkish.ldf]=texlive-lang-other
    [algorithm.sty]=texlive-science
    [algorithmic.sty]=texlive-science
    [siunitx.sty]=texlive-science
)
missing=()
for f in "${!NEEDS[@]}"; do
    kpsewhich "$f" >/dev/null 2>&1 || missing+=("${NEEDS[$f]}")
done
if (( ${#missing[@]} )); then
    uniq_pkgs=$(printf '%s\n' "${missing[@]}" | sort -u | tr '\n' ' ')
    red "missing LaTeX support files. Install with:"
    red "    sudo apt install $uniq_pkgs"
    exit 1
fi

# ------------------------------------------------------------------ build ---
run() {
    printf '  %s ... ' "$1"
    if "${@:2}" >/dev/null 2>&1; then grn ok; else
        ylw "issues (see $JOB.log)"
    fi
}

if [[ "${1:-}" == "quick" ]]; then
    echo "quick build:"
    run "pdflatex" pdflatex -interaction=nonstopmode "$JOB.tex"
else
    echo "full build:"
    run "pdflatex (1/3)" pdflatex -interaction=nonstopmode "$JOB.tex"
    run "bibtex       " bibtex "$JOB"
    run "pdflatex (2/3)" pdflatex -interaction=nonstopmode "$JOB.tex"
    run "pdflatex (3/3)" pdflatex -interaction=nonstopmode "$JOB.tex"
fi

# ---------------------------------------------------------------- report ---
echo
[[ -f "$JOB.pdf" ]] || { red "no PDF produced -- see $JOB.log"; exit 1; }

errors=$(grep -c '^!' "$JOB.log" || true)
overfull=$(grep -c 'Overfull' "$JOB.log" || true)
undef=$(grep -ciE 'undefined (reference|citation)' "$JOB.log" || true)
pages=$(pdfinfo "$JOB.pdf" 2>/dev/null | awk '/^Pages:/{print $2}')

grn "$JOB.pdf${pages:+ ($pages pages)}"
(( errors   )) && ylw "  $errors error(s)          grep '^!' $JOB.log"
(( undef    )) && ylw "  $undef undefined ref/cite  (a second full build usually clears these)"
(( overfull )) && ylw "  $overfull overfull box(es)    grep -n Overfull $JOB.log"
(( errors || undef )) || grn "  no errors, no undefined references"
exit 0
