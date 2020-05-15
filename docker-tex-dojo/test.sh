#!/bin/bash -e

cd $(dirname $0)

echo "X" | xelatex ./test.tex

pdftotext test.pdf

echo -e "\nPDF file created. Scanning contents..."
for search in "Some téxt hęre." "Sample LATEX section" "Subtitle in italics"; do
  grep "$search" test.txt >/dev/null \
    || (echo "Text not found: $search" >&1 && exit 1)
done
echo "Contents verified."
