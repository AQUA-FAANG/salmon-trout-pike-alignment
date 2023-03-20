# Genome alignment with cactus by syntenic blocks

We apply a strategy to improve whole genome alignments by cplitting the genomes into blocks duplicate syntenic regions in the salmonid genomes. We are aligning salmon, trout and pike (Ssal, Omyk, Eluc) where the salmonid genomes are split into two (suffixed _A and _B). The salmonid synteny table contains a manually curated set of regions corresponding to each of the salmon chromosome.

* extractBlocks.R - Reads the synteny table and generates a directory structure (one for each salmon chromosome) and the commands (samtools faidx) needed to extract the corresponding blocks for each (sub-)genome
* run_extractBlocks.job.sh - Actually runs the commands generated. (had to do it this way because I couldn't get samtools to run from R)
* run_cactus.job.sh - slurm array to run cactus for each of the directories (one for salmong chromosome)
* (hal2maf)
* makeChromSizes.R - make a table of chromosome sizes needed for fix_maf
* fix_maf.py - Converts the coordinates from block coordinates to full genome coordinates
* maf2pafs.py - Converts maf file to pairwise .paf files that can be viewed in jbrowse

