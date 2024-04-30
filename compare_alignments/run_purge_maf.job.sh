#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=5G
#SBATCH --constraint=avx2
#SBATCH --job-name=purgemaf
#SBATCH --array=1-29%10


DATA_DIR="/mnt/SCRATCH/lagr/aqua-faang/cactus"

CHROM=$SLURM_ARRAY_TASK_ID
MAF_FILE="Ssal_$(printf "%02d" $CHROM).maf"
MAF_FILTERED="Ssal_$(printf "%02d" $CHROM)_filtered.maf"

echo "Filtering maf..."

# conda activate biopython

python purgeSameChromAlignments.py $DATA_DIR/$MAF_FILE $DATA_DIR/$MAF_FILTERED

echo "done..."
