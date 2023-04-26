#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=5G
#SBATCH --constraint=avx2
#SBATCH --job-name=halLiftover
#SBATCH --array=1-29

CACTUS_SIF="cactus_v2.4.4.sif"

# Usage: sbatch run_halLiftover.job.sh <in_prefix> <out_prefix> <src_genome> <target_genome>

INPUT_FILE=${1}ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID).bed
OUTPUT_FILE=${2}ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID).bed
HAL_FILE=data/blocks/ssa$(printf "%02d" $SLURM_ARRAY_TASK_ID)/output.hal
echo INPUT_FILE:$INPUT_FILE
echo OUTPUT_FILE:$OUTPUT_FILE
echo Source genome: $3
echo Target genome: $4

# halLiftover [Options] <halFile> <srcGenome> <srcBed> <tgtGenome> <tgtBed>
singularity exec --contain --bind .:/data -H /data  $CACTUS_SIF halLiftover \
  --noDupes $HAL_FILE $3 $INPUT_FILE $4 $OUTPUT_FILE

# Note: the binaries in the image are in the /home directory which is bound by default on Orion.
# the --contain option overrides default bindings.

