#!/usr/bin/env bash

# Copy this to ZifRC directory and run from there.

DATADIR="/Users/jonwells/Projects/feschottelab/metazoan-znfs/data/binding-predictions"
SEQDIR="/Users/jonwells/Projects/feschottelab/metazoan-znfs/data/seqs"
declare -A GENOMELIB=(
    # ["Danio_rerio"]="/Users/jonwells/Genomes/Cypriniformes/GCF_000002035.6_GRCz11_genomic.nonalt.fna"
    # ["Homo_sapiens"]="/Users/jonwells/Genomes/Mammalia/GCF_000001405.39_GRCh38.p13_genomic.nonalt.fna"
    # ["Mus_musculus"]="/Users/jonwells/Genomes/Mammalia/GCF_000001635.27_GRCm39_genomic.fna"
    # ["Octopus_sinensis"]="/Users/jonwells/Genomes/Mollusca/GCF_006345805.1_ASM634580v1_genomic.fna"
    # ["Sitophilus_oryzae"]="/Users/jonwells/Genomes/Insecta/GCA_002938485.2_Soryzae_2.0_genomic.fna"
    # ["Drosophila_melanogaster"]="/Users/jonwells/Genomes/Insecta/GCA_000001215.4_Release_6_plus_ISO1_MT_genomic.fna"
    ["Strongylocentrotus_purpuratus"]="/Users/jonwells/Genomes/Echinodermata/GCA_000002235.4_Spur_5.0_genomic.fna"
    )

for species in ${!GENOMELIB[@]}; do
    echo $species
    if [ -d "${DATADIR}/${species}" ]; then
        rm -rf "${DATADIR}/${species}"
    fi
    
    # Translate ZnF seqs and predict binding motif
    sed 's/:/_/' "${SEQDIR}/${species}_znfs.fa" |
    transeq \
        -sformat fasta \
        -sequence /dev/stdin \
        -outseq "${species}_znfs_translated.fa"
    /usr/local/ZifRC/B1hRC.sh $species "${species}_znfs_translated.fa"
   
    # Convert to MEME motif file format
    atcount=$(rg -v '>' ${GENOMELIB[$species]} | rg --count-matches --ignore-case "T|A")
    gccount=$(rg -v '>' ${GENOMELIB[$species]} | rg --count-matches --ignore-case "G|C")
    # Min motif length = 7
    /usr/local/ZifRC/src/pwm2meme.py \
        "/usr/local/ZifRC/out/${species}/results.PFM.txt" \
        $atcount \
        $gccount \
        7 \
        > "/usr/local/ZifRC/out/${species}/${species}_znf_binding.meme"

    # Cleanup
    mv "/usr/local/ZifRC/out/${species}" "${DATADIR}"
    rm "${species}_znfs_translated.fa"
done
