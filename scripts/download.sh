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

URL=$1
DEST_DIRECTORY=$2
UNCOMPRESS=$3
SPECIFIED_WORD=$4

if [ "$#" -eq 4 ]
then
        echo "Downloading contaminants file..."
else
        echo "Downloading Data files..."
fi
echo

wget -O $DEST_DIRECTORY/$(basename $URL) $URL
echo

if [ $UNCOMPRESS == "yes" ]
then
        echo "Uncompressing contaminants file ..."
        gunzip $DEST_DIRECTORY/$(basename $URL)
fi
echo

if [ "$SPECIFIED_WORD" == "small nuclear" ]
then
        echo "Remove all sequences corresponding to small nuclear RNAs..."

	awk -v pat="$SPECIFIED_WORD" '
        BEGIN { delete_sequence = 0 }

        # Si es una cabecera
        /^>/ {

                if (index($0, pat)) {

                        delete_sequence = 1  # Contiene el patrón → marcar para eliminar

                } else {

                        delete_sequence = 0  # No contiene el patrón → conservar
                        print $0
                }

                next #Pasamos a la siguiente linea

        }


        # Si no hemos marcado la secuencia para eliminar, la imprimimos

        {
                if(delete_sequence == 0) {

                         print $0

                }
        }
        ' $DEST_DIRECTORY/$(basename $URL .gz) > $DEST_DIRECTORY/$(basename $URL .fasta.gz)_filtered.fasta 
fi
