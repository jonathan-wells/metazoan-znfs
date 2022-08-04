#!/usr/bin/env python3

from Bio import motifs
import sys
import random

def write_pfm_consensi(species):
    with open(f'/Users/jonwells/Projects/feschottelab/metazoan-znfs/data/binding-predictions/{species}/{species}_binding_predictions.fa', 'w') as outfile, open(f'/Users/jonwells/Projects/feschottelab/metazoan-znfs/data/binding-predictions/{species}/{species}_shuffled_predictions.fa', 'w') as shuffled_outfile:
        with open(f'/Users/jonwells/Projects/feschottelab/metazoan-znfs/data/binding-predictions/{species}/{species}_znf_binding.txt') as handle:
            for m in motifs.parse(handle, 'ClusterBuster'):
                cons = m.consensus
                if len(cons) < 10:
                    continue
                cons = [c for c in cons]
                cons = ''.join(cons)
                shuffled_cons = ''.join(random.sample(cons, len(cons)))
                outfile.write(f'>{m.name}\n{cons}\n')
                shuffled_outfile.write(f'>{m.name}\n{shuffled_cons}\n')

if __name__ == '__main__':
    write_pfm_consensi(sys.argv[1])
