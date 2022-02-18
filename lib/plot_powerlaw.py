#!/usr/bin/env python3
import powerlaw
import sys
import csv
import matplotlib.pyplot as plt
# fig = plt.figure()
# ax = fig.add_subplot(111)
# line = sys.stdin.readline()

cin = csv.reader(sys.stdin)
for row in cin:
    nums = [int(n) for n in row]
    results = powerlaw.Fit(nums)

    print('ccdf')
    x, y = results.ccdf()
    if len(x) != len(y):
        sys.exit(1)
    for i in range(len(x)):
        print(int(x[i]), y[i], sep='\t')

    print('pdf')
    bin, prob = results.pdf()
    if len(bin) != len(prob) + 1:
        sys.exit(1)
    for i in range(len(prob)):
        print(f'{int(bin[i])}-{int(bin[i+1])}', prob[i], sep='\t')

    fig = results.plot_ccdf(color='tab:orange', label='cumulative distribution function', linewidth=1, marker='.')
    results.power_law.plot_ccdf(ax=fig, color='tab:orange', linestyle=':', linewidth=1)
    results.plot_pdf(ax=fig, color='tab:blue', label='probability density function', linewidth=1, marker='.')
    results.power_law.plot_pdf(ax=fig, color='tab:blue', linestyle=':', linewidth=1)
    plt.xlim(1,100)
    plt.legend()
    plt.show()
