# Useful HAL tools

Cactus comes with a wide range of tools for processing, converting and analysing HAL files. This document contains notes on how to use some of the tools that I have found useful.



Note: Since I am running this inside a container and I need to bind the data directories I use the define the following prefix:

```
CACTUS="singularity exec --contain --bind data:/data --bind /mnt/SCRATCH/lagr/aqua-faang/cactus:/data_af --pwd / cactus_v2.7.1.sif"
```

## list of all files in /home/cactus/bin/hal*

hal2assemblyHub.py
hal2fasta
hal2maf
hal2mafMP.py
hal2paf
hal2vg
hal4dExtract - "Extract Fourfold-Degenerate codon positions from a BED file that contains exons"
halAddToBranch
halAlignedExtract
halAlignmentDepth
halAppendCactusSubtree
halAppendSubtree
halBranchMutations
halCoverage - Estimates coverage from given ref genome to all other. Also counts sites covered multiple times...
halExtract
halIndels
halLiftover
halLodExtract
halLodInterpolate.py
halMaskExtract
halMergeChroms - Merge multiple HAL files with same genomes
halPctId
halPhyloP
halPhyloPMP.py
halPhyloPTrain.py
halRandGen
halRemoveDupes
halRemoveGenome
halRemoveSubtree
halRenameGenomes
halRenameSequences
halReplaceGenome
halSetMetadata
halSingleCopyRegionsExtract
halSnps
halStats
halSummarizeMutations
halSynteny
halTestGen
halTreeNIBackground.py
halTreeNIConservation.py
halTreeNITurnover.py
halTreePhyloP.py
halUnclip
halUpdateBranchLengths
halValidate
halWiggleLiftover
halWriteNucleotides

## halStats

Read the tree, genome names and sequence names. Get some basic stats..

E.g. `data/blocks/ssa13/output.hal` contains genome `Ssal_A` with sequence `13:0-114417674`

## halAlignmentDepth

"Make alignment depth wiggle plot for a genome. By default, this is a count of the number of other unique genomes each base aligns to, including ancestral genomes."

The options --noAncestors --targetGenomes --countDupes gives you some control of what is included. Note that to be able to get duplicates that occured before the targets (e.g. Ssal and Omyk) you need to include an earlier ancestor (by using noAncestors this will not be counted).

$CACTUS halAlignmentDepth data/blocks/ssa13/output.hal Ssal_A --refSequence 13:0-114417674 --start 56512360 --length 20 --step 1 --noAncestors --targetGenomes Eluc,Ssal_B,Omyk_A,Omyk_B

$CACTUS halAlignmentDepth data_af/aqua-faang.hal salmo_salar_gca905237065v2 --start 56512360 --length 20 --step 1 --noAncestors --countDupes --refSequence 13

## hal2maf [Options] <halFile> <mafFile>

$CACTUS hal2maf data/blocks/ssa13/output.hal stdout --refGenome Ssal_A --refSequence 13:0-114417674 --start 56512360 --length 20 --noAncestors

s	Ssal_A.13:0-114417674	     56512360	20	+	114417674	TATGACTATTTGAAAGTTAA
s	Eluc.LG07:2813480-36200450	3281989	10	+	33386971	TTAAAT----------TTAA
s	Omyk_A.12:41260-58375820	  4719991	20	-	58334561	TATGACTATTTGAAAGTTAA
s	Omyk_B.10:6299987-42405570	5285031	16	+	36105584	TATAATTCTA----AGTTAA
s	Ssal_B.4:44501540-83086020	5473573	16	-	38584481	TATAATTATT----GTGGAA

       (Compare with output from halAlignmentDepth:   44444433331111334444)
       

$CACTUS hal2maf data/blocks/ssa19/output.hal stdout --refGenome Ssal_A --refSequence 19:0-88107222 \
 --start 5326600 --length 1000 --noAncestors --noDupes --targetSequ