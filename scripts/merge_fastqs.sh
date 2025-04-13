# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

SAMPLES_DIRECTORY=$1
DEST_DIRECTORY=$2
id_SAMPLES=$3

mkdir -p  out/merged
cat $SAMPLES_DIRECTORY/${id_SAMPLES}-*.fastq.gz > $DEST_DIRECTORY/${id_SAMPLES}.fastq.gz
