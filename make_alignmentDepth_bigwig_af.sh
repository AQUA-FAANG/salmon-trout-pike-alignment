#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=16G
#SBATCH --constraint=avx2
#SBATCH --job-name=halAlignmentDepth


CACTUS="singularity exec --contain --bind /mnt/SCRATCH/lagr/aqua-faang/cactus:/data_af --pwd / cactus_v2.7.1.sif"

OUTDIR=$SCRATCH/halAlignmentDepth/Ssal_Ancestors_af

mkdir -p $OUTDIR

$CACTUS halAlignmentDepth data_af/aqua-faang.hal salmo_salar_gca905237065v2  --step 1 \
  --targetGenomes Anc5,Anc0,Anc2 > $OUTDIR/all.wig

wigToBigWig $OUTDIR/all.wig chrom.sizes $OUTDIR/all.bw

rm $OUTDIR/all.wig
