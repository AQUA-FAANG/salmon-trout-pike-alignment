#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=5G
#SBATCH --constraint=avx2
#SBATCH --job-name=countAlignedAF
#SBATCH --array=1-29%10

set -e -x


MAF_GZ_DIR="/mnt/project/Aqua-Faang/lars/genome_alignments/trial_cactus/data/maf_ref_Ssal_A"
MAF_TMP_DIR=$TMPDIR

CHROM=$SLURM_ARRAY_TASK_ID
MAF_BASENAME="ssa$(printf "%02d" $CHROM)_AB.maf"
MAF=$MAF_TMP_DIR/$MAF_BASENAME
MAF_GZ=$MAF_GZ_DIR/$MAF_BASENAME.gz

OUTDIR="counts"
mkdir -p $OUTDIR

OUTFILE="$OUTDIR/Ssal_$(printf "%02d" $CHROM)_counts.tsv"

echo "Unzipping $MAF_GZ..."
gunzip -c $MAF_GZ > $MAF

MAF_INDEX="${MAF}index"

echo "counting aligned bases in $MAF..."

# conda activate biopython

python countAlignedCDS.py \
  --chrom $CHROM \
  --refGenome Ssal_A \
  --mafFile $MAF --mafindexFile $MAF_INDEX \
  --cdsCoordsFile cdsCoords_Ssal22.tsv \
  --outFile $OUTFILE

rm $MAF_INDEX
rm $MAF
echo "done..."
