SAMTOOLS="samtools-1.16.1/samtools"
MINIMAP="minimap2/minimap2"

all: final_result.txt
# get report from FastQC
	fastqc/fastqc "input/$(READS).fastq"
	mv "input/$(READS)_fastqc.html" results/
	mv "input/$(READS)_fastqc.zip" results/

# get final results
	mv final_result.txt results/

final_result.txt: output/samtools_result.txt
	./parse.sh output/samtools_result.txt

output/samtools_result.txt: output/alignment.bam
	$(SAMTOOLS) flagstat output/alignment.bam > output/samtools_result.txt

output/alignment.bam: output/alignment.sam
	$(SAMTOOLS) view -bS output/alignment.sam > output/alignment.bam

output/alignment.sam: output/reference.mmi
	$(MINIMAP) -a output/reference.mmi input/$(READS).fastq > output/alignment.sam

output/reference.mmi:
	$(MINIMAP) -d output/reference.mmi input/reference.fna
