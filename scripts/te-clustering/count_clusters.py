#!/usr/bin/env python3

from collections import defaultdict
import os

def read_cluster_file(filename):
    cdict = defaultdict(int)
    with open(filename) as infile:
        for line in infile:
            if line.startswith('>'):
                cluster = line.strip().strip('>')
            else:
                cdict[cluster] += 1
    return cdict

if __name__ == '__main__':
    for filename in list(os.walk('../../data/cd-hit-out/'))[-1][-1]:
        if not filename.endswith('.clstr'):
            continue
        species = filename.split('_retroelements_clustered.fa.clstr')[0]
        cdict = read_cluster_file(f'../../data/cd-hit-out/{filename}')
        c, s = 0, 0
        for key, val in cdict.items():
            if val >= 5:
                # print(key, val)
                c += 1
            else:
                s += 1
        if c + s > 0:
            print(f'{species}\t{c}')


