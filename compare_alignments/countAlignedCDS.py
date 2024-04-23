import pandas as pd
from Bio.AlignIO.MafIO import MafIndex
import argparse

def countAlignedCDS(chrom, refGenome, mafFile, mafindexFile, cdsCoordsFile, outFile):

  df = pd.read_csv(cdsCoordsFile ,delimiter="\t", dtype={"chrom": str})

  refChrom = f'{refGenome}.{chrom}'
  idx = MafIndex(mafindexFile, mafFile, refChrom)

  df_chrom = df[df['chrom'] == chrom]

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


  
  new_df = pd.concat(df_chrom.apply(get_cds_nAligned, axis=1).tolist(), ignore_index=True)

  new_df.to_csv(outFile, sep='\t', index=False, header=True)

def main():
    # Set up the argument parser
    parser = argparse.ArgumentParser(description='Count aligned coding sequences.')
    
    # Add arguments, all required and named
    parser.add_argument('--chrom', type=str, required=True, help='Chromosome name or number')
    parser.add_argument('--refGenome', type=str, required=True, help='Reference genome id')
    parser.add_argument('--mafFile', type=str, required=True, help='MAF file path')
    parser.add_argument('--mafindexFile', type=str, required=True, help='MAF index file path')
    parser.add_argument('--cdsCoordsFile', type=str, required=True, help='CDS coordinates .tsv file path')
    parser.add_argument('--outFile', type=str, required=True, help='Output file path')

    # Parse the arguments
    args = parser.parse_args()

    # Call the function with command line arguments
    countAlignedCDS(args.chrom, args.refGenome, args.mafFile, args.mafindexFile, args.cdsCoordsFile, args.outFile)

if __name__ == '__main__':
    main()
