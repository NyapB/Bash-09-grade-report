#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 FILE.csv" >&2
    exit 1
fi

CSV_FILE="$1"
line_num=0
Skip_count=0

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
        echo "Error: line $line_num skipped (missing name)"
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
            echo "Error: line $line_num skipped (score, $score is not numeric)"
            invalid_score=1
            break
        fi

        if ((score > 20)); then
            echo "Error: line $line_num skipped (score, $score is greater then 20)"
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
    average=$(awk "BEGIN {printf \ "%.2f", $total_score / 4}")

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


    echo "Line $line_num name is $raw_name"
done < "$CSV_FILE"

#print the number of skipped lines
echo "The total lines skipped are: $Skip_count"