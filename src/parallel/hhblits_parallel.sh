#!/bin/bash -x
#SBATCH --output="data/results/step2_out.txt"
#SBATCH --error="data/results/step2_error.txt"
#SBATCH -A "td20170508"
#SBATCH --array=1-34 #N is the number of total proteins
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2 #How many CPUs to use
#SBATCH --mem-per-cpu=16000 #Memory in Mb per CPU
#SBATCH --partition=bigmem #Partition to use according your needs

#Args
#input
offset=$1 # useful if more than the max amount of allowed jobs is used
OUTDIR=$2 # path to output
FASTADIR=$3 # path to individual fasta seqs created in step 1
HHBLITS=$4 # path to HHblits
#DEFAULT
UNICLUST="./data/uniclust30_2018_08/uniclust30_2018_08" # path to Uniclust30, according to setup

# Load the necessary modules (e.g. python)

LN=$(($SLURM_ARRAY_TASK_ID+$offset))
#Get ID
ID=$(awk -F, -v line="$LN" 'NR==line {print $1}' "$FASTADIR/id_seqs.csv")
echo $ID

MSADIR=$OUTDIR/msas/
mkdir -p $MSADIR

FASTA=$FASTADIR/$ID'.fasta'

# Run HHblits to create MSA
echo $ID
if [ -f "$MSADIR/$ID.a3m" ]; then
  echo $MSADIR/$ID.a3m exists
else
  echo Creating MSA for $ID
  $HHBLITS -i $FASTA -d $UNICLUST -E 0.001 -all -oa3m $MSADIR/$ID'.a3m'
fi
