#!/bin/bash

set -e
set -a

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
# # ====================================================================================================================#

# Usage: bash STRspy_run_v1.1_Args.sh -i config/InputConfig.txt -t config/ToolsConfig.txt -j normal

#################################### WE REQUEST YOU TO PLEASE DO NOT TOUCH BELOW THIS LINE ##############################

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
echo -e "#		Requested Citation	: https://doi.org/10.1016/j.fsigen.2021.102629"
echo -e "#		Author		  	: bioinforupesh2009 DOT au AT gmail DOT com"
echo -e "#		Copyright (c) 		: 2021 Kesharwani RK"
echo -e "#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#"
}
print_softInfo

usage="[-h] [-i -t -j] -- This script is wrapper of STRspy [https://doi.org/10.1016/j.fsigen.2021.102629]

where:
	-h show the help
	-i input config (InputConfig.txt)
	-t tools config (ToolsConfig.txt)
	-j job type (parallel/normal) [default: normal]"

if [[ ( $@ == "--help" ) ||  $@ == "-h" ]]; then
  echo "Usage: bash `basename $0` $usage";
  echo -e "\n";
  exit 0;
fi

if [ $# -eq 0 ]; then
	echo -e "\n"
    echo "Error: No arguments provided, get more help by -h/--help"
    echo -e "\n"
    echo -e "bash `basename $0` [-h] -i config/InputConfig.txt -t config/ToolsConfig.txt -j normal"
    echo -e "\n"
    exit 1;
fi

while getopts 'i:t:j:' option
do
    case "${option}" in
        i) InputConfig=${OPTARG};;
        t) ToolsConfig=${OPTARG};;
        j) ParallelJob=${OPTARG};;
    esac
done

## setting default values if not assinged
if [[ -z "$ParallelJob" ]]
then
	echo -e '\n'
	echo "Note: ParallelJob (-j) option is not opted; Setting default value"
  	filter_threshold="normal"
fi

## check right input
if [ ! -s $ToolsConfig ]; then
	echo -e "ERROR : InputConfig =" $ToolsConfig "does not exist\n";
	echo $usage
	exit 1;
fi

## check right input
if [ ! -s $InputConfig ]; then
	echo -e "ERROR : InputConfig =" $InputConfig "does not exist\n";
	echo $usage
	exit 1;
fi

## Extract parameters from the given file
#clear
echo -e "\n"
echo -e "########################################################"
echo -e "#################   Input Parameters   #################"
echo -e "########################################################"

INPUT_DIR=$(cat $InputConfig | grep -w '^INPUT_DIR' | cut -d '=' -f2)
INPUT_BAM=$(cat $InputConfig | grep -w '^INPUT_BAM' | cut -d '=' -f2)
READ_TYPE=$(cat $InputConfig | grep -w '^READ_TYPE' | cut -d '=' -f2)
STR_FASTA=$(cat $InputConfig | grep -w '^STR_FASTA' | cut -d '=' -f2)
STR_BED=$(cat $InputConfig | grep -w '^STR_BED' | cut -d '=' -f2)
GENOME_FASTA=$(cat $InputConfig | grep -w '^GENOME_FASTA' | cut -d '=' -f2)
REGION_BED=$(cat $InputConfig | grep -w '^REGION_BED' | cut -d '=' -f2)
NORM_CUTOFF=$(cat $InputConfig | grep -w '^NORM_CUTOFF' | cut -d '=' -f2)
OUTPUT_DIR=$(cat $InputConfig | grep -w '^OUTPUT_DIR' | cut -d '=' -f2)
## print paramters from a input file
echo -e "\n"
echo -e "#DIR OF LONG READS INPUT 	:" $INPUT_DIR
echo -e "#FILE TYPE BAM?			:" $INPUT_BAM
echo -e "#READ TYPE			:" $READ_TYPE
echo -e "#DIR OF STR FASTA 		:" $STR_FASTA
echo -e "#DIR OF STR BED 		:" $STR_BED
echo -e "#GENOME FASTA 			:" $GENOME_FASTA
echo -e "#FILE OF STR REGION BED 	:" $REGION_BED
echo -e "#NORMALIZATION THRESHOLD 	:" $NORM_CUTOFF
echo -e "#OUTPUT DIR 			:" $OUTPUT_DIR


echo -e "\n"
echo -e "########################################################"
echo -e "####################   Tools Path    ###################"
echo -e "########################################################"

BEDTOOLS=$(cat $ToolsConfig | grep -w '^BEDTOOLS' | cut -d '=' -f2)
MINIMAP=$(cat $ToolsConfig | grep -w '^MINIMAP' | cut -d '=' -f2)
SAMTOOLS=$(cat $ToolsConfig | grep -w '^SAMTOOLS' | cut -d '=' -f2)
XATLAS=$(cat $ToolsConfig | grep -w '^XATLAS' | cut -d '=' -f2)
PARALLEL=$(cat $ToolsConfig | grep -w '^PARALLEL' | cut -d '=' -f2)
## print tools input from a input file
echo -e "\n"
echo -e "#BEDTOOLS			:" $BEDTOOLS
echo -e "#MINIMAP			:" $MINIMAP
echo -e "#SAMTOOLS			:" $SAMTOOLS
echo -e "#XATLAS				:" $XATLAS
echo -e "#PARALLEL 			:" $PARALLEL

########################
#### Analysis begins ###
########################

if [[ $ParallelJob == "parallel" ]] || [[ $ParallelJob == "Parallel" ]] || [[ $ParallelJob == "PARALLEL" ]] ; then
	if [[ -f "STRspy_Parallel_v1.1_Args.sh" ]]; then
		echo -e "\n"
		echo -e "\t\t  ~ ~ ~ ~ Running STRspy ~ ~ ~ ~	 "
		echo -e "\t\tAnalysis date:" `date`
		echo -e "\n"
		## parallel version of STRspy
		bash STRspy_Parallel_v1.1_Args.sh -s "$INPUT_DIR" -r "$INPUT_BAM" -t "$READ_TYPE" -f "$STR_FASTA" -b "$STR_BED" -g "$GENOME_FASTA" -l "$REGION_BED" -k "$NORM_CUTOFF" -o "$OUTPUT_DIR" -c "$ToolsConfig"
		echo -e "#Analysis finished.\n" `date`
	else
		echo -e "please make sure you are in the same directory of STRspy\n"
		exit 1;
	fi
else
	if [[ -f "STRspy_Normal_v1.1_Args.sh" ]]; then
		echo -e "\n"
		echo -e "\t\t  ~ ~ ~ ~ Running STRspy ~ ~ ~ ~	 "
		echo -e "\t\tAnalysis date:" `date`
		echo -e "\n"
		## nested loop version STRspy
		bash STRspy_Normal_v1.1_Args.sh -s "$INPUT_DIR" -r "$INPUT_BAM" -t "$READ_TYPE" -f "$STR_FASTA" -b "$STR_BED" -g "$GENOME_FASTA" -l "$REGION_BED" -k "$NORM_CUTOFF" -o "$OUTPUT_DIR" -c "$ToolsConfig"
	else
		echo -e "please make sure you are in the same directory of STRspy\n"
		exit 1;
	fi
fi

set +a

exit $?

