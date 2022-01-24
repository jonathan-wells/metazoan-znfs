#!/usr/bin/env bash

declare -A proteomes
proteomes=(
    ['Octopus_bimaculoides']='GCA_001194135.1_Octopus_bimaculoides_v2_0_protein.faa'
)

for species in ${!proteomes[@]}; do
    echo $species
    echo ${proteomes[$species]}
    blastp \
        -query ../../data/phmms/PF00096_seed.consensus.fa \
        -subject ../../data/proteomes/${proteomes[$species]} \
        -outfmt 6 \
        -evalue 1e-02 | 
    awk '{ print $2 }' |
    sort -u > "${species}_znfs.names"
    
    # /programs/seqtk/
    seqtk subseq \
        ../../data/proteomes/${proteomes[$species]} \
        "${species}_znfs.names" \
        > "${species}_znfs.fa"
   
    cut -c -20 "${species}_znfs.fa" > "${species}_znfs_cut20.fa"


    # /programs/cd-hit
    cd-hit \
        -c 0.75 \
        -i "${species}_znfs_cut20.fa" \
        -o "${species}_znfs_clustered.fa" \
        -sc 1 \
        -sf 1
done

