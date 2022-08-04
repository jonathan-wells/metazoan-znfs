#!/usr/bin/env bash

################################################################################
## Process ChIP-exo motifs
################################################################################

echo processing MEME motifs

# # Rename Human ChIP-exo meme motifs
# for file in ../../data/binding-predictions/GSE78099_RAW/*.bed; do
#     znf=$(awk -F '_' '{ print $3 }' <<< $file)
#     if [ ! -f "${znf}.meme" ]; then
#         sed "s/MEME-1/${znf}/" ../../data/binding-predictions/GSE78099_RAW/${znf}/meme.txt \
#             > "${znf}.meme"
#     fi
# done

# # Compile all ZNF meme motifs into single file
# if [ ! -s ../../data/binding-predictions/GSE78099_RAW/imbeault_motifs.meme ]; then 
#     /usr/local/meme-5.3.3/src/meme2meme *.meme > ../../data/binding-predictions/GSE78099_RAW/imbeault_motifs.meme
# fi
# rm *.meme

################################################################################
## Control to demonstrate accuracy of ZifRC prediction program
################################################################################

echo Running accuracy control

# if [ ! -d ../../data/binding-predictions/meme-out/Homo_sapiens ]; then
#     mkdir ../../data/binding-predictions/meme-out/Homo_sapiens
# fi

# # Confirm that ChIP-exo motifs match TEs
# if [ -d ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_te ]; then
#     rm -r ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_te
# fi    

# /usr/local/meme-5.3.3/src/fasta-get-markov \
#     ~/Genomes/RepBase/RepBase26.10.fasta/Homo_sapiens_nosat.fa \
#     > ../../data/binding-predictions/meme-out/Homo_sapiens/background.txt
# fimo \
#     --qv-thresh \
#     --thresh 5e-2 \
#     --bfile ../../data/binding-predictions/meme-out/Homo_sapiens/background.txt \
#     -o ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_te \
#     ../../data/binding-predictions/GSE78099_RAW/imbeault_motifs.meme \
#     ~/Genomes/RepBase/RepBase26.10.fasta/Homo_sapiens_nosat.fa &

# Run tomtom to compare human chipexo motifs with predicted ones.
if [ -d ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_predicted ]; then
    rm -r ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_predicted
fi    
tomtom \
    -norc \
    -o ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_predicted \
    ../../data/binding-predictions/GSE78099_RAW/imbeault_motifs.meme \
    ../../data/binding-predictions/GSE78099_RAW/matched_predicted_motifs.meme &

# Run tomtom to compare human chipexo motifs with shuffled ones.
if [ -d ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_shuffled ]; then
    rm -r ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_shuffled
fi    
tomtom \
    -norc \
    -o ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_shuffled \
    ../../data/binding-predictions/GSE78099_RAW/imbeault_motifs.meme \
    ../../data/binding-predictions/GSE78099_RAW/matched_predicted_motifs.shuffled.meme

#################################################################################
### Control to demonstrate specificity of ZifRC prediction program
#################################################################################

#echo Running specificity control

## Confirm that ChIP-exo motifs match TEs
#if [ -d ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_danio ]; then
#    rm -r ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_danio
#fi

#/usr/local/meme-5.3.3/src/fasta-get-markov \
#    ~/Genomes/RepBase/RepBase26.10.fasta/Danio_rerio_nosat.fa \
#    > ../../data/binding-predictions/meme-out/Homo_sapiens/danio_background.txt
#fimo \
#    --qv-thresh \
#    --thresh 5e-2 \
#    --bfile ../../data/binding-predictions/meme-out/Homo_sapiens/danio_background.txt \
#    -o ../../data/binding-predictions/meme-out/Homo_sapiens/chipexo_vs_danio \
#    ../../data/binding-predictions/GSE78099_RAW/imbeault_motifs.meme \
#    ~/Genomes/RepBase/RepBase26.10.fasta/Danio_rerio_nosat.fa &

# # Run tomtom to compare human chipexo motifs with predicted ones.
# if [ -d ../../data/binding-predictions/meme-out/Homo_sapiens/predicted_vs_danio ]; then
#     rm -r ../../data/binding-predictions/meme-out/Homo_sapiens/predicted_vs_danio
# fi

# fimo \
#     --qv-thresh \
#     --thresh 5e-2 \
#     --bfile ../../data/binding-predictions/meme-out/Homo_sapiens/danio_background.txt \
#     -o ../../data/binding-predictions/meme-out/Homo_sapiens/predicted_vs_danio \
#     ../../data/binding-predictions/Homo_sapiens/Homo_sapiens_znf_binding.meme \
#     ~/Genomes/RepBase/RepBase26.10.fasta/Danio_rerio_nosat.fa

################################################################################
## Test predicted binding sequences against TE libraries  
################################################################################

# species=(
#     Homo_sapiens
#     Mus_musculus
#     Danio_rerio
#     Octopus_sinensis
#     Sitophilus_oryzae
#     Drosophila_melanogaster
#     Strongylocentrotus_purpuratus
#     )


# for sp in ${species[@]}; do
#     echo $sp 

    # if [ -d ../../data/binding-predictions/meme-out/${sp}/predicted_vs_te ]; then
    #     rm -r ../../data/binding-predictions/meme-out/${sp}/predicted_vs_te
    # fi
    
    # if [ -d ../../data/binding-predictions/meme-out/${sp}/shuffled_vs_te ]; then
    #     rm -r ../../data/binding-predictions/meme-out/${sp}/shuffled_vs_te
    # fi
    
    # if [ -d ../../data/binding-predictions/meme-out/${sp}/predicted_vs_nonrep ]; then
    #     rm -r ../../data/binding-predictions/meme-out/${sp}/predicted_vs_nonrep
    # fi
    
    # /usr/local/meme-5.3.3/src/fasta-get-markov \
    #     ~/Genomes/RepBase/RepBase26.10.fasta/${sp}_nosat.fa \
    #     > ../../data/binding-predictions/meme-out/${sp}/background.txt
    
    # /usr/local/meme-5.3.3/src/fasta-get-markov \
    #     ../../data/binding-predictions/${sp}/${sp}_nonrep.fa \
    #     > ../../data/binding-predictions/meme-out/${sp}/nonrep_background.txt
    
    # # Run predicted
    # fimo \
    #     --qv-thresh \
    #     --thresh 5e-2 \
    #     --bfile ../../data/binding-predictions/meme-out/${sp}/background.txt \
    #     -o ../../data/binding-predictions/meme-out/${sp}/predicted_vs_te \
    #     ../../data/binding-predictions/${sp}/${sp}_znf_binding.meme \
    #     ~/Genomes/RepBase/RepBase26.10.fasta/${sp}_nosat.fa &

    # # Run shuffled
    # fimo \
    #     --qv-thresh \
    #     --thresh 5e-2 \
    #     --bfile ../../data/binding-predictions/meme-out/${sp}/background.txt \
    #     -o ../../data/binding-predictions/meme-out/${sp}/shuffled_vs_te \
    #     ../../data/binding-predictions/${sp}/${sp}_znf_binding.shuffled.meme \
    #     ~/Genomes/RepBase/RepBase26.10.fasta/${sp}_nosat.fa &
    
    # # Run nonrepetitive
    # fimo \
    #     --qv-thresh \
    #     --thresh 5e-2 \
    #     --bfile ../../data/binding-predictions/meme-out/${sp}/nonrep_background.txt \
    #     -o ../../data/binding-predictions/meme-out/${sp}/predicted_vs_nonrep \
    #     ../../data/binding-predictions/${sp}/${sp}_znf_binding.meme \
    #     ../../data/binding-predictions/${sp}/${sp}_nonrep.fa

# done
