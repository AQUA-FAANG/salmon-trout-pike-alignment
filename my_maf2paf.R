library(tidyverse)

readMAF <- function(mafFile){
  x <- readLines(mafFile)
  
  aLines <- grepl("^a",x)
  sLines <- grepl("^s",x)
  
  tibble(idx=cumsum(aLines),txt=x) %>% 
    filter(sLines) %>%
    # separate(txt, into=c("s","geneID","pos","len","strand","seqLen","seq"),sep = "[ \t]+") %>% 
    separate(txt, into=c("s","src","start","size","strand","srcSize","text"),sep = "[ \t]+") %>% 
    select(-s) %>% 
    # mutate(geneID = sub("\\..*$","",geneID)) %>% 
    # mutate_at(vars(pos,len,seqLen),as.numeric) 
    mutate_at(vars(start,size,srcSize),as.integer) 
}

makeCigar <- function(query_seq,target_seq){
  # !gapT !gapQ
  #  0(-)  0(-)  = 0 (ignore)
  #  0(-)  1(N)  = 1 (I)nsertion
  #  1(N)  0(-)  = 2 (D)eletion
  #  0(N)  0(N)  = 3 (M)atch
  #
  mapply(seqQ = strsplit(toupper(query_seq),split=""),
         seqT = strsplit(toupper(target_seq),split=""), 
         FUN = function(seqQ,seqT){
    gapQ <- seqQ=="-"
    gapT <- seqT=="-"
    cigar <- c('I','D','M')[(!gapQ)+2*(!gapT)] # use the hack that 0 (both are gap) in index gives nothing
    change <- cigar!=lead(cigar,default = "!")
    paste0(seq_along(cigar)[change] - lag(seq_along(cigar)[change],default = 0),cigar[change],collapse = "")
  })
}

maf2paf <- function(maf){
  maf %>% 
    separate(src, into=c("spc","genome","chr")) %>% 
    group_by(idx) %>% 
    filter( n() == 2, all(c("A","B") %in% genome)) %>% 
    mutate(end=start+size) %>%
    select(-spc,text,-size,-srcSize) %>% 
    pivot_wider(names_from=genome, values_from=c("chr","start","end","strand","text")) %>% 
    mutate(cigar = paste0("cg:Z:",makeCigar(text_A,text_B))) %>% select(-text_A,-text_B) %>% 
    ungroup() %>% 
    mutate(dummy="") %>% 
    mutate(rel_strand = ifelse(strand_A==strand_B,"+","-")) %>% 
    select(chr_A, len_A=dummy, start_A, end_A,rel_strand,chr_B, len_B=dummy, start_B, end_B,
           nmatch=dummy,block_len=dummy,mapq=dummy,cigar)
}



# Example paf CIGAR: "cg:Z:9M362I23M13I1M"

check_slurm_job_status <- function(job_id) {
  system(paste("sacct -j", job_id, "-o State --noheader -P"), intern = TRUE)[1]
}

regionString <- "3:28,700,012..28,770,877"
prefix <- "Ssa03_prkag2b"
# write bed file for hal2maf
write(gsub(":|\\.\\.","\t",gsub(",","",regionString)),file = paste0(prefix,".bed"))

str_glue("sbatch run_hal2maf.job.sh ",
         "--maxBlockLen 1000000 --noAncestors --noDupes ",
         "--refGenome Ssal_A --refTargets {prefix}.bed ",
         "ssa03_trial.hal {prefix}.maf") %>% 
  system()


# # This did not work:
# str_glue("sbatch run_in_container.job.sh ",
#          "cactus-hal2maf ",
#          "--refGenome Ssal_A --chunkSize 1000000 --noAncestors ",
#          "--dupeMode ancestral "
#          "./js ",
#          "data/blocks_test/Ssal14_27174335-27222943/output.hal ",
#          "data/blocks_test/Ssal14_27174335-27222943/output.maf") %>% 
#   system()

prefix <- "data/blocks/ssa03/output"
str_glue("sbatch run_in_container.job.sh hal2maf ",
         "--maxBlockLen 1000000 --noAncestors --noDupes ",
         "--refGenome Ssal_A ",
         "{prefix}.hal {prefix}.maf") %>% 
  system()



system("sacct -j 11937651")

ssa03_Ssal_vs_Omyk <- read_tsv("data/blocks/ssa03/ssa03_Ssal_vs_Omyk.paf",col_names = F)

table(ssa03_Ssal_vs_Omyk$X1)
ssa03_Ssal_vs_Omyk %>% 
  filter( ((X1 == 3) & (X4 > 28700012) & (X3 < 28770877)) |
            ((X1 == 14) & (X4 > 27174335) & (X3 < 27222943))) %>% 
  arrange(X1,X3) -> tmp

write_tsv(tmp, "ssa03_fixed_prkag2bSsal_vs_Omyk.paf",col_names = F)

# 3:28700012-28770877
# 14:27174335-27222943

# remove the _A and _B suffix in the maf file
system(str_glue("sed -i 's/_[AB]\\././g' {prefix}.maf"))

maf <- readMAF(paste0(prefix,".maf"))
paf <- maf2paf(maf) 
write_tsv(paf, file = paste0(prefix,"_withCIGAR.paf"),col_names = F)

paf %>%
  filter(chr_B=="14") %>% 
  ggplot()+geom_segment(aes(x=start_A,xend=end_A,y=start_B,yend=end_B))

# 1 	string 	Query sequence name
# 2 	int 	Query sequence length
# 3 	int 	Query start (0-based; BED-like; closed)
# 4 	int 	Query end (0-based; BED-like; open)
# 5 	char 	Relative strand: "+" or "-"
# 6 	string 	Target sequence name
# 7 	int 	Target sequence length
# 8 	int 	Target start on original strand (0-based)
# 9 	int 	Target end on original strand (0-based)
# 10 	int 	Number of residue matches
# 11 	int 	Alignment block length
# 12 	int 	Mapping quality (0-255; 255 for missing)
