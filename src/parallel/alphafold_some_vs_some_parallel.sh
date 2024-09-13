#!/bin/bash -x
#SBATCH --output="data/results/step3_DHX15_out.txt"
#SBATCH --error="data/results/step3_DHX15_error.txt"
#SBATCH -A "td20170508"
#SBATCH --array=1-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2 #How many CPUs to use
#SBATCH --mem-per-cpu=4000 #Memory in Mb per CPU
#SBATCH --export=ALL
#SBATCH --gres=gpu:1
#SBATCH --partition=hpc_gpu #Partition to use according your needs

#Load the necessary modules (e.g. python)
offset=$1
OUTDIR=$2 # path to output
FASTADIR1=$3 # path to individual fasta seqs 1 created in step 1
FASTADIR2=$4 # path to individual fasta seqs 2 created in step 1

LN=$(($SLURM_ARRAY_TASK_ID + $offset))
#Get ID
ID=$(awk -F, -v line="$LN" 'NR==line {print $1}' "$FASTADIR1/id_seqs.csv")
echo $ID
echo "LN = $LN"
# Fasta with sequences to use for the PPI network
MSADIR=$OUTDIR/msas/
PR_CSV1=$FASTADIR1/id_seqs.csv
PR_CSV2=$FASTADIR2/id_seqs.csv
DATADIR="data/"
RECYCLES=10
PDOCKQ_T=0.5
NUM_CPUS=2

# 创建输出目录
mkdir -p $OUTDIR'/pred'$LN'/'

# 打印当前运行的信息
echo Running pred $c out of $NUM_PREDS

# 运行 AlphaFold2 预测
python3 "/public/home/td20170508/SpeedPPI/src/run_alphafold_some_vs_some.py" \
  --protein_csv1 $PR_CSV1 \
  --protein_csv2 $PR_CSV2 \
  --target_row $LN \
  --msa_dir $MSADIR \
  --data_dir $DATADIR \
  --max_recycles $RECYCLES \
  --pdockq_t $PDOCKQ_T \
  --num_cpus $NUM_CPUS \
  --output_dir $OUTDIR'/pred'$LN'/'