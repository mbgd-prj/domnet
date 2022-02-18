#!/usr/bin/env python3
import argparse
import powerlaw
import sys
import csv

parser = argparse.ArgumentParser(description='Fit data to power law distribution')
parser.add_argument('-o', '--outfile', help='output file name')
args = parser.parse_args()

f = sys.stdout
if args.outfile:
    f = open(args.outfile, mode='w')

cin = csv.reader(sys.stdin)
for row in cin:
    nums = [int(n) for n in row]
    results = powerlaw.Fit(nums, xmin=1.0)
    # R, p = results.distribution_compare('power_law', 'lognormal')
    R, p = results.distribution_compare('power_law', 'exponential')
    print(R, p, results.alpha, file=f, sep='\t', flush=True)

if args.outfile:
    f.close()
