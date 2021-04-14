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

# # Usage: bash ./STRspy.sh InputConfig.txt

					########################################################
################### WE REQUEST YOU TO PLEASE DO NOT TOUCH BELOW THIS LINE ####################
					########################################################
echo -e "\n"
print_softInfo ()
{
echo -e "#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Welcome to STRspy^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#"
echo -e "#		Analysis    		: Finding STRs in a Long Read Sample"
echo -e "#		Requested Citation	: Kesharwani RK et al.(2021)"
echo -e "#		Author		  	: bioinforupesh2009 DOT au AT gmail DOT com"
echo -e "#		Copyright (c) 		: 2021 Kesharwani RK"
echo -e "#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#"
}
print_softInfo
##input file
InputConfig="$1"
ToolsConfig="$2"
print_USAGE()
{
echo -e "\n"
echo -e "#Please Provide File Inputs (positional arguments = counts => 2) !!"
echo -e "\n"
echo -e "USAGE:
bash ./STRspy_run_v1.0.sh InputConfig.txt ToolsConfig.txt"
echo -e "\n"
}
## check file input
if [[ $# != 2 ]]; then
	print_USAGE
	exit 0;
fi

## check right input
if [ ! -s $ToolsConfig ]; then
	echo -e "ERROR : InputConfig =" $ToolsConfig "does not exist\n";
	print_USAGE
	exit 1;
fi

## check right input
if [ ! -s $InputConfig ]; then
	echo -e "ERROR : InputConfig =" $InputConfig "does not exist\n";
	print_USAGE
	exit 1;
fi

## Extract parameters from the given file
clear
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

if [[ -f "./scripts/STRspy_Parallel_v1.0.sh" ]]; then
	echo -e "\n"
	echo -e "\t\t  ~ ~ ~ ~ Running STRspy_Parallel_v1.0.sh ~ ~ ~ ~	 "
	#echo -e "\t\tAnalysis date:" `date`
	echo -e "\n"
	bash ./scripts/STRspy_Parallel_v0.1.sh $INPUT_DIR $INPUT_BAM $READ_TYPE $STR_FASTA $STR_BED $GENOME_FASTA $REGION_BED $NORM_CUTOFF $OUTPUT_DIR $ToolsConfig
	#echo -e "#Analysis finished.\n" `date`
else
	echo -e "please make sure you are in the same directory of STRspy
	and have provided all necessary input in InputConfig.txt and ToolsConfig.txt.\n"
	exit 1;
fi

set +a

exit $?

