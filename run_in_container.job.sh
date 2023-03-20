#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=20G
#SBATCH --constraint=avx2
#SBATCH --job-name=cactus_tools

CACTUS_SIF="cactus_v2.4.4.sif"

singularity exec --contain --bind .:/data -H /data $CACTUS_SIF $@

# Note: the binaries in the image are in the /home directory which is bound by default on Orion.
# the --contain option overrides default bindings.

