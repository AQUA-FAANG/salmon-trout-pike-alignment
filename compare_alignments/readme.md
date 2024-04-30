# Comparison of synteny block vs. whole genome alignment

"Whole genome" alignment in this case refers to running cactus with standard parameters on full genomes as opposed to our method of splitting the the assemblies into syntenic blocks and running cactus on each block seperately. 

To measure alignment quality we count the number of aligned bases in CDS regions of genes that have both ohnologs retained in both salmon and trout (i.e. 2:2 orthologs), that are located on syntenic chromosomes. A good genome alignment should be able to align all of these. Note that we do not expect 100% coverage as there will be cases of gain/loss in parts of the CDS.

## input data

* SalmonTroutOrthologs.tsv - Table with orthologs (read directly from salmobase.org)
* Compara.106.protein_default.nhx.emf.gz - Used to convert geneID to protein IDs used in compara gene trees  (http://ftp.ensembl.org/pub/release-106/emf/ensembl-compara/homologies/Compara.106.protein_default.nhx.emf.gz)
* Salmo_salar.Ssal_v3.1.106.gff3.gz - Contains CDS coordinates (read directly from ensembl)
* maf_ref_Ssal_A/Ssal_XX_AB.maf - Synteny block genome alignments in in MAF format (https://salmobase.org/datafiles/datasets/Aqua-Faang/alignments/salmon-trout-pike/maf_ref_Ssal_A/)
* aqua-faang.hal - Whole genome alignment of aqua-faang assemblies (http://ftp.ensembl.org/pub/misc/aqua-faang/cactus/20210908/aqua-faang.hal)


## Workflow

1. GetCDSCoords.R - Extracts CDS coordinates of the 2:2 orthologs. (input data: , )
2. run_hal2maf_alt.job.sh - Extracts maf from hal for the whole genome alignment
3. run_purge_maf.job.sh / purgeSameChromAlignments.py - Remove duplications on same chromosome from alignments (as these messes up the counting)
4. countAlignedCDS.py - Extracts CDS alignments using Bio.AlignIO.MafIO.MafIndex.get_spliced() and counts bases aligned
5. run_countAligned_alt.job.sh - Do counts for the whole genome alignment
6. run_countAligned.job.sh - Do counts for the synteny block alignment
7. plotSummary.R - Plots a summary of the count

