#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=5G
#SBATCH --constraint=avx2
#SBATCH --job-name=countAlignedAlt
#SBATCH --array=1-29%10

set -e -x

DATA_DIR="/mnt/SCRATCH/lagr/aqua-faang/cactus"

CHROM=$SLURM_ARRAY_TASK_ID
MAF_FILTERED="$DATA_DIR/Ssal_$(printf "%02d" $CHROM)_filtered.maf"
MAF_INDEX="${MAF_FILTERED}index"

OUTDIR="counts_alt"
mkdir -p $OUTDIR

OUTFILE="$OUTDIR/Ssal_$(printf "%02d" $CHROM)_counts.tsv"

echo "counting aligned bases in $MAF_FILTERED..."

# conda activate biopython

python countAlignedCDS.py \
  --chrom $CHROM \
  --refGenome salmo_salar_gca905237065v2 \
  --mafFile $MAF_FILTERED --mafindexFile $MAF_INDEX \
  --cdsCoordsFile cdsCoords_Ssal22.tsv \
  --outFile $OUTFILE

echo "done..."
