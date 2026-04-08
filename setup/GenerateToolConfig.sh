#!/bin/bash


#echo -e "This will create a ToolConfig file to run STRspy..."

SAMTOOLS=$(which samtools)
echo -e "SAMTOOLS="$SAMTOOLS > config/UserToolsConfig.txt
BEDTOOLS=$(which bedtools)
echo -e "BEDTOOLS="$BEDTOOLS >> config/UserToolsConfig.txt
XATLAS=$(which xatlas)
echo -e "XATLAS="$XATLAS >> config/UserToolsConfig.txt
PARALLEL=$(which parallel)
echo -e "PARALLEL="$PARALLEL >> config/UserToolsConfig.txt
MINIMAP=$(which minimap2)
echo -e "MINIMAP="$MINIMAP >> config/UserToolsConfig.txt
SEQKIT=$(which seqkit)
echo -e "SEQKIT="$SEQKIT >> config/UserToolsConfig.txt

echo -e "ToolConfig file is generated."

