# get trancript coordinates of 2:2 genes

library(tidyverse)

# get 2:2 genes
SalmonTroutOrthologs <- read_tsv("https://salmobase.org/datafiles/datasets/Aqua-Faang/salmon-trout-orthologs/SalmonTroutOrthologs.tsv")
Ssal22Genes <- filter(SalmonTroutOrthologs, nSsal==2,nOmyk==2,!is.na(synteny), spc=="Ssal")$geneID

# get protein ID corresponding to the gene from the alignment

# unzip and filter salmon genes
con = pipe("gunzip -c ../salmon-trout-orthologs/data/download/Compara.106.protein_default.nhx.emf.gz | grep '^SEQ' | grep ENSSSA", open="rb")
gene2prot <- read_table(con,col_types = "--c---cc-",col_names=c("proteinID","strand","geneID"))
close(con)


#library(rtracklayer)
cds_data <- rtracklayer::import.gff3("http://ftp.ensembl.org/pub/release-106/gff3/salmo_salar/Salmo_salar.Ssal_v3.1.106.gff3.gz", 
                                     feature.type = "CDS")

cdsCoords <- 
  data.frame(
    chrom = seqnames(cds_data),
    start = start(cds_data),
    end = end(cds_data),
    proteinID = mcols(cds_data)$protein_id
  ) %>% 
  inner_join(filter(gene2prot, geneID %in% Ssal22Genes),by="proteinID") %>%
  group_by(chrom, proteinID, geneID, strand) %>% 
  summarise(start=paste(start,collapse = ","),end=paste(end,collapse = ","))

write_tsv(cdsCoords,"compare_alignments/cdsCoords_Ssal22.tsv")
