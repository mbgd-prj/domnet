#!/usr/bin/env python3.4
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
    try:
        nums = [int(n) for n in fields[1].split(',')]
    except ValueError as error:
        print(error, file=sys.stderr)
        continue
    results = powerlaw.Fit(nums, xmin=1.0)
    # R, p = results.distribution_compare('power_law', 'lognormal')
    R, p = results.distribution_compare('power_law', 'exponential', normalized_ratio=True)
    # R, p = results.distribution_compare('power_law', 'truncated_power_law')
    print(fields[0], R, p, results.alpha, file=f, sep='\t', flush=True)

if args.outfile:
    f.close()
