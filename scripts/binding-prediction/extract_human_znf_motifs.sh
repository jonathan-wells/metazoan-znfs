#!/usr/bin/env bash

for file in ../../data/binding-predictions/GSE78099_RAW/*.bed; do
    znf=$(awk -F '_' '{ print $3 }' <<< $file)
    echo $znf
    awk -F '\t' '{ if ( $5 > 100 ) print $0 }' $file |
        bedtools getfasta \
        -fi ~/Genomes/Mammalia/human_g1k_v37.renamed.fasta \
        -bed /dev/stdin |
        meme -dna -o "../../data/binding-predictions/GSE78099_RAW/${znf}" stdin
done
