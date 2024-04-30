# Comparison of synteny block vs. whole genome alignment

"Whole genome" alignment in this case refers to running cactus with standard parameters on full genomes as opposed to our method of splitting the the assemblies into syntenic blocks and running cactus on each block seperately. 

To measure alignment quality we count the number of aligned bases in CDS regions of genes that have both ohnologs retained in both salmon and trout (i.e. 2:2 orthologs), that are located on syntenic chromosomes. A good genome alignment should be able to align all of these. Note that we do not expect 100% coverage as there will be cases of gain/loss in parts of the CDS.