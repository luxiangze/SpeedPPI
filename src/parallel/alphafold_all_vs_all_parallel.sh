#!/bin/bash -x
#SBATCH --output="data/test_out/step3_out.txt"
#SBATCH --error="data/test_out/step3_error.txt"
#SBATCH -A "td20170508"
#SBATCH -t 08:00:00 #Set at 8 hours
#SBATCH --array=1-5 #N is the number of total proteins
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16 #How many CPUs to use
#SBATCH --mem-per-cpu=4000 #Memory in Mb per CPU
#SBATCH --export=ALL,CUDA_VISIBLE_DEVICES
#SBATCH --gpus=1
#SBATCH --partition=hpc_gpu #Partition to use according your needs

#Args
#input
offset=$1 # useful if more than the max amount of allowed jobs is used
OUTDIR=$2 # path to output
FASTADIR=$3 # path to individual fasta seqs created in step 1, fasta with sequences to use for the PPI network.
PDOCKQ_T=$4 # threshold to construct edges (links) is 0.5
#DEFAULT
MSADIR=$OUTDIR/msas/
PR_CSV=$FASTADIR/id_seqs.csv
DATADIR="data"
RECYCLES=10
NUM_CPUS=1

#Load the necessary modules (e.g. python)

LN=$(($SLURM_ARRAY_TASK_ID+$offset))
#Get ID
ID=$(awk -F, -v line="$LN" 'NR==line {print $1}' "$FASTADIR/id_seqs.csv")
echo $ID

# Predict the structure using a modified version of AlphaFold2 (FoldDock)
# The predictions continue where they left off if the run is timed out

mkdir $OUTDIR"/pred'$LN'/"
echo Running pred $c out of $NUM_PREDS
python3 /public/home/td20170508/SpeedPPI/src/run_alphafold_all_vs_all.py --protein_csv $PR_CSV \
--target_row $LN \
--msa_dir $MSADIR \
--data_dir $DATADIR \
--max_recycles $RECYCLES \
--pdockq_t $PDOCKQ_T \
--num_cpus $NUM_CPUS \
--output_dir $OUTDIR'/pred'$LN'/'
