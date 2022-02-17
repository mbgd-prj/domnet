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
    fig = powerlaw.plot_pdf(nums, color='tab:blue')
    powerlaw.plot_ccdf(nums, ax=fig, color='tab:orange')
    plt.show()
