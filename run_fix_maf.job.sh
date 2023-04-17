#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=5G
#SBATCH --constraint=avx2
#SBATCH --job-name=maf_fix
#SBATCH --array=1-29%10

BLOCK_DIR="data/blocks/ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID)"
echo $BLOCK_DIR
MAF_FILE=$BLOCK_DIR/output.maf

mkdir -p data/salmon-trout-pike-AB
MAF_FIXED="data/salmon-trout-pike-AB/ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID)_AB.maf"

echo "Fixing coordinates in maf file..."
python fix_maf.py --keep_subgenome $MAF_FILE chromSizes.tsv > $MAF_FIXED
gzip $MAF_FIXED
