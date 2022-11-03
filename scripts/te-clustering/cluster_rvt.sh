#!/usr/bin/env bash

DATADIR="../../data"
C=1
while read line; do
    
    species=$(awk '{ OFS="\t"; print $1 }' <<< $line)
    genomefile=$(awk '{ OFS="\t"; print $2 }' <<< $line)
    ftpdir=$(awk '{ OFS="\t"; print $3 }' <<< $line)
    n50=$(awk '{ OFS="\t"; print $4 }' <<< $line)

    
    if [ $n50 -lt 10000 ]; then
        continue
    fi
    
    # if [ $C -gt 5 ]; then
    #     break
    # fi
    
    echo "Downloading ${species}..."
    curl \
        -s \
        -S \
        --retry 4 \
        --max-filesize 5000000000 \
        -o "${DATADIR}/genomes/${species}.fna.gz" \
        "${ftpdir}/${genomefile}.gz"
    
    if ! [ -s "${DATADIR}/genomes/${species}.fna.gz" ]; then
        echo "${species} genome not downloaded"
        continue
    fi

    echo "Unzipping genome..."
    gunzip -f "${DATADIR}/genomes/${species}.fna.gz"    
    
    echo "Extracting retroelement sequences"
    bedtools getfasta \
        -fi "${DATADIR}/genomes/${species}.fna" \
        -bed "${DATADIR}/beds/${species}_retroelements.bed" \
        -s > "${DATADIR}/seqs/${species}_retroelements.fa"
    
    # Clustering based on pretty arbitrary 90-90-90 rule. Seems reasonable as
    # 808080 is usually used, and we would expect reverse transcriptases to be
    # much more conserved than the bulk of TE sequence. Might not even be
    # conservative enough?
    
    echo translating sequences
    transeq "../../data/seqs/${species}_retroelements.fa" "../../data/seqs/${species}_translated_retroelements.fa"
    seqtk rename  "../../data/seqs/${species}_translated_retroelements.fa" "seq_" | 
        sed 's/*//g'  > tmp
    mv tmp "../../data/seqs/${species}_translated_retroelements.fa"
    
    echo clustering sequences
    cd-hit \
        -i "../../data/seqs/${species}_translated_retroelements.fa" \
        -o "../../data/cd-hit-out/${species}_retroelements_clustered.fa" \
        -c 0.9 \
        -d 0 \
        -G 1 \
        -l 29 \
        -aS 0.9 \
        -aL 0.0 \
        -g 1 \
        -sc 1 \
        -sf 1

    echo "Cleaning up..."
    if [ -f "${DATADIR}/genomes/${species}.fna.fai" ]; then
        rm "${DATADIR}/genomes/${species}.fna.fai"
    fi
    rm "${DATADIR}/genomes/${species}.fna"
    
    (( C+=1 ))
done < ../../data/parsed_family_metazoans.out

rg -c '>' ../../data/cd-hit-out/*.fa | 
    sed 's/_retroelements_clustered.fa:/\t/' \
    > ../../data/cd-hit-out/family_retroelement_diversity.txt
