#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=20G
#SBATCH --constraint=avx2
#SBATCH --job-name=miniminimap

set -x

QUERY_SPC=$1
QUERY_REGION=$2
TARGET_SPC=$3
TARGET_REGION=$4
OUT_PREFIX=$5

TARGET_REGION=$(echo $TARGET_REGION | sed 's/,//g; s/\.\./-/')
TARGET_PREFIX=$(echo $TARGET_REGION | sed 's/:/-/g')

QUERY_REGION=$(echo $QUERY_REGION | sed 's/,//g; s/\.\./-/')
QUERY_PREFIX=$(echo $QUERY_REGION | sed 's/:/-/g')

set +x

declare -A spc2fasta=(
    ["Ssal"]="/mnt/project/ELIXIR/salmobase/datafiles/genomes/AtlanticSalmon/Ssal_v3.1/sequence_Ensembl/Salmo_salar.Ssal_v3.1.dna_sm.toplevel.fa.gz"
    ["Omyk"]="/mnt/project/ELIXIR/salmobase/datafiles/genomes/RainbowTrout/USDA_OmykA_1.1/sequence_Ensembl/Oncorhynchus_mykiss.USDA_OmykA_1.1.dna_sm.toplevel.fa.gz"
)

QUERY_FASTA=${spc2fasta[$QUERY_SPC]}
TARGET_FASTA=${spc2fasta[$TARGET_SPC]}

set -x

module load SAMtools
samtools faidx $TARGET_FASTA $TARGET_REGION > data/$TARGET_PREFIX.fa
samtools faidx $QUERY_FASTA $QUERY_REGION > data/$QUERY_PREFIX.fa

module load minimap2
minimap2 -cL data/$TARGET_PREFIX.fa data/$QUERY_PREFIX.fa > data/$OUT_PREFIX.tmp.paf

module load R/4.0.4
Rscript fix_paf.R data/$OUT_PREFIX.tmp.paf data/$OUT_PREFIX.paf
