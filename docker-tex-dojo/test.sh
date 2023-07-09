#!/bin/bash -e

cd $(dirname $0)

# Verify word count script
count_total=$(wordcount --total ./test.tex 2>&1)
if [[ "$count_total" != "12" ]]; then
    echo -e "Wordcount doesn't process sample file correctly with --total: \n$count_total" >&1 && exit 1
fi
count_raw=$(wordcount --raw ./test.tex 2>&1)
if [[ "$count_raw" != "6+6+0 (2/0/0/0) File: ./test.tex" ]]; then
    echo -e "Wordcount doesn't process sample file correctly with --raw: \n$count_raw" >&2 && exit 1
fi
count_bad_arg=$(output=$(wordcount --not-a-flag ./test.tex 2>&1 1>/dev/null); echo "$? | $output")
if [[ $count_bad_arg != "1 | Usage: /usr/bin/wordcount [--total|--raw|--texcount] files" ]]; then
    echo -e "Wordcount doesn't reject a bad argument: \n$count_bad_arg" >&2 && exit 1
fi


# Verify that a file can actually be compiled to PDF.
echo "X" | xelatex ./test.tex

pdftotext test.pdf

echo -e "\nPDF file created. Scanning contents..."
for search in "Some téxt hęre." "Sample LATEX section" "Subtitle in italics"; do
  grep "$search" test.txt >/dev/null \
    || (echo "Text not found: $search" >&1 && exit 1)
done
echo "Contents verified."
