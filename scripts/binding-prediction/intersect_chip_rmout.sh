#!/usr/bin/env bash

FILES="../../data/binding-predictions/Homo_sapiens/GSE78099_RAW/*.bed"
GDIR="/Users/jonwells/Genomes/Mammalia"

for file in $FILES; do
    znf=$(echo $file | awk -F '_' '{ print $4 }')
    if [ ! $znf == ZNF93 ]; then
        continue
    fi
    echo $znf
    bedtools intersect \
        -a "${GDIR}/hg19.fa.rmout.bed" \
        -b $file \
        -F 0.1 \
        -wa \
        -wb \
        > "../../data/binding-predictions/Homo_sapiens/znf-chip-out/${znf}_rep.bed"
    
    awk '{ print $19"\t" }' "../../data/binding-predictions/Homo_sapiens/znf-chip-out/${znf}_rep.bed" |
        sort -u > exclude.peaks
    rg -v -f exclude.peaks $file \
        > "../../data/binding-predictions/Homo_sapiens/znf-chip-out/${znf}_nonrep.bed"
    
    bedtools getfasta \
        -fi ${GDIR}/human_g1k_v37.renamed.fasta \
        -bed "../../data/binding-predictions/Homo_sapiens/znf-chip-out/${znf}_rep.bed" \
        -s \
        > "../../data/binding-predictions/Homo_sapiens/znf-chip-out/${znf}_rep.fa"

    bedtools getfasta \
        -fi ${GDIR}/human_g1k_v37.renamed.fasta \
        -bed "../../data/binding-predictions/Homo_sapiens/znf-chip-out/${znf}_nonrep.bed" \
        -s \
        > "../../data/binding-predictions/Homo_sapiens/znf-chip-out/${znf}_nonrep.fa"
done

