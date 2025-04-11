# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output

URL = $1
DEST_DIRECTORY = $2
UNCOMPRESS = $3
SPECIFIED_WORD = $4

if [ "$#" -eq 3 ]
then
	echo "Downloading Data files..."

wget -O $DEST_DIRECTORY/basename($URL) $URL

if [$UNCOMPRESS == "Yes"]
then
	echo "Uncompressing ..."
	gunzip $DEST_DIRECTORY/basename($URL)

if [$SPECIFIED_WORD == small nuclear]
	echo "Remove all sequences corresponding to small nuclear RNAs..."

