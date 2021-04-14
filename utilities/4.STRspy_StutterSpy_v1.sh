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

#Inputs: command line arguments
CountsFreqDir="$1" 
ValidatedSTRDir="$2" 
ResultDir="$3"

print_USAGE()
{
echo -e "USAGE: bash ./StutterSpy_v1.sh <CountsFreqDir> <ValidatedSTRDir> <ResultDir>\n"
echo "EXAMPLE:"
echo "bash ./StutterSpy_v1.sh ../Countings ../ValidatedSTRDir ../ResultsDir test"
echo -e "\n"
}

if [[ $# -ne 3 ]]; then
		echo "#ERROR: Please privide all and correct inputs"
		echo -e "\n"
		print_USAGE
		exit;
fi

## benchmarking from predcted vs validated
((
echo -e "^^^^^^^^^^^^^^^Input^^^^^^^^^^^^^"
echo -e "Counts dir        :\t" $CountsFreqDir
echo -e "Validated STRs dir:\t" $ValidatedSTRDir
echo -e "Output dir        :\t" $ResultDir
echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

StuttersSpy="./StutterSpy_v1.py"

# create a output dir regardless of existance
mkdir -p $ResultDir
cp $CountsFreqDir/*Allele_freqs.txt $ResultDir
cp $ValidatedSTRDir/*.tab $ResultDir
cd $ResultDir
echo -e "#Done."

echo -e "##running python script"
for i in *Allele_freqs.txt
do
	counts_samplename=$(basename $i _Allele_freqs.txt)
	counts_sample=$(echo $i | awk -F'_' '{print $2}')
	counts_locus=$(echo $i | tr '_' ' ' | awk '{print $1}')
	depth=$(echo $counts_samplename | tr '_' ' ' | awk -F'.' '{print $1"."$2}' | awk '{print $3}')
	echo "##########"
	echo "Counts file. :" $counts_samplename
	echo "Counts Sample:" $counts_sample
	echo "Counts Locus :" $counts_locus
	echo "Counts Depth :" $depth
	echo "##########"
	for j in *.tab
	do
		motif_samplename=$(basename $j .txt.tab)
		motif_sample=$(echo $j | awk -F'_' '{print $2}' | sed 's/.txt.tab//')
		echo "========="
		echo "motif file :" $motif_samplename
		echo "motif Locus:" $motif_sample
		if [[ "$counts_sample" == "$motif_sample" ]]; then
			echo "#Its match from sample of counts. Spying Stutters..."
			echo "========="
			$StuttersSpy -i1 $j -i2 $i -t $counts_locus -s $counts_sample -d $depth
			echo "#Stutters, Non-stutters and Truth alleles sets are written as *.out in your dir:" $ResultDir
		else
			echo "#Please pay attention!! The sample of counts does not match with the sample motif/truth sets."
			echo "========="
		fi
	done
done
echo "#Done"

rm -rf *.tab *Allele_freqs.txt 
cd ..

) 2>&1) | tee -a "$3"/stutter_Log.log

