echo "############ Starting pipeline at $(date +'%H:%M:%S')... ##############"

#Download all the files specified in data/filenames
for url in $(cat data/urls)
do
    bash scripts/download.sh "$url" data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear"

# Index the contaminants file
bash scripts/index.sh res/contaminants_filtered.fasta res/contaminants_idx

# Merge the samples into a single file
echo "Merging samples with similar id ..."

for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | cut -d "/" -f2 | sort | uniq)
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done
echo

# Run cutadapt for all merged files
echo "Running cutadapt for all merged files ..."
echo "Trimming Results" >>log/pipeline.log

mkdir -p out/trimmed
mkdir -p log/cutadapt
for file  in out/merged/*.fastq.gz 
do
    sampleid=$(basename $file .fastq.gz)
    
    cutadapt -m 18 \
        -a TGGAATTCTCGGGTGCCAAGG \
        --discard-untrimmed \
        -o out/trimmed/${sampleid}.trimmed.fastq.gz \
        $file  > log/cutadapt/${sampleid}.log

	#Include cutadapt's results in pipeline.log
	echo >>log/pipeline.log
	echo "Processing sample $sampleid with cutadapt" >> log/pipeline.log
	grep "Reads with adapters:" log/cutadapt/${sampleid}.log >> log/pipeline.log
	grep "Total basepairs processed:" log/cutadapt/${sampleid}.log >> log/pipeline.log
	echo >>log/pipeline.log
	echo "===============================================================" >> log/pipeline.log
done
echo >>log/pipeline.log
echo

# Run STAR for all trimmed files
echo "Runing STAR for all trimmed files ..."
echo "STAR Results" >>log/pipeline.log
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename $fname .trimmed.fastq.gz)
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
         --outReadsUnmapped Fastx --readFilesIn $fname \
         --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid/

    #Include STAR's results in pipeline.log
    echo >>log/pipeline.log
    echo "Processing sample $sid with cutadapt" >> log/pipeline.log
    grep "Uniquely mapped reads %" out/star/${sid}/Log.final.out >> log/pipeline.log
    grep "% of reads mapped to multiple loci" out/star/${sid}/Log.final.out >> log/pipeline.log
    grep "% of reads mapped to too many loci" out/star/${sid}/Log.final.out >> log/pipeline.log
    echo "===============================================================" >> log/pipeline.log

done
echo >>log/pipeline.log
echo

