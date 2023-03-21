#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=5G
#SBATCH --constraint=avx2
#SBATCH --job-name=hal2maf_fix
#SBATCH --array=1-29%10

CACTUS_SIF="cactus_v2.4.4.sif"

BLOCK_DIR="data/blocks/ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID)"
echo $BLOCK_DIR
HAL_FILE=$BLOCK_DIR/output.hal
MAF_FILE=$BLOCK_DIR/output.maf

mkdir -p data/salmon-trout-pike
MAF_FIXED="data/salmon-trout-pike/ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID).maf"


singularity exec --contain --bind .:/data -H /data  $CACTUS_SIF hal2maf \
  --maxBlockLen 1000000 --noAncestors --noDupes \
  --refGenome Ssal_A \
  $HAL_FILE $MAF_FILE

echo "hal2maf complete. Fixing coordinates in maf file..."
python fix_maf.py $MAF_FILE chromSizes.tsv > $MAF_FIXED

# Note: the binaries in the image are in the /home directory which is bound by default on Orion.
# the --contain option overrides default bindings.

