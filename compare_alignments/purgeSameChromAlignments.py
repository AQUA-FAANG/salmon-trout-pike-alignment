
import argparse

def purgeSameChromAlignments(inFile, outFile):

  file_in = open(inFile,"r")
  file_out = open(outFile,"w")

  lineNr = 0
  skippedLines = 0

  line = file_in.readline()
  for line in file_in.readlines():
    lineNr = lineNr + 1
    if line.startswith("a"):
      seen_ids = []
    if line.startswith("s"):
      id = line.split("\t")[1]
      if id in seen_ids:
        skippedLines = skippedLines + 1
        continue
      seen_ids.append(id)
    bytes_written = file_out.write(line)

  file_in.close()
  file_out.close()

  print(f'Lines read:{lineNr}, lines skipped: {skippedLines}')

def main():
    # Set up the argument parser
    parser = argparse.ArgumentParser(description='Remove multiple alignments to same chromosome.')
    
    # Add arguments
    parser.add_argument('inFile', type=str, help='Input .maf file path')
    parser.add_argument('outFile', type=str, help='Output .maf file path')
    
    # Parse the arguments
    args = parser.parse_args()
    
    # Call the function with command line arguments
    purgeSameChromAlignments(args.inFile, args.outFile)

if __name__ == '__main__':
    main()
