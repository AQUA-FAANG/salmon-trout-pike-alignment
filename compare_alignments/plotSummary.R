
SalmonTroutOrthologs <- read_tsv("https://salmobase.org/datafiles/datasets/Aqua-Faang/salmon-trout-orthologs/SalmonTroutOrthologs.tsv")

SalmonTroutOrthologs %>% filter(nSsal==2,nOmyk==2,!is.na(synteny), spc=="Ssal") %>% with(table(proxiSynteny))

bind_rows(
  .id="alignment",
  synteny=read_tsv("compare_alignments/alignCountSsal25.tsv",show_col_types = F),
  whole=read_tsv("compare_alignments/alignCountSsal25_alt.tsv",show_col_types = F)
) -> tbl

refChr<-"Ssa25"

tbl %>% 
  separate(spc.chrom, into=c("spc","chrom"),sep = "\\.",extra = "merge") %>% 
  filter( !grepl("[^0-9]",chrom) ) %>% # remove scaffolds
  filter( spc != "Eluc" ) %>% 
  mutate( spc = c(Omyk_A="Omy",Omyk_B="Omy",Ssal_A="Ssa",Ssal_B="Ssa",
                  salmo_salar_gca905237065v2="Ssa", oncorhynchus_mykiss_gca013265735v3="Omy")[spc]) %>% 
  left_join(select(SalmonTroutOrthologs,geneID,proxiSynteny)) %>% 
  mutate( proxiSynteny = strsplit(gsub("[)(]","",proxiSynteny),split=",")) %>% 
  mutate(spcChrom = sprintf("%s%02i",spc,as.integer(chrom)) ) %>% 
  rowwise() %>% 
  filter( spcChrom %in% proxiSynteny) %>% # keep only alignments on expected chromosome
  mutate( synIdx = match(spcChrom,proxiSynteny)) %>% 
  mutate( refIdx = match(refChr,proxiSynteny)) %>% 
  mutate( AB = ifelse(refIdx <= 2,c("A","A","B","B")[synIdx],c("B","B","A","A")[synIdx])) %>% 
  ungroup() %>% 
  mutate( spcAB = paste0(spc,AB)) %>%
  select(alignment,geneID,spcAB,nAligned) %>% 
  pivot_wider(names_from = spcAB, values_from = nAligned, values_fill = 0) %>% 
  arrange(geneID) %>% 
  group_by(alignment) %>% 
  summarise( totBases = sum(SsaA), 
             across(c(OmyA,SsaB,OmyB), ~ sum(.x)/totBases, .names="propBases_{.col}"),
             across(c(OmyA,SsaB,OmyB), ~ mean(.x>0), .names="propGenes_{.col}"))
  
