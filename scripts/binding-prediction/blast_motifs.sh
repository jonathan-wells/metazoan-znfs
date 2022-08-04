#!/usr/bin/env bash

declare -A GENOMELIB=(
    ["Danio_rerio"]="/Users/jonwells/Genomes/Cypriniformes/GCF_000002035.6_GRCz11_genomic.nonalt.fna"
    ["Homo_sapiens"]="/Users/jonwells/Genomes/Mammalia/GCF_000001405.39_GRCh38.p13_genomic.nonalt.fna"
    ["Mus_musculus"]="/Users/jonwells/Genomes/Mammalia/GCF_000001635.27_GRCm39_genomic.fna"
    )

declare -A TELIB=(
    ["Danio_rerio"]="/Users/jonwells/Genomes/RepBase/RepBase26.10.fasta/zebrep.ref"
    ["Homo_sapiens"]="/Users/jonwells/Genomes/RepBase/RepBase26.10.fasta/humrep.ref"
    ["Mus_musculus"]="/Users/jonwells/Genomes/RepBase/RepBase26.10.fasta/rodrep.ref"
    )

for species in ${!GENOMELIB[@]}; do
    echo $species
    blastn \
        -query "../../data/binding-predictions/${species}/${species}_binding_predictions.fa" \
        -subject ${TELIB[$species]} \
        -task blastn-short \
        -evalue 0.1 \
        -outfmt 6 \
        -out "../../data/binding-predictions/${species}/${species}_blasted_tes.out"

    # Generate random motifs
    nseqs=$(rg -c '>' ${TELIB[$species]})
    at_count=$(rg -v '>' ${GENOMELIB[$species]} | rg --count-matches --ignore-case "T|A")
    gc_count=$(rg -v '>' ${GENOMELIB[$species]} | rg --count-matches --ignore-case "G|C")
    python3 -c "
from random import choices 
from sys import argv 
gc, at, nseqs = float(argv[1]), float(argv[2]), int(argv[3]) 
a, b = (gc/(gc+at))/2.0, (at/(gc+at))/2.0
print('\n'.join([f'>{i}\n' + ''.join(choices(['A', 'C', 'G', 'T'], [b, a, a, b], k=12)) for i in range(nseqs)]))
" $gc_count $at_count $nseqs > "${species}_random_motifs.fa"

    blastn \
        -query "${species}_random_motifs.fa" \
        -subject ${TELIB[$species]} \
        -task blastn-short \
        -evalue 0.1 \
        -outfmt 6 \
        -out "../../data/binding-predictions/${species}/${species}_shuffle_blasted_tes.out"
    wc -l "../../data/binding-predictions/${species}/${species}_blasted_tes.out"
    wc -l "../../data/binding-predictions/${species}/${species}_shuffle_blasted_tes.out"
done
