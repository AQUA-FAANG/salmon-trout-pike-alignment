library(tidyverse)

SalmonTroutOrthologs <- read_tsv("https://salmobase.org/datafiles/datasets/Aqua-Faang/salmon-trout-orthologs/SalmonTroutOrthologs.tsv")

bind_rows(
  .id="alignment",
  synteny= bind_rows(lapply(dir("counts",full.names = T),read_tsv,show_col_types = F)),
  whole= bind_rows(lapply(dir("counts_alt",full.names = T),read_tsv,show_col_types = F)),
) -> tbl

tbl_failed <- tbl %>% filter( nAligned == -1)
tbl <- tbl %>% filter( nAligned != -1)

# There are some genes mapping to same chromosome (specifically 5 genes on Ssal_19) that causes
# some issues. Need to remove these problem entries. 

problem_entries <-
  tbl %>% 
  filter(alignment=="synteny") %>% 
  separate(spc.chrom, into=c("spc","chrom"),sep = "\\.",extra = "merge") %>% 
  filter( spc != "Eluc" ) %>% 
  separate(spc, into=c("spc","AB"),sep = "_") %>% 
  group_by(geneID,spc,chrom) %>% 
  filter( all(c("A","B") %in% AB)) %>% # both A and B copy on same chromosome
  ungroup() %>%
  filter( AB == "B") %>% # keep B so we can remove it
  mutate(spc.chrom=paste0(spc,"_",AB,".",chrom)) %>% 
  select(geneID,spc.chrom)


# note: There are some issues with using proxiSynteny to determine the chromosomes of
# the orthologs and ohnolog when the gene is in a border region between synteny blocks

tbl_wide <-
  tbl %>% 
  anti_join(problem_entries, by = join_by(geneID, spc.chrom)) %>% 
  mutate( refChr = sprintf("Ssa%02i", as.integer(chrom)) ) %>% 
  separate(spc.chrom, into=c("spc","chrom"),sep = "\\.",extra = "merge") %>% 
  filter( spc != "Eluc" ) %>% 
  filter( !grepl("[^0-9]",chrom) ) %>% # remove scaffolds
  mutate( spc = c(Omyk_A="Omy",Omyk_B="Omy",Ssal_A="Ssa",Ssal_B="Ssa",
                  salmo_salar_gca905237065v2="Ssa", oncorhynchus_mykiss_gca013265735v3="Omy")[spc]) %>% 
  left_join(select(SalmonTroutOrthologs,geneID,proxiSynteny), by = join_by(geneID)) %>% 
  mutate( proxiSynteny = strsplit(gsub("[)(]","",proxiSynteny),split=",")) %>% 
  mutate( spcChrom = sprintf("%s%02i",spc,as.integer(chrom)) ) %>% 
  rowwise() %>% 
  filter( spcChrom %in% proxiSynteny) %>% # keep only alignments on expected chromosome
  mutate( synIdx = match(spcChrom,proxiSynteny)) %>% 
  mutate( refIdx = match(refChr,proxiSynteny)) %>% 
  mutate( AB = ifelse(refIdx <= 2,c("A","A","B","B")[synIdx],c("B","B","A","A")[synIdx])) %>% 
  ungroup() %>% 
  mutate( spcAB = paste0(spc,AB)) %>%
  select(alignment,geneID,spcAB,nAligned) %>% 
  pivot_wider(names_from = spcAB, values_from = nAligned, values_fill = 0)


tbl_wide %>% 
  left_join(select(SalmonTroutOrthologs,geneID,chr,phylogeny), by = join_by(geneID)) %>% 
  group_by(alignment,phylogeny) %>% 
  summarise( totBases = sum(SsaA), 
             across(c(OmyA,SsaB,OmyB), ~ sum(.x)/totBases, .names="propBases_{.col}"),
             across(c(OmyA,SsaB,OmyB), ~ mean(.x/SsaA>0.5), .names="propGenes_{.col}")) %>% 
  ungroup() %>%
  pivot_longer(cols= starts_with("prop"),
               names_to = c("stat", "spcAB"),
               names_pattern = "prop(.*)_(.*)", values_to = "proportion") %>% 
  filter( stat == "Bases" ) %>% 
  ggplot( aes(x=spcAB,y=proportion,fill=alignment)) + 
  facet_grid( . ~ phylogeny) + 
  geom_col(position="dodge", color="black",width = 0.5) +
  scale_fill_manual(values = c("synteny"="white", "whole"="black")) +
  ylab("Proportion of bases\naligned with SsaA") + xlab("") +
  ggtitle("Alignment of CDS in 2:2 genes") +
  theme_bw()
