

#def purgeSameChromAlifnments(inFile, outFile):

inFile = "compare_alignments/Ssal25.maf"
outFile = "compare_alignments/Ssal25_filtered.maf"

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