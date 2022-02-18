#!/usr/bin/env python3
import argparse
import powerlaw
import sys

parser = argparse.ArgumentParser(description='Fit data to power law distribution')
parser.add_argument('-o', '--outfile', help='output file name')
args = parser.parse_args()

f = sys.stdout
if args.outfile:
    f = open(args.outfile, mode='w')

for line in sys.stdin.readlines():
    fields = line.split('\t')
    if len(fields) != 2:
        sys.exit(1)
    nums = [int(n) for n in fields[1].split(',')]
    results = powerlaw.Fit(nums, xmin=1.0)
    # R, p = results.distribution_compare('power_law', 'lognormal')
    R, p = results.distribution_compare('power_law', 'exponential')
    print(fields[0], R, p, results.alpha, file=f, sep='\t', flush=True)

if args.outfile:
    f.close()
