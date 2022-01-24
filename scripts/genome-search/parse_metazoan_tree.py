#!/usr/bin/env python

import treeswift as ts

tree = ts.read_tree_newick('../data/metazoan_tree.nwk')
for node in tree.root.traverse_bfs():
    if node[0].label == "'Porifera'":
        print([i.label.strip("'").replace(' ', '_') for i in node[0].traverse_leaves()])
        break

