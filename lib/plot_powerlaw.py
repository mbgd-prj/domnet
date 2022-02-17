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
    fig = results.plot_ccdf(color='tab:orange', label='cumulative distribution function')
    results.power_law.plot_ccdf(ax=fig, color='tab:orange', linestyle=':')
    results.plot_pdf(ax=fig, color='tab:blue', label='probability density function')
    results.power_law.plot_pdf(ax=fig, color='tab:blue', linestyle=':')
    plt.xlim(1,100)
    plt.legend()
    plt.show()
