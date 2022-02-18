#!/usr/bin/env python3
import argparse
import powerlaw
import sys
import csv

parser = argparse.ArgumentParser(description='Fit data to power law distribution')
parser.add_argument('-o', '--outfile', help='output file name')
args = parser.parse_args()

if args.outfile:
    f = open(args.outfile, mode='w')

cin = csv.reader(sys.stdin)
for row in cin:
    nums = [int(n) for n in row]
    results = powerlaw.Fit(nums, xmin=1.0)

    # print('a=', results.power_law.alpha)
    # print('s=', results.power_law.sigma)
    # print('xmin=', results.power_law.xmin)

    # powerlaw.plot_pdf(nums, color='b')

    # R, p = results.distribution_compare('power_law', 'lognormal')
    R, p = results.distribution_compare('power_law', 'exponential')
    if args.outfile:
        print(R, p, file=f, sep='\t', flush=True)
    else:
        print(R, p, sep='\t', flush=True)

if args.outfile:
    f.close()
