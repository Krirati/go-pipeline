#!/bin/sh
set -e

MIN_COVERAGE=80

IGNORE_FILE="scripts/coverage.ignore"
FILTERED_COVERAGE="$(mktemp)"

cleanup() {
    rm -f "$FILTERED_COVERAGE"
}
trap cleanup EXIT INT TERM

#
# Filter ignored files
#
awk -v ignore_file="$IGNORE_FILE" '
BEGIN {
    while ((getline line < ignore_file) > 0) {
        gsub(/\r/, "", line)
        sub(/^[[:space:]]+/, "", line)
        sub(/[[:space:]]+$/, "", line)

        if (line == "" || line ~ /^#/)
            continue

        ignore[++n] = line
    }

    close(ignore_file)
}

NR == 1 {
    print
    next
}

{
    split($1, a, ":")
    file = a[1]

    base = file
    sub(/^.*\//, "", base)

    skip = 0

    for (i = 1; i <= n; i++) {
        if (file == ignore[i] ||
            base == ignore[i] ||
            index(file, ignore[i]) == 1) {
            skip = 1
            break
        }
    }

    if (!skip)
        print
}
' coverage.out > "$FILTERED_COVERAGE"

echo
echo "========== Files below ${MIN_COVERAGE}% =========="

awk -v min="$MIN_COVERAGE" '
NR == 1 { next }

{
    split($1, a, ":")
    file = a[1]

    statements = $2
    count = $3

    total[file] += statements

    if (count > 0)
        covered[file] += statements
}

END {

    low = 0

    printf "%-60s %10s\n", "FILE", "COVERAGE"

    for (f in total) {

        pct = covered[f] * 100 / total[f]

        if (pct < min) {
            printf "%-60s %8.1f%%\n", f, pct
            low++
        }
    }

    if (low == 0)
        print "No file below threshold."
}
' "$FILTERED_COVERAGE"

echo

TOTAL=$(go tool cover -func="$FILTERED_COVERAGE" \
    | awk '/total:/ {gsub("%","",$3); print $3}')

echo "========== Summary =========="
echo "Total Coverage : ${TOTAL}%"
echo "Threshold      : ${MIN_COVERAGE}%"

if awk -v c="$TOTAL" -v min="$MIN_COVERAGE" \
'BEGIN { exit !(c >= min) }'
then
    echo "Status         : PASS"
else
    echo "Status         : FAIL"
    exit 1
fi