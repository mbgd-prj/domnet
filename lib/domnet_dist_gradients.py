#!/usr/bin/env python3
import os
import argparse
import subprocess
from threading import Thread, Semaphore

parser = argparse.ArgumentParser(description='Execute R in parallel')
parser.add_argument('-i', '--input', required=True, help='input directory')
parser.add_argument('-o', '--output', required=True, help='output directory')
parser.add_argument('-n', '--cores', default=20, type=int, help='Number of CPU cores to be used')
args = parser.parse_args()

semaphore = Semaphore(args.cores)

if args.input:
    input_dir = args.input
if args.output:
    output_dir = args.output

os.makedirs(output_dir, exist_ok=True)

def execute_r(input_file):
    id, _ = input_file.split('.')
    with semaphore:
        subprocess.run(f'cat {input_dir}/{input_file} | domnet_dist_gradient.R | cut -f1 > {output_dir}/{id}', shell=True)

files = os.listdir(input_dir)
for file in files:
    t = Thread(target=execute_r, args=(file,))
    t.start()
