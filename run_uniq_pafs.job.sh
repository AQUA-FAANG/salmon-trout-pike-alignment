#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=10G
#SBATCH --constraint=avx2
#SBATCH --job-name=uniqpafs
#SBATCH --array=1-4

ALL_SUFFIX=("Omyk_vs_Omyk" "Omyk_vs_Ssal" "Ssal_vs_Omyk" "Ssal_vs_Ssal")
SUFFIX=${ALL_SUFFIX[$SLURM_ARRAY_TASK_ID-1]}
echo Task: $SLURM_ARRAY_TASK_ID
echo Suffix: $SUFFIX

OUTDIR="data/salmon-trout-pike_pafs_merged"
sort $OUTDIR/$SUFFIX.paf | uniq | sort -k 6,8n -t$'\t'> $OUTDIR/$SUFFIX.uniq.paf
