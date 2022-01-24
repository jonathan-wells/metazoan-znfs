#!/usr/bin/env bash

echo "species	znfs	retroelements	scaffold_n50" > ../../data/znf_ret_counts.txt
while read -r line; do
    species=$(awk '{ print $1 }' <<< $line)
    n50=$(awk '{ print $4 }' <<< $line)

    if [ $n50 -lt 10000 ]; then
        continue
    fi

    znf=$(< "../../data/beds/${species}_znfs.bed" wc -l)
    ret=$(< "../../data/beds/${species}_retroelements.bed" wc -l)
    echo "${species}	${znf}	${ret}	${n50}" >> ../../data/znf_ret_counts.txt
done < ../../data/parsed_metazoans.out
