#!/bin/bash

# This file is part of STRspy project.

# MIT License

# Copyright (c) 2021 unique379r

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# author: Rupesh Kesharwani <bioinrupesh2009 DOT au AT gmail DOT com>

SECONDS=0
#Inputs: command line arguments
input_reads_dir="$1" ## either bam or fastq directory
is_input_bam="$2" ## yes or no
readtype="$3"
motif_fasta_dir="$4" ## str_bed
motif_bed_dir="$5" ## str_fasta
genome_fa="$6" ## ref_fasta
region_bed="$7" ## combined str bed
filter_threshold="$8"
output_dir="$9" ## results dir
tools_config="${10}" ## tools config

print_USAGE()
{
echo -e "USAGE: bash ./STRspy_v1.0.sh <input_reads_dir(fastq/bam dir)> <is_input_bam(yes/no)> <ReadType(ont/pb)> <motif_fasta_dir> <motif_bed_dir> <genome_fa> <region_bed> <filter_threshold> <output_dir> <tools_config>\n"
echo "EXAMPLE (positional arguments = counts => 10):"
echo "#In case of bam input dir"
echo "bash ./STRspy_v1.0.sh example/test_dir yes pb example/str_fa example/str_bed NULL region_bed 0.4 output_dir tools_config.txt"
echo "#In case of fastq input dir"
echo "bash ./STRspy_v1.0.sh example/test_dir no ont str_fa str_bed ref_fasta/hg19.fa region_bed 0.4 output_dir tools_config.txt"
echo -e "\n"
}

# checking input arguments
if [[ $# -ne 10 ]]; then
	echo "#ERROR: Please privide all and correct inputs"
	echo -e "\n"
	print_USAGE
	exit;
fi

if [[ ! -d "$output_dir" ]]; then
	echo -e "\n#Output directory "$output_dir" does not exist !!\n"
	print_USAGE
	exit 1;
fi

if [[ "$readtype" == "ont" ]]; then
	echo -e "Read Type:" "$readtype"
elif [[ "$readtype" == "pb" ]]; then
	echo -e "Read Type:" "$readtype"
else
	echo -e "#Read Type can not be other than ont/pb"
	exit;
fi

((
if [[ ! -d "$input_reads_dir" ]]; then
    echo -e "\n#Input directory "$input_reads_dir" does not exist !!\n"
	echo -e "\n"
	print_USAGE
	exit 1;
elif [[ ! -d "$motif_fasta_dir" ]]; then
	echo -e "\n#Input directory "$motif_fasta_dir" does not exist !!\n"
	print_USAGE
	exit 1;
elif [[ ! -d "$motif_bed_dir" ]]; then
	echo -e "\n#Input directory "$motif_bed_dir" does not exist !!\n"
	print_USAGE
	exit 1;
elif [[ ! -f "$region_bed" ]]; then
	echo -e "\n#Input region_bed "$region_bed" does not exist !!\n"
	print_USAGE
	exit 1;
elif [[ ! -f "$tools_config" ]]; then
	echo -e "\n#Input tools_config "$tools_config" does not exist !!\n"
	print_USAGE
	exit 1;
elif [[ "$is_input_bam" != "yes" ]] && [[ "$is_input_bam" != "no" ]] ; then
	echo -e "\n#Input read type should only be: yes or no, analysis halted.. !!\n"
	echo -e "\n"
	print_USAGE
	exit 1;
else
	echo -e "========================================================"
	echo -e "Arguments are fine !! analysis proceeded.."
	now="$(date)"
	echo -e "Analysis date and time:" "$now"
	echo -e "========================================================"
	echo "Input read dir:" "$input_reads_dir"
	if [[ "$is_input_bam" == "yes" ]]; then
		read_type="bam"
		echo "Input type: bam"
	else
		read_type="fastq"
		 echo "Input type: fastq"
	fi 
	echo -e "Motif/STR fasta dir:" "$motif_fasta_dir"
	echo -e "Motif/STR bed dir:" "$motif_bed_dir"
	echo -e "region_bed:" "$region_bed"
	echo -e "Output dir:" "$output_dir"
fi

#### checking bam/fastq files existence
if [[ "$is_input_bam" == "yes" ]]; then
	bam=($input_reads_dir/*.bam)
	type="bam"
	if [[ ! -e "${bam[0]}" ]]; then
		echo -e "\n#ERROR: Inputs sample.bam reads are not found !!\n"
		exit 1;
	fi
fi

if [[ "$is_input_bam" == "no" ]]; then
	fastq=($input_reads_dir/*.fastq)
	type="fastq"
	if [[ ! -e "${fastq[0]}" ]]; then
		echo -e "\n#ERROR: Input fastq reads are not found !!\n"
		exit 1;
	fi
fi

### STR/Motif fasta
strfa=($motif_fasta_dir/*.fa)
if [[ ! -e "${strfa[0]}" ]]; then
	echo -e "\n#ERROR: Inputs STR/Motif fasta does not found !!\n"
	exit 1;
fi

### STR/Motif fasta
strbed=($motif_bed_dir/*.bed)
if [[ ! -e "${strbed[0]}" ]]; then
	echo -e "\n#ERROR: Inputs STR/Motif bed does not found !!\n"
	exit 1;
fi

### checking ref file in case of fast input
if [[ "$is_input_bam" == "no" ]] && [[ ! -f "$genome_fa" ]]; then
	echo -e "Error: Genome fasta is required in case of input fastq reads"
	exit 1;
fi

if [[ "$is_input_bam" == "no" ]] && [[ -f "$genome_fa" ]]; then
	genome="$genome_fa"
	echo -e "genome ref fasta:" "$genome"
	echo -e "========================================================"
fi

if [[ "$is_input_bam" == "yes" ]] && [[ ! -f "$genome_fa" ]]; then
	genome="NULL"
	echo -e "genome ref fasta:" "$genome"
	echo -e "========================================================"
fi

if [[ "$is_input_bam" == "yes" ]] && [[ -f "$genome_fa" ]]; then
	## ignore genome fasta in case of bam input reads
	genome="NULL"
	echo -e "genome ref fasta:" "$genome"
	echo -e "========================================================"
fi

#"==================================================================================================================================="
####################   Tools Path from tool config   ###################

BEDTOOLS=$(cat $tools_config | grep -w '^BEDTOOLS' | cut -d '=' -f2)
MINIMAP=$(cat $tools_config | grep -w '^MINIMAP' | cut -d '=' -f2)
SAMTOOLS=$(cat $tools_config | grep -w '^SAMTOOLS' | cut -d '=' -f2)
XATLAS=$(cat $tools_config | grep -w '^XATLAS' | cut -d '=' -f2)
PARALLEL=$(cat $tools_config | grep -w '^PARALLEL' | cut -d '=' -f2)

######Set of tool user path######
bedtools=$BEDTOOLS
minimap=$MINIMAP
samtools=$SAMTOOLS
xatlas=$XATLAS
parallel=$PARALLEL

#"==================================================================================================================================="
mkdir -p $output_dir/{IntersectedRegions,IntersectMappedReads,Countings,SNVcalls}
#"==================================================================================================================================="

## general function to get total, mapped and unmapped reads and their percentage from a bam
get_cov() {
	## bam input
	arg1=$1
	## output
	arg2=$2
	#region_bed 
	arg3=$3
	for bamfile in $arg1/*.bam; do
		bamfile_name="${bamfile##*/}"
		## get total, mapped and unmapped reads from bam and their percentage
		$samtools flagstat $bamfile | sed -n '1p;5p' | awk -F' ' '{print $1}' | \
		xargs | awk ' {print $1"\t"$2,"("$2/$1*100"%)""\t"$1-$2,"("($1-$2)/$1*100"%)"}' > \
		$arg2/"$bamfile_name"_MappingStats.txt
		# header
		sed -i '1iTotalReads\tIntersectMappedReads(Ratio)\tUnmapedReads(Ration)' $arg2/"$bamfile_name"_MappingStats.txt
		## get overlap regions from mapped reads
		region_cov=$("$samtools" view -c -F 4 -L $arg3 $bamfile)
		bam_cov=$("$samtools" view -c -F 4 $bamfile)
		paste <(echo $bam_cov) <(echo $region_cov) | awk '{print $1"\t"$2"\t"$2/$1*100"(%)"}' > $arg2/"$bamfile_name".regions.OverlapStats.txt
		## header
		sed -i '1iGenomicMapping\tRegionsOverllaped\tRatio' $arg2/"$bamfile_name".regions.OverlapStats.txt
	done
}


#"=================================================="
## step1 : determine the read type and map if needed.
#"=================================================="
echo -e "\n"
if [[ $read_type == "fastq" ]]; then
	echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	echo -e "#Mapping given fastq to human reference genome..."
	mkdir -p $output_dir/GenomeMapping
	for fastqfile in "${fastq[@]}"; do
		fastq_name="${fastqfile##*/}"
		## map to human genome
		if [[ "$readtype" == "ont" ]]; then
			$minimap --MD -L -t 1 -ax map-ont $genome "${fastqfile}" -o $output_dir/GenomeMapping/$fastq_name".minimap.sam"
		elif [[ "$readtype" == "pb" ]]; then
			$minimap --MD -L -t 1 -ax map-pb $genome "${fastqfile}" -o $output_dir/GenomeMapping/$fastq_name".minimap.sam"
		else
			echo -e "#Provided Read type is not known"
			exit 1;
		fi
		## sam to bam
		$samtools view -S -b $output_dir/GenomeMapping/$fastq_name".minimap.sam" -o $output_dir/GenomeMapping/$fastq_name".minimap.bam"
		## bam to sorted bam
		$samtools sort -o $output_dir/GenomeMapping/$fastq_name".minimap.sorted.bam" $output_dir/GenomeMapping/$fastq_name".minimap.bam"
		$samtools index $output_dir/GenomeMapping/$fastq_name".minimap.sorted.bam"
		## delte sam and unsorted bam
		rm -rf $output_dir/GenomeMapping/$fastq_name".minimap.sam" $output_dir/GenomeMapping/$fastq_name".minimap.bam"
	done
echo -e "#Done"
fi

#### checking bam files existence
if [[ "$is_input_bam" == "no" ]]; then
	type="fastq"
	bam=($output_dir/GenomeMapping/*.sorted.bam)
	mkdir -p $output_dir/GenomicMappingStats
	if [[ -e "${bam[0]}" ]]; then
		echo -e "#Summerizing the mapped and unmapped reads and their percentage"
		get_cov $output_dir/GenomeMapping $output_dir/GenomicMappingStats $region_bed
		echo -e "#Done"
	else
		echo -e "\n#ERROR: Minimap bams from fastq inputs are not found !!\n"
		exit 1;
	fi
fi

## get cov info in case of bam provided
#### checking bam files existence
if [[ "$is_input_bam" == "yes" ]]; then
	bam=($input_reads_dir/*.bam)
	type="bam"
	mkdir -p $output_dir/GenomicMappingStats
	if [[ -e "${bam[0]}" ]]; then
		echo -e "#Summerizing the mapped and unmapped reads and their percentage"
		get_cov $input_reads_dir $output_dir/GenomicMappingStats $region_bed
		echo -e "#Done"
	else
		echo -e "\n#ERROR: Provided Genomic bams are not found !!\n"
		exit 1;
	fi
fi

# #"==================================================================="
# ## step2 : mapping to STR.fa + conting + normalization + SNV calling
# #"==================================================================="

if [[ $read_type == "$type" ]]; then
	echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	echo -e "#Spying on STR for a given samples(skipped mapping since bam was provided)...."
	## create a inner and outer loop
	for bamfile in "${bam[@]}"; do
		bam_name="${bamfile##*/}"
		for bedfile in "${strbed[@]}"; do
			bed_name="${bedfile##*/}"
			bed_fname=$(basename $bed_name .bed)
			echo -e "Working for:" $bam_name $bed_name
			##Intersect regions from bed vs bam
			echo -e "#Started Intersecting regions from bed vs bam and creating fastq reads..."
			$bedtools intersect -a "${bamfile}" -b "${bedfile}" > $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam
			## bam to fastq
			$bedtools bamtofastq -i $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam -fq $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam.fq
			rm -rf $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam
			echo -e "#Done.\n"
			echo -e "#Mapping fastq to motif fasta...\n"
			if [[ "$readtype" == "ont" ]]; then
				$minimap --MD -L -ax map-ont $motif_fasta_dir/"$bed_fname".fa $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam.fq -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam
			elif [[ "$readtype" == "pb" ]]; then
				$minimap --MD -L -ax map-pb $motif_fasta_dir/"$bed_fname".fa $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam.fq -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam
			else
				echo -e "#Provided Read type is not known"
				exit 1;
			fi
			echo -e "#Done.\n"
			echo -e "#sam to bam + sort + index..."
			$samtools view -S -b $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.bam
			$samtools sort -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.bam
			$samtools index $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam
			rm -rf $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.bam
			echo -e "#Done.\n"
			## SNV calling by xatlas
			echo -e "#SNV calling by xatlas...\n"
			$xatlas \
			-r $motif_fasta_dir/"$bed_fname".fa \
			-i $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam \
			-s $output_dir/SNVcalls/"$bed_fname"_"$bam_name" \
			-p $output_dir/SNVcalls/"$bed_fname"_"$bam_name"
			echo -e "#Done.\n"
			echo -e "#Counting Alleles..."
			$samtools view -q 1 -F 4 $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam | cut -f 3 | sort | uniq -c | sed -e 's/^ *//;s/ /\t/' | \
			grep -v '*' | sort -nr -k1,1 > $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt
			echo -e "#Normalize with maximum value of Allele counts.."
			awk 'FNR==NR{max=($1+0>max)?$1:max;next} {print $2"\t"$1"\t"$1/max}' $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt \
			$output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt > temp && mv temp $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt 
			## header
			sed -i '1iSTR\tRawCounts\tNormalizedCounts' $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt
			## get top two by getting top two
			#sed '1d' $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt | head -n 2 | tr '_' ' ' | sed 's/\]/] /g' | awk '{print $1"\t"$(NF-2)"\t"$NF}' > $output_dir/Countings/"$bed_fname"_"$bam_name"_Toptwo.txt
			echo -e "#get top two Alleles by filtering norm value <=" $filter_threshold
			sed '1d' $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt | awk  -v f="$filter_threshold" '$3>=f' | tr '_' ' ' | sed 's/\]/] /g' | awk '{print $1"\t"$(NF-2)"\t"$NF}' | sort -r -k3,3 | head -n 2 > $output_dir/Countings/"$bed_fname"_"$bam_name"_Toptwo.txt
			## header
			sed -i '1iLocus\tAllele\tNormalizedCounts' $output_dir/Countings/"$bed_fname"_"$bam_name"_Toptwo.txt
			echo -e "#Done.\n"
		done
	done
fi
echo -e "All Done.\n"

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo -e "\n#The log file also has created in your working directory\n"

) 2>&1) | tee -a "$9"/STRspyLogNoParallel.log

