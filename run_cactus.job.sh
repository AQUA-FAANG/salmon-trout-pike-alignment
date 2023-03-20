#!/bin/bash
#SBATCH --ntasks=25
#SBATCH --nodes=1
#SBATCH --mem=100G
#SBATCH --constraint=avx2
#SBATCH --job-name=cactus
#SBATCH --array=1,2,4-29%3


CACTUS_SIF="/mnt/project/Aqua-Faang/analysis/genome_alignments/scripts/cactus_v2.1.0.sif"

BLOCK_DIR="data/blocks/ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID)"
echo $BLOCK_DIR

rm -rf $BLOCK_DIR/jobStore

# cactus <jobStorePath> <seqFile> <outputHal>

# Bind the BLOCK_DIR to make it accessible inside the container 
# and make that the current dir (home dir)
singularity exec --contain --bind $BLOCK_DIR:/data -H /data $CACTUS_SIF cactus \
  ./jobStore seqFile.txt output.hal \
  --binariesMode local --workDir /data --disableCaching \
  --maxCores $SLURM_NTASKS

# Note: the binaries in the image are in the /home directory which is bound by default on Orion.
# the --contain option overrides default bindings.

