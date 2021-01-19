# strspy
STRspy: A pipeline to detect regions of short tandem repeats in given sample.

Overview

DNA evidence has long been considered the gold standard for human identification in forensic investigations. Most often, DNA typing exploits the high variability of short tandem repeat (STR) sequences to differentiate between individuals at the genetic level. Comparison of STR profiles can be used for human identification in a wide range of forensic cases including homicides, sexual assaults, missing persons, and mass disaster victims. The number of contiguous repeat units present at a given microsatellite locus varies significantly among individuals, and thus make them useful for human identification purposes. Here, we are presents a complete pipeline i.e STRspy to identify STRs in a long read samples i.e. Oxford nanopore sequencing reads.

Key Features

1. Input either fastq (raw reads) or bam (pre-aligned reads)
2. Reports raw allelic counts along with Normalized counts
3. Find top two significant Alleles (filtering set to 0.6)
4. Detects Small variants such as SNP and Indels
5. Plots and reports mapping summary and region of overlaps 


Installation

STSspy requires following third party tools that has to be installed prior to run the program.

samtools
bedtools
minimap2
ngmlr
xatlas

Note: Installation script will be avaible soon. 

Quickstart

bash STRspy -h

USAGE: bash ./STRspy.sh <input_reads_dir(fastq/bam dir)> <is_input_bam(yes/no)> <motif_fasta_dir> <motif_bed_dir> <genome_fa> <output_dir>

EXAMPLE:

echo "#In case of bam input dir"
echo "bash ./STRspy.sh example/test_dir yes example/str_fa example/str_bed NULL output_dir"

echo "#In case of fastq input dir"
echo "bash ./STRspy.sh example/test_dir no example/str_fa example/str_bed example/ref_genome/hg19.fa output_dir"

Positional arguments

fastq/bams : A dir must have either fastq (Oxford nanopore reads) or bam (pre-aligned reads)

is_input_bam: User must say if given inputs are bam or fastq

motif_fasta_dir: A dir contains Fasta files for each STR region of interest (assimung it has flanking regions of 500bp)

motif_bed_dir: A dir contains Bed files for each STR region of interest

genome fasta : Genome fasta (hg10/hg38) must provide in case of fastq input. 

output_dir : A empty diectory to write the results


Test Run

#bam input
bash STRspy.sh example/test_dir yes example/str_bed example/str_fa NULL out_dir

#bam input
bash STRspy.sh example/test_dir yes example/str_bed example/str_fa example/ref_genome/chr22.fa out_dir

