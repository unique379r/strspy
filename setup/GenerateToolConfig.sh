#!/bin/bash


#echo -e "This will create a ToolConfig file to run STRspy..."

SAMTOOLS=$(which samtools)
echo -e "SAMTOOLS="$SAMTOOLS > UserToolsConfig.txt
BEDTOOLS=$(which bedtools)
echo -e "BEDTOOLS="$BEDTOOLS >> UserToolsConfig.txt
XATLAS=$(which xatlas)
echo -e "XATLAS="$XATLAS >> UserToolsConfig.txt
PARALLEL=$(which parallel)
echo -e "PARALLEL="$PARALLEL >> UserToolsConfig.txt
MINIMAP=$(which minimap2)
echo -e "MINIMAP="$MINIMAP >> UserToolsConfig.txt
SEQKIT=$(which seqkit)
echo -e "SEQKIT="$SEQKIT >> UserToolsConfig.txt

echo -e "ToolConfig file is generated."

