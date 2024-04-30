#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=5G
#SBATCH --constraint=avx2
#SBATCH --job-name=hal2maf
#SBATCH --array=1-29%10


CACTUS_SIF="$HOME/github/AQUA-FAANG/salmon-trout-pike-alignment/cactus_v2.7.1.sif"

DATA_DIR="/mnt/SCRATCH/lagr/aqua-faang/cactus"
HAL_FILE=aqua-faang.hal 

CHROM=$SLURM_ARRAY_TASK_ID
MAF_FILE="Ssal_$(printf "%02d" $CHROM).maf"
MAF_FILTERED="Ssal_$(printf "%02d" $CHROM)_filtered.maf"

echo "Runnning hal2maf $HAL_FILE $MAF_FILE"

singularity exec --contain --bind $DATA_DIR:/data -H /data  $CACTUS_SIF hal2maf \
  --maxBlockLen 1000000 --noAncestors \
  --refGenome salmo_salar_gca905237065v2 \
  --refSequence $CHROM \
  --targetGenomes oncorhynchus_mykiss_gca013265735v3 \
  $HAL_FILE $MAF_FILE

# Note: the binaries in the image are in the /home directory which is bound by default on Orion.
# the --contain option overrides default bindings.

echo "hal2maf done. Filtering maf..."

# conda activate biopython

python purgeSameChromAlignments.py $DATA_DIR/$MAF_FILE $DATA_DIR/$MAF_FILTERED

echo "done..."
