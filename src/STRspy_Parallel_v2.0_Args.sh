#!/bin/bash


# This file is part of STRspy2.0 project.

# MIT License

# Copyright (c) 2026 unique379r

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

echo -e "\n"

cat <<'Logo'

                                                      _____ _______ _____                  
                                                      / ____|__   __|  __ \                 
                                                     | (___    | |  | |__) |___ _ __  _   _ 
                                                      \___ \   | |  |  _  // __| '_ \| | | |
                                                      ____) |  | |  | | \ \\__ \ |_) | |_| |
                                                     |_____/   |_|  |_|  \_\___/ .__/ \__, |
                                                                               | |     __/ |
                                                                               |_|    |___/    
                                                ===============================================      
            _              _    __              __                         _         _____ _______ _____                     __ _ _ _             
    /\     | |            | |  / _|            / _|                       (_)       / ____|__   __|  __ \                   / _(_) (_)            
   /  \    | |_ ___   ___ | | | |_ ___  _ __  | |_ ___  _ __ ___ _ __  ___ _  ___  | (___    | |  | |__) |  _ __  _ __ ___ | |_ _| |_ _ __   __ _ 
  / /\ \   | __/ _ \ / _ \| | |  _/ _ \| '__| |  _/ _ \| '__/ _ \ '_ \/ __| |/ __|  \___ \   | |  |  _  /  | '_ \| '__/ _ \|  _| | | | '_ \ / _` |
 / ____ \  | || (_) | (_) | | | || (_) | |    | || (_) | | |  __/ | | \__ \ | (__   ____) |  | |  | | \ \  | |_) | | | (_) | | | | | | | | | (_| |
/_/    \_\  \__\___/ \___/|_| |_| \___/|_|    |_| \___/|_|  \___|_| |_|___/_|\___| |_____/   |_|  |_|  \_\ | .__/|_|  \___/|_| |_|_|_|_| |_|\__, |
                                                                                                           | |                               __/ |
                                                                                                           |_|                              |___/ 
Logo


print_softInfo ()
{
echo -e "#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Welcome to STRspy^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#"
echo -e "#		Analysis    		: Finding forensic STRs in a Long Read Sample"
echo -e "#		Requested Citation	: https://doi.org/10.3390/ijms27041889"
echo -e "#		Author		  	: bioinforupesh2009 DOT au AT gmail DOT com"
echo -e "#		Copyright (c) 		: 2026 Kesharwani RK"
echo -e "#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#"
}
print_softInfo

usage="[-h] [-s -r -t -f -b -g -l -k -o -c] -- This script is core-method of STRspy2.0 [https://doi.org/10.3390/ijms27041889]

where:
	-h show the help
	-s input read dir (either bam or fastq)
	-r is input bam? (yes/no)
	-t technology type (ont/pb) 
	-f dir of database fasta
	-b dir of database bed
	-g genome fasta file (fa)
	-l a file of known regions (bed)
	-k cutoff to find top two alleles (Any value from 0.1 to 0.9) [default: 0.4] 
	-o results dir
	-c a file of tools config
	-d Num of Threads"

if [[ ( $@ == "--help" ) ||  $@ == "-h" ]]; then
  echo "Usage: bash `basename $0` $usage"
  exit 0;
fi

if [ $# -eq 0 ]; then
	echo -e "\n"
    echo "Error: No arguments provided, get more help by -h/--help"
    echo -e "\n"
    echo -e "bash `basename $0` [-h] -s <dir of fastq/bam> -r <is_input_bam(yes/no)> -t <ReadType(ont/pb)> -f <DB_fasta_dir> -b <DB_bed_dir> -g <genome_fa> -l <region_bed> -k <filter_threshold> -o <output_dir> -c <tools_config> -d <Number of Threads>"
    echo -e "\n"
    exit 1;
fi

while getopts 's:r:t:f:b:g:l:k:o:c:d:' option
do
    case "${option}" in
        s) input_reads_dir=${OPTARG};;
        r) is_input_bam=${OPTARG};;
        t) readtype=${OPTARG};;
        f) motif_fasta_dir=${OPTARG};;
        b) motif_bed_dir=${OPTARG};;
        g) genome_fa=${OPTARG};;
	l) region_bed=${OPTARG};;
	k) filter_threshold=${OPTARG};;
	o) output_dir=${OPTARG};;
	c) tools_config=${OPTARG};;
	c) threads=${OPTARG};;
    esac
done

# Default value for threads
threads=1
# Check if the 'threads' variable is set and is a positive integer
if ! [[ $threads =~ ^[0-9]+$ ]] || [ "$threads" -le 0 ]; then
    echo -e "Invalid or no value provided for threads, setting to default (1).."
    threads=1
fi

## setting default values if not assinged
if [[ -z "$filter_threshold" ]]
then
	echo -e '\n'
	echo "Note: cutoff (-k) option is not opted; Setting default value for cutoff"
  	filter_threshold=0.4
fi

if [[ ! -d "$output_dir" ]]; then
	echo -e "\n#Output directory "$output_dir" does not exist !!\n"
	echo "Usage: bash `basename $0` $usage"
	exit;
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
	echo "Usage: bash `basename $0` $usage"
	exit 1;
elif [[ ! -d "$motif_fasta_dir" ]]; then
	echo -e "\n#Input directory "$motif_fasta_dir" does not exist !!\n"
	echo "Usage: bash `basename $0` $usage"
	exit 1;
elif [[ ! -d "$motif_bed_dir" ]]; then
	echo -e "\n#Input directory "$motif_bed_dir" does not exist !!\n"
	echo "Usage: bash `basename $0` $usage"
	exit 1;
elif [[ ! -f "$region_bed" ]]; then
	echo -e "\n#Input region_bed "$region_bed" does not exist !!\n"
	echo "Usage: bash `basename $0` $usage"
	exit 1;
elif [[ ! -f "$tools_config" ]]; then
	echo -e "\n#Input tools_config "$tools_config" does not exist !!\n"
	echo "Usage: bash `basename $0` $usage"
	exit 1;
elif [[ "$is_input_bam" != "yes" ]] && [[ "$is_input_bam" != "no" ]] ; then
	echo -e "\n#Input read type should only be: yes or no, analysis halted.. !!\n"
	echo -e "\n"
	echo "Usage: bash `basename $0` $usage"
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
	echo -e "Treads:" "$threads"
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
	fastq=($input_reads_dir/*.fastq.gz)
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

if [[ "$is_input_bam" == "yes" ]] && [[ ! -e "$genome_fa" ]]; then
	## ignore genome fasta in case of bam input reads if user provides nothing
	genome="NULL"
	echo -e "genome ref fasta:" "$genome"
	echo -e "========================================================"
fi

if [[ "$is_input_bam" == "yes" ]] && [[ -f "$genome_fa" ]]; then
	## ignore genome fasta in case of bam input reads
	genome=NULL
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
		region_cov=$($samtools view -c -F 4 -L $arg3 $bamfile)
		bam_cov=$($samtools view -c -F 4 $bamfile)
		paste <(echo $bam_cov) <(echo $region_cov) | awk '{print $1"\t"$2"\t"$2/$1*100"(%)"}' > $arg2/"$bamfile_name".regions.OverlapStats.txt
		## header
		sed -i '1iGenomicMapping\tRegionsOverllaped\tRatio' $arg2/"$bamfile_name".regions.OverlapStats.txt
	done
}

#"==================================================================="
## step1 : mapping to genome 
#"==================================================================="

if [[ $read_type == "fastq" ]]; then
	mkdir -p $output_dir/GenomeMapping
	echo -e "#fastq map to genome.."
	if [[ "$readtype" == "ont" ]]; then
		$parallel -j5 "$minimap --MD -L -t $threads -ax map-ont $genome {} -o $output_dir/GenomeMapping/{/.}.minimap.sam" :::  $input_reads_dir/*.fastq.gz
	elif [[ "$readtype" == "pb" ]]; then
		$parallel -j5 "$minimap --MD -L -t $threads -ax map-pb $genome {} -o $output_dir/GenomeMapping/{/.}.minimap.sam" :::  $input_reads_dir/*.fastq.gz
	else
		echo -e "#Provided Read type is not known"
		exit 1;
	fi
fi

#### checking sam files existence
if [[ "$is_input_bam" == "no" ]]; then
	type="fastq"
	sam=($output_dir/GenomeMapping/*.minimap.sam)
	if [[ -e "${sam[0]}" ]]; then
		## sam2bam
		echo -e "#sam to bam.."
		$parallel -j5 "$samtools view -@ $threads -S -b {} -o $output_dir/GenomeMapping/{/.}.bam" ::: $output_dir/GenomeMapping/*.sam
		## bam2sortedbam and index
		echo -e "#bam sort and index.."
		$parallel -j5 "$samtools sort -@ $threads -o $output_dir/GenomeMapping/{/.}.sorted.bam {}" ::: $output_dir/GenomeMapping/*.minimap.bam
		## bam index
		$parallel -j5 "$samtools index -@ $threads {}" ::: $output_dir/GenomeMapping/*.sorted.bam
		## remove temp sam and bam
		rm -rf $output_dir/GenomeMapping/*.sam $output_dir/GenomeMapping/*.minimap.bam
		echo -e "#Done."
	else
		echo -e "\n#ERROR: Minimap sams from fastq inputs are not found !!\n"
		exit 1;
	fi
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
		echo -e "#Summerizing the mapped, unmapped reads and their percentage"
		get_cov $input_reads_dir $output_dir/GenomicMappingStats $region_bed
		echo -e "#Done"
	else
		echo -e "\n#ERROR: Provided Genomic bams are not found !!\n"
		exit 1;
	fi
fi

#"==================================================================="
## step2 : Mapping to STR.fa + conting + normalization + SNV calling
#"==================================================================="
if [[ $read_type == "$type" ]]; then
	echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	echo -e "#Spying on STR for a given samples...."
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
			## filter reads with lower than 1 Mapping quality
			$samtools view -@ $threads -bq 1 $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam > $output_dir/IntersectedRegions/"$bam_name"_"$bed_name"Q1.bam
			## bam to fastq
			#$bedtools bamtofastq -i $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam -fq $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam.fq
			$samtools bam2fq $output_dir/IntersectedRegions/"$bam_name"_"$bed_name"Q1.bam > $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam.fq
			echo -e "#Done.\n"
			echo -e "#Mapping fastq to motif fasta...\n"
			if [[ "$readtype" == "ont" ]]; then
				$minimap -t $threads --MD -L -ax map-ont $motif_fasta_dir/"$bed_fname".fa $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam.fq -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam
			elif [[ "$readtype" == "pb" ]]; then
				$minimap -t $threads --MD -L -ax map-pb $motif_fasta_dir/"$bed_fname".fa $output_dir/IntersectedRegions/"$bam_name"_"$bed_name".bam.fq -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam
			else
				echo -e "#Provided Read type is not known"
				exit 1;
			fi
			echo -e "#Done.\n"
			echo -e "#sam to bam + sort + index..."
			$samtools view -@ $threads -S -b $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.bam
			$samtools sort -@ $threads -o $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.bam
			$samtools index -@ $threads $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam
			rm -rf $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sam $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.bam
			## SNV calling by xatlas
			echo -e "#SNV calling by xatlas...\n"
			$xatlas \
			-r $motif_fasta_dir/"$bed_fname".fa \
			-i $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam \
			-s $output_dir/SNVcalls/"$bed_fname"_"$bam_name" \
			-p $output_dir/SNVcalls/"$bed_fname"_"$bam_name"
			echo -e "#Counting Alleles..."
			#$samtools view -q 1 -F 4 $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam | cut -f 3 | sort | uniq -c | sed -e 's/^ *//;s/ /\t/' | \
			#grep -v '*' | sort -nr -k1,1 > $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt
			## reduce background repeat counts by removing secondary and supplementary alignments and counts only primary 
			$samtools view -@ $threads -q 1 -F 2308 $output_dir/IntersectMappedReads/"$bed_fname"_"$bam_name"_alignment.sorted.bam | cut -f 3 | sort | uniq -c | sed -e 's/^ *//;s/ /\t/' | \
			grep -v '*' | sort -nr -k1,1 > $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt
			echo -e "#Normalize with maximum value of Allele counts.."
			awk 'FNR==NR{max=($1+0>max)?$1:max;next} {print $2"\t"$1"\t"$1/max}' $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt \
			$output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt > temp && mv temp $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt 
			## header
			sed -i '1iSTR\tRawCounts\tNormalizedCounts' $output_dir/Countings/"$bed_fname"_"$bam_name"_Allele_freqs.txt
			## get top two by getting top two
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

) 2>&1) | tee -a "$output_dir"/STRspyLogParallel.log
