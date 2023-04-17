#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=1G
#SBATCH --constraint=avx2
#SBATCH --job-name=maf2pafs
#SBATCH --array=1-29%5

CHROM="$(printf "ssa%02d" $SLURM_ARRAY_TASK_ID)"
MAF_FILE="data/salmon-trout-pike/$CHROM.maf"
echo $MAF_FILE
OUTDIR="data/salmon-trout-pike_pafs"
mkdir -p $OUTDIR
cat $MAF_FILE | python maf2pafs.py --out_prefix $OUTDIR/${CHROM}_ - Ssal Omyk