#!/usr/bin/env bash

declare -A GENOMELIB=(
    [Homo_sapiens]="/Users/jonwells/Genomes/Mammalia/GCF_000001405.39_GRCh38.p13_genomic.nonalt.fna"
    [Mus_musculus]="/Users/jonwells/Genomes/Mammalia/GCF_000001635.27_GRCm39_genomic.fna"
    [Danio_rerio]="/Users/jonwells/Genomes/Cypriniformes/GCF_000002035.6_GRCz11_genomic.nonalt.fna"
    [Octopus_sinensis]="/Users/jonwells/Genomes/Mollusca/GCF_006345805.1_ASM634580v1_genomic.fna"
    [Sitophilus_oryzae]="/Users/jonwells/Genomes/Insecta/GCA_002938485.2_Soryzae_2.0_genomic.fna"
    [Drosophila_melanogaster]="/Users/jonwells/Genomes/Insecta/GCA_000001215.4_Release_6_plus_ISO1_MT_genomic.fna"
    [Strongylocentrotus_purpuratus]="/Users/jonwells/Genomes/Echinodermata/GCA_000002235.4_Spur_5.0_genomic.fna"
    )

for species in ${!GENOMELIB[@]}; do

    echo $species
    echo ">${species}_nonrepetitive" > ${species}.fa
    echo "${species}_nonrepetitive" > ${species}.names
    rg -v '>' ${GENOMELIB[$species]} | rg -o '[A|C|T|G]+' >> ${species}.fa
    seqtk subseq -l 120 ${species}.fa ${species}.names > tmp
    mv tmp ${species}.fa
    bioawk -c fastx \
        '{ print $name "\t" length($seq) }' ${species}.fa > ${species}.genome
    
    bioawk -v "var=${species}_nonrepetitive" -c fastx \
        '{ print var "\t1\t" length($seq) }' \
        "/Users/jonwells/Genomes/RepBase/RepBase26.10.fasta/${species}_nosat.fa" \
        > "${species}_nonrep_locs.bed"
    bedtools shuffle \
        -i "${species}_nonrep_locs.bed" \
        -g "${species}.genome" > tmp
    bedtools getfasta \
        -fi $species.fa \
        -bed tmp \
        > "../../data/binding-predictions/${species}/${species}_nonrep.fa"
    
    rm tmp
    rm ${species}.genome
    rm ${species}.fa
    rm ${species}.names
    rm "${species}_nonrep_locs.bed"
    done

