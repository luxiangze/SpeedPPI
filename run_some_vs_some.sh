#!/bin/bash

# Create a PPI network for all sequences in the input fasta file, all vs all.
nohup ./create_ppi_all_vs_all_parallel.sh data/dev/test.fasta hh-suite/bin/hhblits 0.5 data/test_out > run.log 2>&1 &