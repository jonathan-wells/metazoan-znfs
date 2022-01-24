#!/usr/bin/env bash

DATADIR="../../data"

c=1
while read -r line; do
    # if [ $c -gt 5 ]; then
    #     break
    # fi
    
    species=$(awk '{ OFS="\t"; print $1 }' <<< $line)
    genomefile=$(awk '{ OFS="\t"; print $2 }' <<< $line)
    assemblyrep=$(sed 's/genomic\.fna/assembly_report\.txt/' <<< $genomefile)
    ftpdir=$(awk '{ OFS="\t"; print $3 }' <<< $line)
    n50=$(awk '{ OFS="\t"; print $4 }' <<< $line)
    
    if [ $n50 -lt 10000 ]; then
        continue
    fi

    echo "Downloading ${species} assembly_report..."
    curl \
        -s \
        -S \
        --retry 4 \
        --max-filesize 5000000000 \
        -o "${DATADIR}/genomes/${species}_assembly_report.txt" \
        "${ftpdir}/${assemblyrep}"
    
    if ! [ -s "${DATADIR}/genomes/${species}_assembly_report.txt" ]; then
        echo "${species} assembly report not downloaded"
        continue
    fi

    echo "Extracting coordinates..."
    rg -v '#' "${DATADIR}/genomes/${species}_assembly_report.txt" | 
        awk -F "\t" '{ OFS="\t"; print $5, $9}' > "${DATADIR}/genomes/${species}.genome"

    echo "Cleaning up..."
    rm "${DATADIR}/genomes/${species}_assembly_report.txt"
    ((c=c+1))

done < "${DATADIR}/parsed_reference_metazoans.out"
