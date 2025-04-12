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
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | cut -d "/" -f2 | sort | uniq)
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# Run cutadapt for all merged files
mkdir out/cutadapt
mkdir log/cutadapt
for file  in out/merged/*.fastq.gz 
do
    sampleid=$(basename $file .fastq.gz)
    
    cutadapt -m 18 \
        -a TGGAATTCTCGGGTGCCAAGG \
        --discard-untrimmed \
        -o out/cutadapt/${sampleid}_trimmed.fastq.gz \
        $file  > log/cutadapt/${sampleid}.log

	#Include cutadapt's results in pipeline.log
	echo "Trimming Results" >>log/pipeline.log
	echo "Processing sample $sampleid with cutadapt" >> log/pipeline.log
	grep "Reads with adapters:" log/cutadapt/${sampleid}.log >> log/pipeline.log
	grep "Total basepairs processed:" log/cutadapt/${sampleid}.log >> log/pipeline.log
	echo "==============================================================="


# Run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename $fname .fastq.gz)
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
         --outReadsUnmapped Fastx --readFilesIn $fname \
         --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid

    #Include STAR's results in pipeline.log
    grep "Uniquely mapped reads %" out/star/${sid}/Log.final.out >> log/pipeline.log
    grep "Mapped to multiple loci" out/star/${sid}/Log.final.out >> log/pipeline.log
    grep "Mapped to too many loci" out/star/${sid}/Log.final.out >> log/pipeline.log

done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
