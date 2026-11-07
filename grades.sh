#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 FILE.csv" >&2
    exit 1
fi

CSV_FILE="$1"

# Check if file exists AND is readable
if [[ ! -f "$CSV_FILE" ]] || [[ ! -r "$CSV_FILE" ]]; then
    echo "Error: $CSV_FILE not found or not readable" >&2
    exit 1
fi

# Printing the header (AVERAGE changed to %7s for correct column alignment)
printf "%4s %-16s %4s %4s %4s %4s %7s %s\n" "RANK" "NAME" "HTML" "CSS" "BASH" "GIT" "AVERAGE" "MENTION"

line_num=0
Skip_count=0
num_students=0
class_total_score=0

# Temporary file for sorting
tmp=$(mktemp)

while IFS="," read -r raw_name raw_html raw_css raw_bash raw_git || [[ -n "$raw_name" ]]; do
    ((line_num++))
    if [[ "$line_num" -eq 1 ]]; then
        continue
    fi

    # Data cleaning
    name=$(echo "$raw_name" | tr -d '\r' | xargs)
    html=$(echo "$raw_html" | tr -d '\r' | xargs)
    css=$(echo "$raw_css" | tr -d '\r' | xargs)
    bash=$(echo "$raw_bash" | tr -d '\r' | xargs)
    git=$(echo "$raw_git" | tr -d '\r' | xargs)

    # Checking for missing name
    if [[ -z "$name" ]]; then
        echo "Error: line $line_num skipped (missing name)" >&2
        ((Skip_count++))
        continue
    fi

    # Checking for missing scores (Fixed: added >&2 and continue)
    if [[ -z "$html" ]] || [[ -z "$css" ]] || [[ -z "$bash" ]] || [[ -z "$git" ]]; then
        echo "Error: line $line_num skipped (missing score)" >&2
        ((Skip_count++))
        continue
    fi

    # Make sure that scores are numeric and should not exceed 20
    invalid_score=0
    for score in "$html" "$css" "$bash" "$git"; do
        if ! [[ "$score" =~ ^[0-9]+$ ]]; then
            echo "Error: line $line_num skipped (score, $score is not numeric)" >&2
            invalid_score=1
            break
        fi
        if ((score > 20)); then
            echo "Error: line $line_num skipped (score, $score is greater than 20)" >&2
            invalid_score=1
            break
        fi
    done

    if [[ "$invalid_score" -eq 1 ]]; then
        ((Skip_count++))
        continue
    fi

    # Calculate scores
    total_score=$((html + css + bash + git))
    average=$(awk "BEGIN {printf \"%.2f\", $total_score / 4}")

    # Correct thresholds and exact mention formatting
    if ((total_score >= 64)); then
        mention="Très bien"
    elif ((total_score >= 56)); then
        mention="Bien"
    elif ((total_score >= 48)); then
        mention="Assez bien"
    elif ((total_score >= 40)); then
        mention="Passable"
    else
        mention="Échec"
    fi

    # Save to temp file using pipe delimiter
    echo "$average|$name|$html|$css|$bash|$git|$mention" >> "$tmp"
    
    class_total_score=$((class_total_score + total_score))
    ((num_students++))
done < "$CSV_FILE"

# Print Table Content using process substitution to keep 'rank' in main scope
rank=0
while IFS='|' read -r average name html css bash git mention; do
    ((rank++))
    printf "%4s %-16s %4s %4s %4s %4s %7s %s\n" "$rank" "$name" "$html" "$css" "$bash" "$git" "$average" "$mention"
done < <(sort -t '|' -k1,1 -rn "$tmp")

# Remove temporary file
rm -f "$tmp"

# Printing the footer
echo "----------------------------------------------"
if [[ "$num_students" -gt 0 ]]; then
    class_avg=$(awk "BEGIN {printf \"%.2f\", ($class_total_score / $num_students) / 4}")
    echo "Class average: $class_avg"
else
    echo "Class average: 0.00"
fi

# Fixed wording to match brief requirements exactly
echo "Skipped $Skip_count invalid lines (see warnings above)"
