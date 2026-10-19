#!/usr/bin/env python3
import argparse
from pathlib import Path
from collections import defaultdict

parser = argparse.ArgumentParser(description='')
parser.add_argument('-i', '--input', help='input file', required=True)
parser.add_argument('-s', '--size', help='label size', default='10,8')
args = parser.parse_args()

input_file = args.input
output_file = Path(input_file).stem + '_0_1.png'
link_ancestor = Path(input_file).parent / 'link.ancestor'
tax_name_file = Path(input_file).parent / '../additional_info/taxid_nodes/taxid_node.names'
tax_parent_file = Path(input_file).parent / '../additional_info/taxid_nodes/taxid_node.parents'

name_map = {}
with open(tax_name_file) as f:
    for line in f:
        cols = line.rstrip('\n').split('\t')
        if len(cols) == 2:
            name_map[cols[0]] = cols[1]

parent_map = {}
with open(tax_parent_file) as f:
    for line in f:
        cols = line.rstrip("\n").split('\t')
        if len(cols) == 2:
            parent_map[cols[0]] = cols[1]

import matplotlib
matplotlib.use('Agg')  # Use a non-interactive backend for saving the figure
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import numpy as np

import pandas as pd

df = pd.read_csv(
    input_file,
    sep='\t',
    header=None,
    names=['taxid', 'motif', 'count']
)

taxid_order = df['taxid'].drop_duplicates().tolist()
motif_order = df['motif'].drop_duplicates().tolist()


mat = df.pivot(index='taxid', columns='motif', values='count').fillna(0)
mat = mat.reindex(index=taxid_order, columns=motif_order)

def sort_taxids(taxids):
    displayed = set(taxids)
    children = defaultdict(list)
    roots = []

    for taxid in taxids:
        node = taxid.removeprefix('tax:')
        parent = parent_map.get(node)
        visited = {node}

        while parent is not None and parent not in visited:
            if f'tax:{parent}' in displayed:
                break

            visited.add(parent)
            parent = parent_map.get(parent)

        if parent is not None and f'tax:{parent}' in displayed and parent not in visited:
            children[f'tax:{parent}'].append(taxid)
        else:
            roots.append(taxid)

    ordered = []
    prefixes = {}

    def visit(taxid, prefix=''):
        ordered.append(taxid)
        prefixes[taxid] = prefix

        siblings = children[taxid]

        for i, child in enumerate(siblings):
            is_last = (i == len(siblings) - 1)

            if prefix:
                # 親のツリー構造を引き継ぐ
                continuation = prefix[:-2] + (
                    '   ' if prefix.endswith('└ ') else '│  '
                )
            else:
                continuation = ''

            branch = '└ ' if is_last else '├ '
            visit(child, continuation + branch)

    for root in roots:
        visit(root)

    return ordered, prefixes

taxid_order, prefixes = sort_taxids(taxid_order)
mat = mat.reindex(index=taxid_order)

cmap = ListedColormap(['white', 'steelblue'])
# cmap = ListedColormap(['white', 'forestgreen'])

# plt.imshow(mat.values
#            , cmap='YlOrRd'
#            , aspect='auto'
#            )

binary = (mat.values > 0).astype(int)
plot = plt.imshow(binary, cmap=cmap, aspect='auto')

plt.xticks(ticks=np.arange(len(mat.columns)), labels=mat.columns, rotation=90)

new_labels = []
for taxid in mat.index:
    name = name_map.get(taxid.removeprefix('tax:'), taxid)
    label = f'{name} ({taxid})'
    new_labels.append(prefixes[taxid] + label)

plt.yticks(
    ticks=np.arange(len(mat.index)),
    labels=new_labels,
    fontfamily='monospace'
)

ax = plt.gca()
for label in ax.get_yticklabels():
    label.set_ha('left')
    label.set_x(-0.58)

ax.set_xticks(np.arange(binary.shape[1] + 1) - 0.5, minor=True)
ax.set_yticks(np.arange(binary.shape[0] + 1) - 0.5, minor=True)
ax.grid(which='minor', color='black', linewidth=0.2)
ax.tick_params(which='minor', bottom=False, left=False)  # Hide minor ticks

ax.xaxis.tick_top()  # Move x-axis ticks to the top
ax.tick_params(axis='x', labelsize=args.size)
ax.tick_params(axis='y', labelsize=args.size)
plt.tick_params(axis='both', length=0)  # Remove tick marks
plt.colorbar(label='count')

plt.subplots_adjust(left=0.3,top=0.82)
plt.savefig(output_file)
