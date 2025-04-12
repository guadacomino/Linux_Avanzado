# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

CONTAMINANTS_DATABASE_FILE = $1
DEST_DIRECTORY = $2

STAR \
    --runThreadN 4 \
    --runMode genomeGenerate \
    --genomeDir $DEST_DIRECTORY \
    --genomeFastaFiles $CONTAMINANT_DATABASE_FILE \
    --genomeSAindexNbases 9
