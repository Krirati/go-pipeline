#!/bin/sh
set -e

MIN_COVERAGE=80
IGNORE_FILE="scripts/coverage.ignore"
REPORT_FILE="/tmp/coverage-report.$$"

cleanup() {
    rm -f "$REPORT_FILE"
}
trap cleanup EXIT INT TERM HUP

echo "=== Coverage by file ==="

awk -v min="$MIN_COVERAGE" -v ignore_file="$IGNORE_FILE" '
BEGIN {
    while ((getline line < ignore_file) > 0) {
        gsub(/\r/, "", line)
        sub(/^[[:space:]]+/, "", line)
        sub(/[[:space:]]+$/, "", line)

        if (line ~ /^[[:space:]]*$/) continue
        if (line ~ /^[[:space:]]*#/) continue

        ignore[++n] = line
    }
    close(ignore_file)
}

NR==1 { next }

{
    split($1, a, ":")
    file = a[1]

    base = file
    sub(/^.*\//, "", base)

    skip = 0
    for (i = 1; i <= n; i++) {
        pattern = ignore[i]
        if (file == pattern || base == pattern || index(file, pattern) > 0 || index(base, pattern) > 0) {
            skip = 1
            break
        }
    }
    if (skip) next

    statements = $2
    count = $3

    total[file] += statements
    if (count > 0)
        covered[file] += statements
}

END {
    failed_count = 0

    printf "%-60s %10s %8s\n", "FILE", "COVERAGE", "STATUS"

    for (f in total) {
        pct = covered[f] * 100 / total[f]
        status = "PASS"

        if (pct < min) {
            status = "FAIL"
            failed_count++
        }

        printf "%-60s %8.1f%% %8s\n", f, pct, status
    }

    print "FAILED_COUNT=" failed_count
}
' coverage.out > "$REPORT_FILE"

cat "$REPORT_FILE"

failed_count=$(awk -F= '/^FAILED_COUNT=/{print $2}' "$REPORT_FILE")
failed_count=${failed_count:-0}

echo

coverage=$(go tool cover -func=coverage.out \
    | awk '/total:/ { gsub("%","",$3); print $3 }')

echo "Total Coverage = ${coverage}%"

if [ "$failed_count" -gt 0 ]; then
    echo "❌ Coverage validation failed"
    exit 1
fi

echo "✅ Coverage validation passed"