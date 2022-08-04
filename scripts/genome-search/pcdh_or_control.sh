#!/usr/bin/env bash

DATADIR="../../data"

declare -A PFAM=(
    ["protocadherin"]="PF08374.hmm"
    ["olfactory_receptor"]="PF13853.hmm"
)

while read -r line; do
    
    species=$(awk '{ OFS="\t"; print $1 }' <<< $line)
    genomefile=$(awk '{ OFS="\t"; print $2 }' <<< $line)
    ftpdir=$(awk '{ OFS="\t"; print $3 }' <<< $line)
    n50=$(awk '{ OFS="\t"; print $4 }' <<< $line)
    taxonomy=$(awk '{ OFS="\t"; print $6 }' <<< $line)
    
    if [ -s "${datadir}/seqs/${species}_protocadherin.fa" ]; then
        echo "${species} protocadherin data already exists"
        continue
    fi
    if [ -s "${datadir}/seqs/${species}_olfactory_receptor.fa" ]; then
        echo "${species} olfactory data data already exists"
        continue
    fi
    
    if [ $n50 -lt 10000 ]; then
        continue
    fi

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

    echo "Extracting open reading frames..."
    getorf \
        -minsize 375 \
        -maxsize 10000 \
        -nomethionine \
        -find 0 \
        -sequence "${DATADIR}/genomes/${species}.fna" \
        -outseq "${DATADIR}/seqs/${species}_orfs.fa"

    if [ $taxonomy == "Mollusca" ]; then
        domain="protocadherin"
    elif [ $taxonomy == "Mammalia" ]; then
        domain="olfactory_receptor"
    else
        echo "${species} taxonomy not recognized"
        continue
    fi

    echo "Searching for olfactory receptor sequences..."
    hmmsearch \
        -o tmp.out \
        --tblout "${DATADIR}/hmmer-out/${species}_${domain}.out" \
        --domtblout "${DATADIR}/hmmer-out/${species}_${domain}_domains.out" \
        --noali \
        -E 0.01 \
        --domE 0.1 \
        --incE 0.1 \
        --incdomE 1 \
        "${DATADIR}/phmms/${PFAM[$domain]}" \
        "${DATADIR}/seqs/${species}_orfs.fa"

    echo "Parsing output"
    phmmer2bed.py "${DATADIR}/hmmer-out/${species}_${domain}.out" \
        >"${DATADIR}/beds/${species}_${domain}.bed"
    # bedtools getfasta \
    #     -fi "${DATADIR}/genomes/${species}.fna" \
    #     -bed "${DATADIR}/beds/${species}_${domain}.bed" \
    #     -s > "${DATADIR}/seqs/${species}_${domain}.fa"
    
    echo "Cleaning up..."
    rm tmp.out
    if [ -f "${DATADIR}/genomes/${species}.fna.fai" ]; then
        rm "${DATADIR}/genomes/${species}.fna.fai"
    fi
    rm "${DATADIR}/genomes/${species}.fna"
    rm "${DATADIR}/seqs/${species}_orfs.fa"
    
done < "${DATADIR}/parsed_mammalia.out"
