#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=4G
#SBATCH --constraint=avx2
#SBATCH --job-name=halAlignmentDepth
#SBATCH --array 1-29


CACTUS="singularity exec --contain --bind data:/data --pwd / cactus_v2.7.1.sif"
# OUTDIR=$SCRATCH/halAlignmentDepth/Ssal_A_to_B
OUTDIR=$SCRATCH/halAlignmentDepth/Ssal_A_Ancestors

mkdir -p $OUTDIR


# Loop through chromosomes 1 to 29
#for CHROM_NUM in {1..29}
#do

#  CHROM="$(printf "ssa%02d" $CHROM_NUM)"
  CHROM="$(printf "ssa%02d" $SLURM_ARRAY_TASK_ID)"

  echo "Processing $CHROM..."

#  $CACTUS halAlignmentDepth data/blocks/$CHROM/output.hal Ssal_A --step 1 \
#    --noAncestors --targetGenomes Ssal_B \
#    | python fix_wiggle.py stdin > $OUTDIR/$CHROM.wig
  $CACTUS halAlignmentDepth data/blocks/$CHROM/output.hal Ssal_A --step 1 \
    --targetGenomes Anc0,Anc1,Anc2 \
    | python fix_wiggle.py stdin > $OUTDIR/$CHROM.wig

  wigToBigWig $OUTDIR/$CHROM.wig chrom.sizes $OUTDIR/$CHROM.bw

  rm $OUTDIR/$CHROM.wig
#done

echo "Done."
