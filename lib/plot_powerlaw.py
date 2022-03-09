#!/usr/bin/env python3
import argparse
import powerlaw
import sys
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser(description='Plot fitted power law distribution')
parser.add_argument('-o', '--outname', help='output file name')
parser.add_argument('-q', '--quiet', action='store_true', help='output values without plot')
args = parser.parse_args()

# fig = plt.figure()
# ax = fig.add_subplot(111)

for line in sys.stdin.readlines():
    fields = line.split('\t')
    if len(fields) != 2:
        print('ERROR: len(fields) != 2', file=sys.stderr)
        sys.exit(1)
    try:
        nums = [int(n) for n in fields[1].split(',')]
    except ValueError as error:
        print(error, file=sys.stderr)
        continue

    results = powerlaw.Fit(nums, discrete=True, estimate_discrete=True)
    xmin = results.xmin
    results = powerlaw.Fit(nums, xmin=1.0)

    print()
    print('CCDF')
    x, y = results.ccdf()
    if len(x) != len(y):
        sys.exit(1)
    for i in range(len(x)):
        print(int(x[i]), y[i], sep='\t')

    print()
    print('PDF')
    bin, prob = results.pdf()
    if len(bin) != len(prob) + 1:
        sys.exit(1)
    for i in range(len(prob)):
        print(f'{int(bin[i])}-{int(bin[i+1])}', prob[i], sep='\t')

    print()
    print('a =', results.alpha)
    print('estimated xmin =', xmin)

    if not args.quiet:
        fig = results.plot_ccdf(linewidth=1, marker='.', color='tab:orange', label='cumulative distribution function')
        results.plot_pdf(ax=fig, linewidth=1, marker='.', color='tab:blue', label='probability density function')
        results.power_law.plot_ccdf(linewidth=1, linestyle=':', color='tab:orange', ax=fig)
        results.power_law.plot_pdf(linewidth=1, linestyle=':', color='tab:blue', ax=fig)
        plt.xlim(0.9, max(max(x), 400))
        # plt.ylim(min(min(y), min(prob), 0.00002), 2.5)
        plt.legend()
        if args.outname:
            plt.savefig(args.outname)
        else:
            plt.show()
