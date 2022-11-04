SHELL := /bin/bash

REFERENCE="input/reference.fna"
RES="results/final_result.txt"

SAMTOOLS="samtools-1.16.1/samtools"
MINIMAP="minimap2/minimap2"
FREEBAYES="freebayes/freebayes-1.3.6-linux-amd64-static"

main: prepare final_result.txt

# get report from FastQC
	fastqc/fastqc "input/$(READS).fastq"
	mv "input/$(READS)_fastqc.html" results/
	mv "input/$(READS)_fastqc.zip" results/

# get final results
	mv final_result.txt results/

# round final result using bc
	@echo $$(cat $(RES)) / 1 | bc
# if final result >90 then process it using freebayes
	@export res=$$(echo "$$(cat $(RES)) / 1" | bc) &&                                     \
	if (( $$res > 90 ));                                                                  \
		then echo "OK";                                                                   \
		$(SAMTOOLS) sort output/alignment.bam > output/alignment.sorted.bam;              \
		echo "Freebayes works...";														  \
		$(FREEBAYES) -f $(REFERENCE) -b output/alignment.sorted.bam > results/result.vcf; \
		else echo "NOT OK";                                                               \
	fi;
	@echo "!!!Finished!!!"

prepare:
	-mkdir results
	-mkdir output

final_result.txt: output/samtools_result.txt
	./parse.sh output/samtools_result.txt

output/samtools_result.txt: output/alignment.bam
	$(SAMTOOLS) flagstat output/alignment.bam > output/samtools_result.txt

output/alignment.bam: output/alignment.sam
	$(SAMTOOLS) view -bS output/alignment.sam > output/alignment.bam

output/alignment.sam: output/reference.mmi
	$(MINIMAP) -a output/reference.mmi input/$(READS).fastq > output/alignment.sam

output/reference.mmi:
	$(MINIMAP) -d output/reference.mmi $(REFERENCE)

clean:
	-rm -r output results final_result.txt log.txt