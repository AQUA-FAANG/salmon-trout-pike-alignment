#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=10G
#SBATCH --constraint=avx2
#SBATCH --job-name=mergeBigWigs

# OUTDIR=$SCRATCH/halAlignmentDepth/Ssal_A_to_B
OUTDIR=$SCRATCH/halAlignmentDepth/Ssal_A_Ancestors


echo "Merging..."

bigWigMerge $(ls $OUTDIR/ssa*.bw) $OUTDIR/all.bedGraph 

echo "Converting bedGraphToBigWig..."
bedGraphToBigWig $OUTDIR/all.bedGraph chrom.sizes $OUTDIR/all.bw
rm $OUTDIR/all.bedGraph
echo "Done."
