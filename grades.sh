#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 FILE.csv"
    exit 1
fi

CSV_FILE="$1"
line_num=0

while IFS="," read -r raw_name raw_html raw_css raw_git || [[ -n "$raw_name" ]]; do
    ((line_num++))

    if [[ "$line_num" -eq 1 ]]; then
        continue
    fi

    echo "Line $line_num name is $raw_name"
done < "$CSV_FILE"