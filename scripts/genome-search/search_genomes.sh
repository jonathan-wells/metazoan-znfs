#!/usr/bin/env bash

DATADIR="../../data"

declare -A PFAM=(
    ["zf_C2H2"]="PF00096.hmm"
    ["RVT_1"]="PF00078.hmm"
    ["RVT_2"]="PF07727.hmm"
    ["RVT_3"]="PF13456.hmm"
    ["RNaseH"]="PF00075.hmm"
    ["RT_RNaseH"]="PF17917.hmm"
    ["RT_RNaseH_2"]="PF17919.hmm"
    ["rve"]="PF00665.hmm"
)

c=1
while read -r line; do
    # if [ $c -gt 3 ]; then
    #     break
    # fi
    
    species=$(awk '{ OFS="\t"; print $1 }' <<< $line)
    genomefile=$(awk '{ OFS="\t"; print $2 }' <<< $line)
    ftpdir=$(awk '{ OFS="\t"; print $3 }' <<< $line)
    n50=$(awk '{ OFS="\t"; print $4 }' <<< $line)
    
    if [ -s "${DATADIR}/seqs/${species}_znfs.fa" ]; then
        echo "${species} data already exists"
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


    for i in ${!PFAM[@]}; do
        echo "Searching for ${i} sequences..."
        hmmsearch \
            -o tmp.out \
            --tblout "${DATADIR}/hmmer-out/${species}_${i}.out" \
            --domtblout "${DATADIR}/hmmer-out/${species}_${i}_domains.out" \
            --noali \
            -E 0.01 \
            --domE 0.1 \
            --incE 0.1 \
            --incdomE 1 \
            "${DATADIR}/phmms/${PFAM[$i]}" \
            "${DATADIR}/seqs/${species}_orfs.fa"
    done

    echo "Parsing output"
    ./parse_hmmer.py $species
    bedtools getfasta \
        -fi "${DATADIR}/genomes/${species}.fna" \
        -bed "${DATADIR}/beds/${species}_znfs.bed" \
        -s > "${DATADIR}/seqs/${species}_znfs.fa"

    echo "Cleaning up..."
    rm tmp.out
    if [ -f "${DATADIR}/genomes/${species}.fna.fai" ]; then
        rm "${DATADIR}/genomes/${species}.fna.fai"
    fi
    rm "${DATADIR}/genomes/${species}.fna"
    rm "${DATADIR}/seqs/${species}_orfs.fa"
    
    ((c=c+1))

done < "${DATADIR}/parsed_metazoans.out"
