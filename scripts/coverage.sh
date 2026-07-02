#!/bin/sh
set -e

MIN_COVERAGE=80
IGNORE_FILE="scripts/coverage.ignore"
FILTERED_COVERAGE="/tmp/coverage.filtered.$$"

cleanup() {
    rm -f "$FILTERED_COVERAGE"
}
trap cleanup EXIT INT TERM

#
# Step 1 : Filter coverage.out
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

NR==1 {
    print
    next
}

{
    split($1,a,":")
    file=a[1]

    base=file
    sub(/^.*\//,"",base)

    skip=0
    for(i=1;i<=n;i++){
        if(file==ignore[i] ||
           base==ignore[i] ||
           index(file,ignore[i])==1){
            skip=1
            break
        }
    }

    if(!skip)
        print
}
' coverage.out > "$FILTERED_COVERAGE"

#
# Step 2 : Files ต่ำกว่า Threshold
#
echo "========================================="
echo "Files below ${MIN_COVERAGE}%"
echo "========================================="

go tool cover -func="$FILTERED_COVERAGE" |
awk -v min="$MIN_COVERAGE" '
/total:/ {next}

{
    gsub("%","",$3)

    if($3<min)
        printf "%-60s %6.1f%%\n",$1,$3
}
'

echo

#
# Step 3 : Total Coverage
#
coverage=$(
go tool cover -func="$FILTERED_COVERAGE" |
awk '/total:/{
    gsub("%","",$3)
    print $3
}')

echo "========================================="
echo "Total Coverage : ${coverage}%"
echo "Threshold      : ${MIN_COVERAGE}%"

if awk -v c="$coverage" -v min="$MIN_COVERAGE" \
'BEGIN{exit !(c>=min)}'
then
    echo "Status         : PASS"
else
    echo "Status         : FAIL"
    exit 1
fi

echo "========================================="