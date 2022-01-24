#!/usr/bin/env python3

import pybedtools as pbt
import sys

def hmmer2bed(filename):
    data = []
    with open(filename) as infile:
        for line in infile:
            if line.startswith('#'):
                continue
            line = line.strip().split()
            target, query = line[0].split('_')[0], line[2]
            score = int(line[11])
            start, stop, description = line[18].strip('['), line[20].strip(']'), ' '.join(line[21:])
            start, stop = int(start), int(stop)
            if start < stop:
                start -=1
                strand = '+'
            else:
                start, stop = stop, start
                start -= 1
                strand = '-'
                
            data.append(f'{target}\t{start}\t{stop}\t{query}\t{score}\t{strand}')
    data = pbt.BedTool('\n'.join(data), from_string=True)
    return data

def merge_retroelements(species):
    """Combines hmmer output for all retroelement domains and merges to remove
    redundancy."""
    retroelement_domains =  ['RVT_1', 
                             'RVT_2', 
                             'RVT_3', 
                             'RNaseH',
                             'RT_RNaseH', 
                             'RT_RNaseH_2', 
                             'rve']
    bedfiles = []
    for domain in retroelement_domains:
        bedfile = hmmer2bed(f'../../data/hmmer-out/{species}_{domain}.out')
        bedfiles.append(bedfile)
    mergedfile = bedfiles[0].cat(*bedfiles[1:], 
                                 postmerge=False,
                                 force_truncate=False)
    mergedfile = mergedfile.sort()
    mergedfile = mergedfile.merge(s=True, d=100, c=[4, 6], o='distinct')
    return mergedfile

def merge_znfs(species, retroelements=None, minznfs=0):
    """Merges overlapping znf domains and filters out short or
    retroelement-derived exons."""
    bedfile = hmmer2bed(f'../../data/hmmer-out/{species}_zf_C2H2.out')
    mergedfile = bedfile.sort().merge(s=True, 
                                      d=100, 
                                      c=[4, 5, 6], 
                                      o=['distinct', 'sum', 'distinct'])

    mergedfile = mergedfile.filter(lambda x: int(x.score) >= minznfs)
    if retroelements:
        mergedfile = mergedfile.subtract(retroelements, A=True)
    return mergedfile

def main(species):
    retroelements = merge_retroelements(species)
    retroelements.saveas(f'../../data/beds/{species}_retroelements.bed')
    znfs = merge_znfs(species, retroelements, 5)
    znfs.saveas(f'../../data/beds/{species}_znfs.bed')

if __name__ == '__main__':
    main(sys.argv[1])

