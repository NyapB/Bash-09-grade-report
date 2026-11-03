#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 FILE.csv" >&2
    exit 1
fi

CSV_FILE="$1"
if [[ ! -f "$CSV_FILE" ]]; then
    echo "Error: $CSV_FILE not found">&2
fi
#printing the header
printf "%4s %-16s %4s %4s %4s %4s %6s %s\n" "RANK" "NAME" "HTML" "CSS" "BASH" "GIT" "AVERAGE" "MENTION"


line_num=0
Skip_count=0
num_students=0
class_total_score=0

#temporary for sorting files
tmp=$(mktemp)

while IFS="," read -r raw_name raw_html raw_css raw_git || [[ -n "$raw_name" ]]; do
    ((line_num++))

    if [[ "$line_num" -eq 1 ]]; then
        continue
    fi

    #data cleaning
    name=$(echo "$raw_name" | tr -d '\r' | xargs)
    html=$(echo "$raw_html" | tr -d '\r' | xargs)
    css=$(echo "$raw_css" | tr -d '\r' | xargs)
    bash=$(echo "$raw_bash" | tr -d '\r' | xargs)
    git=$(echo "$raw_git" | tr -d '\r' | xargs)

    #checking for missing name
    if [[ -z "$name" ]]; then
        echo "Error: line $line_num skipped (missing name)">&2
        ((Skip_count++))
        continue
    fi

    #checking for missing scores
    if [[ -z "$html" ]] || [[ -z "$css" ]] || [[ -z "$bash" ]] || [[ -z "$git" ]]; then
        echo "Error: line $line_num skipped (missing score)"
        ((Skip_count++))
    fi

    #make sure that scores are numeric and should not exceed 20
    invalid_score=0
    for score in "$html" "$css" "$bash" "$git"; do
        if ! [[ "$score" =~ ^[0-9]+$ ]]; then
            echo "Error: line $line_num skipped (score, $score is not numeric)">&2
            invalid_score=1
            break
        fi

        if ((score > 20)); then
            echo "Error: line $line_num skipped (score, $score is greater then 20)">&2
            invalid_score=1
            break
        fi
    done

    if [[ "$invalid_score" -eq 1 ]]; then
        ((Skip_count++))
        continue
    fi
    #calculate total score
    total_score=$((html + css + bash + git))

    #calculate the average
    average=$(awk "BEGIN {printf \"%.2f\", $total_score / 4}")

    #print out the values calculated
    echo "Student: $name | $total_score | $average"

    #compare the mention using the total score since the bash can not compare average since its in decimals
    if ((total_score >= 64)); then 
        mention="tres bien"
    elif ((total_score >= 56)); then
        mention="bien"
    elif ((total_score >= 46)); then
        mention="assez bien"
    elif ((total_score >= 46)); then
        mention="passable"
    else
        mention="echec"
    fi
#save the ranging file with average first so that sort by it
    echo "$average|$name|$html|$css|$bash|$git|$mention" >> "$tmp"
    class_total_score=$((class_total_score + total_score))
    ((num_students++))

    echo "Line $line_num name is $raw_name"
done < "$CSV_FILE"

#sort and print the rank tbale
rank=0
sort -t'\' -k1,1 -rn "$tmp" | while IFS='|' read -r average name html css bash git mention; do
    ((rank++))
    printf "%4s %-16s %4s %4s %4s %4s %6s %s\n "$rank" "$name" "$html" "$css" '$bash" "$git" "$average" "$mention"
    done

#remove temporary file
rm -f "$tmp"

#printing the footer
echo "----------------------------------------------"
if [[ "$num_students" -gt 0 ]]; then
    class_avg=$(awk "BEGIN {printf \"%.2f\", ($class_total_score / $num_students) / 4}")
    echo "Class average: $class_avg"
else
    echo "Class average: 0.00"
fi

#print the number of skipped lines
echo "The total lines skipped are: $Skip_count, see warnings above"