#!/usr/bin/env python3
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description='')
parser.add_argument('-i', '--input', help='input file', required=True)
parser.add_argument('-s', '--size', help='label size', default='10,8')
args = parser.parse_args()

input_file = args.input
output_file = Path(input_file).stem + '_0_1.png'
link_ancestor = Path(input_file).parent / 'link.ancestor'

label_map = {}
with open(link_ancestor) as f:
    for line in f:
        cols = line.rstrip("\n").split('\t')
        if len(cols) >= 5:
            label_map[cols[4]] = cols[3]

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

cmap = ListedColormap(['white', 'steelblue'])
# cmap = ListedColormap(['white', 'forestgreen'])

# plt.imshow(mat.values
#            , cmap='YlOrRd'
#            , aspect='auto'
#            )

binary = (mat.values > 0).astype(int)
plot = plt.imshow(binary, cmap=cmap, aspect='auto')

plt.xticks(ticks=np.arange(len(mat.columns)), labels=mat.columns, rotation=90)
new_labels = [label_map.get(label, label) for label in mat.index]
# plt.yticks(ticks=np.arange(len(mat.index)), labels=mat.index)
plt.yticks(ticks=np.arange(len(mat.index)), labels=new_labels)

ax = plt.gca()
ax.set_xticks(np.arange(binary.shape[1] + 1) - 0.5, minor=True)
ax.set_yticks(np.arange(binary.shape[0] + 1) - 0.5, minor=True)
ax.grid(which='minor', color='black', linewidth=0.2)
ax.tick_params(which='minor', bottom=False, left=False)  # Hide minor ticks

ax.xaxis.tick_top()  # Move x-axis ticks to the top
ax.tick_params(axis='x', labelsize=args.size)
ax.tick_params(axis='y', labelsize=args.size)
plt.tick_params(axis='both', length=0)  # Remove tick marks
plt.colorbar(label='count')
plt.savefig(output_file)
