#!/bin/bash
# Usage: bash vw-eval.sh cwd model testfile cache

cd "$1"

model="$2"
testfile="$3"
cache="$4"

acc=$(vw --binary --testonly --cache_file "${testfile}.${cache}" -i "$model" "$testfile" 2>&1 | grep "average loss" | cut -d"=" -f2)
acc=$(echo "$acc" | awk '{printf "%.6f\n", 1-$1}')
echo "acc     $acc"

logloss=$(vw --loss_function logistic --testonly --cache_file "${testfile}.${cache}" -i "$model" "$testfile" 2>&1 \
    | grep "average loss" | cut -d"=" -f2 )
logloss=$(echo "$logloss" | awk '{printf "%.6f\n", $0}')
echo "logloss $logloss"
