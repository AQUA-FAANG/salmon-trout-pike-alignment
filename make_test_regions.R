library(tidyverse)

# make a test table
SalmonTroutOrthologs_URL = "https://gitlab.com/sandve-lab/defining_duplicates/-/raw/master/output/SalmonTroutOrthologs.tsv"
SalmonTroutOrthologs <- read_tsv(SalmonTroutOrthologs_URL)

# get the coordinates of the prkag2b orthologs
SalmonTroutOrthologs %>% 
  group_by(subOG) %>% 
  filter("ENSSSAG00000077147" %in% geneID) %>% 
  ungroup() %>% 
  # assign A and B sub_genomes
  mutate( genome = c(Omy08="Omyk_B",Ssa14="Ssal_B",Omy28="Omyk_A",Ssa03="Ssal_A")) %>% 
  mutate( chr = sub("^...0?","",chr)) %>% 
  select( genome,chr,start,end) %>% 
  # amnually add the pike ortholog:
  bind_rows(tibble(genome="Eluc", chr="LG21", start=8559700, end=8631727)) %>% 
  pivot_wider(names_from = genome,values_from=c(chr,start,end), names_glue = "{genome}-{.value}") %>% 
  write_tsv("test_regions.tsv")



