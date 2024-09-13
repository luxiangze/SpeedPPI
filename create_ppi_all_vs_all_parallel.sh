#!/bin/bash
#Create a PPI network

#ARGS
#INPUT
FASTA_SEQS=$1 #All fasta seqs
HHBLITS=$2 #Path to HHblits
PDOCKQ_T=$3
OUTDIR=$4


#The pipeline starts here
#1. Create individual fastas
FASTADIR=$OUTDIR/fasta/
if [ -f "$FASTADIR/id_seqs.csv" ]; then
  echo Fastas exist...
  echo "Remove the directory $FASTADIR if you want to write new fastas."
else
mkdir -p $FASTADIR
python3 ./src/preprocess_fasta.py --fasta_file $FASTA_SEQS \
--outdir $FASTADIR
echo "Writing fastas of each sequence to $FASTADIR"
fi
wait

#2. Run HHblits for all fastas to create MSAs in cluster.
jobid=$(sbatch src/parallel/hhblits_parallel.sh 0 $OUTDIR $FASTADIR $HHBLITS | awk '{print $4}')

# waiting for the HHblits run to finish
while squeue -u $USER | grep -q "$jobid"; do
    sleep 5
done

# checking if the HHblits job completed successfully.
sacct -j $jobid --format=State | grep -q COMPLETED

if [ $? -eq 0 ]; then
  echo "HHblits run successful."
else
  echo "HHblits run failed."
  exit 1
fi

#3. Predict the structure using a modified version of AlphaFold2 (FoldDock) in cluster.

jobid=$(sbatch src/parallel/alphafold_all_vs_all_parallel.sh 0 $OUTDIR $FASTADIR $PDOCKQ_T | awk '{print $4}')

# waiting for the AlphaFold2 (FoldDock) run to finish
while squeue -u $USER | grep -q "$jobid"; do
    sleep 5
done

# checking if the AlphaFold2 (FoldDock) job completed successfully.
sacct -j $jobid --format=State | grep -q COMPLETED

if [ $? -eq 0 ]; then
  echo "HHblits run successful."
else
  echo "HHblits run failed."
  exit 1
fi

# checking if above command is successful.
if [ $? -eq 0 ]; then
  echo "AlphaFold2 (FoldDock) run successful."
else
  echo "AlphaFold2 (FoldDock) run failed."
  exit 1
fi

#4. Merge all predictions to construct a PPI network.
#When the pDockQ > 0.5, the PPV is >0.9 (https://www.nature.com/articles/s41467-022-28865-w, https://www.nature.com/articles/s41594-022-00910-8)
#The default threshold to construct edges (links) is 0.5
python3 ./src/build_ppi.py --pred_dir $OUTDIR/ \
--pdockq_t $PDOCKQ_T --outdir $OUTDIR/

#5. Move all high-confidence predictions to a dir
mkdir $OUTDIR'/high_confidence_preds/'
mv $OUTDIR/pred*/*.pdb $OUTDIR'/high_confidence_preds/'
echo Moved all high confidence predictions to $OUTDIR'/high_confidence_preds/'
