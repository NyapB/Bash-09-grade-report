#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 FILE.csv" >&2
    exit 1
fi

CSV_FILE="$1"
line_num=0

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

    if [[ -z "$html" ]] || [[ "$html" =~ [a-zA-Z] ]]; then
        continue
    fi

    #calculate total score
    total_score=$((html + css + bash + git))

    #calculate the average
    average=$(awk "BEGIN {printf \ "%.2f", $total_score / 4}")

    #print out the values calculated
    echo "Student: $name | $total_score | $average"

    #compare the mention using the total score since the bash can not compare average since its in decimals
    if (($total_score >= 64)); then 
        mention="tres bien"
    elif (($total_score >= 56)); then
        mention="bien"
    elif (($total_score >= 46)); then
        mention="assez bien"
    elif (($total_score >= 46)); then
        mention="passable"
    else
        mention="echec"
    fi


    echo "Line $line_num name is $raw_name"
done < "$CSV_FILE"