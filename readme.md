# Genome alignment with cactus by syntenic blocks

We apply a strategy to improve whole genome alignments by splitting the genomes into __blocks__ of duplicate syntenic regions in the salmonid genomes. We are aligning salmon, trout and pike (Ssal, Omyk, Eluc) where the duplicated salmonid genomes are split into two __sub-genomes__ (suffixed _A and _B). The salmonid synteny table contains a manually curated set of regions corresponding to each of the salmon chromosome. Note that the table uses salmon chromosome as reference for each block, i.e. the each block contains an entire Ssal chromosome as Ssal_A, but for the other genomes it can contain multiple regions from multiple chromosomes. Each block can be identified using Ssal_A as the block ID (e.g. ssa01).

The first step is to extract the sequences for each synteny block. The names of the extracted sequences are

* extractBlocks.R - Reads the synteny table and generates a directory structure (one for each salmon chromosome) and the commands (samtools faidx) needed to extract the corresponding blocks for each (sub-)genome
* run_extractBlocks.job.sh - Actually runs the commands generated. (had to do it this way because I couldn't get samtools to run from R)
* run_cactus.job.sh - slurm array to run cactus for each of the directories (one for salmong chromosome)
* run_hal2maf.job.sh - slurm array that runs hal2maf and fix_maf.py (writes data/salmon-trout-pike)
* run_fix_maf.job.sh - slurm array to run fix_maf only (with keeping the A/B suffix)
* makeChromSizes.R - make a table of chromosome sizes needed for fix_maf
* fix_maf.py - Converts the coordinates from block coordinates to full genome coordinates (optionally keep the _A/_B suffix)
* maf2pafs.py - Converts maf file to pairwise .paf files that can be viewed in jbrowse



## halLiftover bed files with synteny block alignments

Since the hal files contains subsequences we need to convert any coordinates to "block coordinates", i.e. coordinates relative to the sub-sequences. We also need to split the bed file since each block has its own hal file. Then halLiftover can be ran for each block. The resulting bed files need to be converted back to the original coordinates (and can be concatenated)

* split_bed_to_blocks.R - Convert coordinates in BED file to block coordinates and split
* fix_bed.py - Convert coordinates in BED file from block coordinates to sequence coordinates

