# paf file format columns:
#
# 1	qname	string	Query sequence name
# 2	qlen	int	Query sequence length
# 3	qstart	int	Query start coordinate (0-based)
# 4	qend	int	Query end coordinate (0-based)
# 5	strand	char	‘+’ if query/target on the same strand; ‘-’ if opposite
# 6	tname	string	Target sequence name
# 7	tlen	int	Target sequence length
# 8	tstart	int	Target start coordinate on the original strand
# 9	tend	int	Target end coordinate on the original strand
# 10	nmatch	int	Number of matching bases in the mapping
# 11	alen	int	Number of bases, including gaps, in the mapping
# 12	mapq	int	Mapping quality (0-255, with 255 if missing)


args = commandArgs(trailingOnly=TRUE)
if( length(args) != 2 || !grepl("\\.paf",args[1]))
  stop("Usage: Rscript fix_paf.R <input.paf> <output.paf>")

suppressPackageStartupMessages(library(tidyverse))

paf <- 
  readr::read_tsv(args[1],col_names = F) %>% 
  rename(qname=X1,qstart=X3, qend=X4, tname=X6, tstart=X8,tend=X9)

paf$qname[1:5]
paf %>% 
  mutate(qofs = as.integer(sub("[0-9]+:([0-9]+)-[0-9]+","\\1",qname))) %>% 
  mutate( qstart=qstart+qofs, qend=qend+qofs, qname=sub("([0-9]+):[0-9]+-[0-9]+","\\1",qname)) %>% 
  select(-qofs) %>% 
  mutate( tofs = as.integer(sub("[0-9]+:([0-9]+)-[0-9]+","\\1",tname))) %>% 
  mutate( tstart=tstart+tofs, tend=tend+tofs, tname=sub("([0-9]+):[0-9]+-[0-9]+","\\1",tname)) %>% 
  select(-tofs) %>% 
  write_tsv(args[2],col_names = F)
  