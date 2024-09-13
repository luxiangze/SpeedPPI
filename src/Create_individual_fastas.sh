#!/bin/bash
# Create individual fastas
# ARGS
# INPUT
FASTA_SEQS=$1 # fasta seqs directory
OUTDIR=$2 # Output directory

for FASTA in "$FASTA_SEQS"/*.fa
do
  ID=$(basename "$FASTA" .fa)
  echo "Processing $ID"
  FASTADIR="$OUTDIR/fasta/$ID"
  
  if [ -f "$FASTADIR/id_seqs.csv" ]; then
    echo "$FASTADIR already exists."
    echo "Remove the directory $FASTADIR if you want to write new fastas."
  else
    echo "Creating fastas for $ID"
    mkdir -p "$FASTADIR"
    python3 ./src/preprocess_fasta.py --fasta_file "$FASTA" --outdir "$FASTADIR"
    echo "Writing fastas of each sequence to $FASTADIR"
  fi
done
