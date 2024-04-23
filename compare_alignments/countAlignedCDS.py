import pandas as pd
from Bio.AlignIO.MafIO import MafIndex
#from MyMafIO import MafIndex

df = pd.read_csv("compare_alignments/cdsCoords_Ssal22.tsv",delimiter="\t")

# per chrom
idx = MafIndex("compare_alignments/Ssal25_filtered.mafindex", "compare_alignments/Ssal25_filtered.maf", "salmo_salar_gca905237065v2.25")
# idx = MafIO.MafIndex("Ssal_A_25.mafindex", "/Users/larsgr/Downloads/ssa25_AB.maf", "Ssal_A.25")

df_chrom = df[df['chrom'] == 25]

def get_cds_nAligned(row):
  starts = [int(x)-1 for x in row.start.split(',')]
  ends = [int(x) for x in row.end.split(',')]
  multiple_alignment = idx.get_spliced(starts, ends, strand=row.strand)
  n = len(multiple_alignment)
  return pd.DataFrame({
          'chrom': [row['chrom']] * n,
          'geneID': [row['geneID']] * n,
          'spc.chrom': [seqrec.name for seqrec in multiple_alignment],
          'nAligned': [len(str(seqrec.seq).replace("-", "")) for seqrec in multiple_alignment]
      })


# get_cds_nAligned(df[df['geneID']=="ENSSSAG00000009314"].iloc[0])


new_df = pd.concat(df_chrom.apply(get_cds_nAligned, axis=1).tolist(), ignore_index=True)

new_df.to_csv('compare_alignments/alignCountSsal25_alt.tsv', sep='\t', index=False, header=True)

