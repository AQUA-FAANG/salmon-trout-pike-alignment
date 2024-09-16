#
# After merging the bigwig files all the 0's were removed
# This script will fill all gaps with 0's.
#

library(rtracklayer)
library(GenomicRanges)
library(IRanges)

# input_bigwig_file="/mnt/SCRATCH/lagr/halAlignmentDepth/Ssal_A_to_B/all.bw"
# output_bigwig_file="/mnt/SCRATCH/lagr/halAlignmentDepth/Ssal_A_to_B/all_fixed.bw"
input_bigwig_file="/mnt/SCRATCH/lagr/halAlignmentDepth/Ssal_A_Ancestors/all.bw"
output_bigwig_file="/mnt/SCRATCH/lagr/halAlignmentDepth/Ssal_A_Ancestors/all_fixed.bw"

cat("Import bigwig...")
bw_data <- import(input_bigwig_file)

cat("Get gaps")
gaps_data <- gaps(bw_data) 
gaps_data <-  gaps_data[strand(gaps_data)=="*"] # ignore strand

cat("Assign score 0 to gaps")
mcols(gaps_data)$score <- 0

cat("Combine original ranges with gaps")
combined_data <- c(bw_data, gaps_data)

cat("Sort combined data by sequence names and ranges")
combined_data <- sort(combined_data)

cat("Export to BigWig file...")
export.bw(combined_data, output_bigwig_file)
