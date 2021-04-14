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
CountsTopDir="$1" 
ValidatedSTR="$2" 
ResultDir="$3"
filename="$4"
FilterThreshold="$5"
DeleteTemp="$6"

print_USAGE()
{
echo -e "USAGE: bash ./1.STRspy_bencharkingscript.sh <CountsDirFromSTRspy> <ValidatedSTR> <ResultDir> <filename> <FilterThreshold (must be a floating number [0.1-0.9])> <DeleteTemp(yes/no)>\n"
echo "EXAMPLE:"
echo "bash ./1.STRspy_bencharkingscript.sh ../Countings ../ValidatedSTR.txt ../ResultsDir Output30_05 0.5 no"
echo -e "\n"
}

if [[ $# -ne 6 ]]; then
		echo "#ERROR: Please privide all and correct inputs"
		echo -e "\n"
		print_USAGE
		exit;
fi

## benchmarking from predcted vs validated
((
echo -e "^^^^^^^^^^^^^^^Input^^^^^^^^^^^^^"
echo -e "Counts dir:\t" $CountsTopDir
echo -e "Validated STRs:\t" $ValidatedSTR
echo -e "Output dir:\t" $ResultDir
echo -e "Output name:\t" $filename
echo -e "Filter Threshold:\t" $FilterThreshold
echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

echo -e "#prepare a new top two STRs from user input cutoff.."
mkdir -p $ResultDir/UserTopTwo_"$FilterThreshold"
for i in $CountsTopDir/*Allele_freqs.txt
do
	file=$(basename $i)
	sed '1d' $i | awk  -v f="$FilterThreshold" '$3>=f' | tr '_' ' ' | sed 's/\]/] /g' | awk '{print $1"\t"$(NF-2)"\t"$NF}' | \
	sort -r -k3,3 | head -n 2 > $ResultDir/UserTopTwo_"$FilterThreshold"/"$file"_"$FilterThreshold"_UserToptwo.txt
  	sed '1iLocus\tAllele\tNormalizedCounts' $ResultDir/UserTopTwo_"$FilterThreshold"/"$file"_"$FilterThreshold"_UserToptwo.txt > \
  	$ResultDir/UserTopTwo_"$FilterThreshold"/temp && \
  	mv $ResultDir/UserTopTwo_"$FilterThreshold"/temp $ResultDir/UserTopTwo_"$FilterThreshold"/"$file"_"$FilterThreshold"_UserToptwo.txt
done
echo -e "Done."

echo -e "#rename within sample.."
cd $ResultDir/UserTopTwo_"$FilterThreshold"
for i in *_UserToptwo.txt; do 
	#sample=$(basename $i)
  	sample=$(echo $i | tr '.' ' ' | awk '{print $1"."$2}');
  	#echo -e $i $sample
  	sed -i "s/NormalizedCounts/$sample/g" $i; 
done
cd -
echo -e "Done."

echo -e "#make a single file to compare with validated STR (Locus_sample\tAlleles).."
paste -sd ' ' $ResultDir/UserTopTwo_"$FilterThreshold"/*_UserToptwo.txt | sed '/^$/d' | awk '{print $3"\t"$5","$8}' \
| sed 's/,$/,0/g' | sed 's/,/\t/g' \
| sed 's/D19S443/D19S433/g' > $ResultDir/"$filename"_"$FilterThreshold"_STR_SampleResult.table.txt
echo -e "Done."

echo -e "#Match from validated set.."
join <(sort $ValidatedSTR) <(sort $ResultDir/"$filename"_"$FilterThreshold"_STR_SampleResult.table.txt) | sed 's/ /\t/g' > \
$ResultDir/"$filename"_"$FilterThreshold"_matched_truth_STR.txt
echo -e "Done."

echo -e "#Comparing validated STRs vs Predicted STRs.."
echo -e "#Total STRs to compare.."
cat $ResultDir/"$filename"_"$FilterThreshold"_matched_truth_STR.txt | wc -l
awk '{ if ($2==$4 || $2==$5) print $0"\tMatch"; else if ($3==$5 || $3==$4) print $0"\tMatch"; else print $0"\tNomatch"}' \
$ResultDir/"$filename"_"$FilterThreshold"_matched_truth_STR.txt \
| awk '{ if ( $6=="Match" && $2+$3==$4+$5) print $0"\tBothMatch"; else if ( $6=="Match" && $2+$3!=$4+$5) print $0"\tOneMatch"; else print $0"\tBothNomatch"}' \
| sed 's/ /\t/g' > $ResultDir/"$filename"_"$FilterThreshold"_Results.txt
#echo -e "Done."

if [[ -f $ResultDir/"$filename"_"$FilterThreshold"_Results.txt ]]; then
	## total Results
	echo -e "#Counts of Partial Match.."
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | wc -l
	echo -e "#Counts of Exact Match (Both Alleles).."
	grep 'BothMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | wc -l
	echo -e "#Counts of incorrect Match"
	grep 'Nomatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | wc -l
	## erros findings
	echo -e "\n#Case Type 1: 12,12 == 12,0; (Results: homozygous == homozygous i.e. Correct Prediction)"
	#echo -e "#one match but one predicted Zero therefore it is Correct Prediction..." 
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | awk 'OFS="\t" {if ($2==$3 && $5 == "0") print $0}' | wc -l
	echo "#Example:"
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | awk 'OFS="\t" {if ($2==$3 && $5 == "0") print $0}' | head -n2
	
	echo -e "\n#Case Type 2: 12,12 == 12,14; (Results: homozygous == hetrozygous i.e. FP)"
	#echo -e "#validated same but pred found one exact only.."
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | awk 'OFS="\t" {if ($2==$3 && $5 != "0") print $0}' | wc -l 
	echo "#Example:"
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | awk 'OFS="\t" {if ($2==$3 && $5 != "0") print $0}' | head -n2

	echo -e "\n#Case Type 3 (a): 12,13 == 12,14; (Results: hetrozygous == hetrozygous i.e. FP)"
	echo -e "OR"
	echo -e "#Case Type 3 (b): 12,0 == 12,14;  (Results: homozygous == hetrozygous i.e. FP)"
	#echo -e "#one match but one predicted wrong as hetrozygous (FP)..."
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | awk 'OFS="\t" {if ($2!=$3 && $5 != "0") print $0}' | wc -l
	echo "#Example:"
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | awk 'OFS="\t" {if ($2!=$3 && $5 != "0") print $0}' | head -n2

	echo -e "\n#Case Type 4: 12,13 == 12,0; (Results: hetrozygous == homozygous i.e. FN)"
	#echo -e "#one match but one predicted wrong as homozygous..."
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt| awk 'OFS="\t" {if ($2!=$3 && $5 == "0") print $0}' | wc -l 
	echo "#Example:"
	grep 'OneMatch' $ResultDir/"$filename"_"$FilterThreshold"_Results.txt | awk 'OFS="\t" {if ($2!=$3 && $5 == "0") print $0}' | head -n2
	echo -e "All Done."
else
	echo -e "ERROR: Result files do not exists !!"
fi

if [[ "$DeleteTemp" == "yes" ]]; then
	echo -e "#deleting temp files.."
	rm -fr $ResultDir/UserTopTwo_"$FilterThreshold"
	echo -e "Done."
fi

) 2>&1) | tee -a "$3"/bench_"$FilterThreshold"_"$filename".log

## Compute Recall, Precision and F1score
if [[ -f "$3"/bench_"$FilterThreshold"_"$filename".log ]]; then
	grep -A1 '#Counts of\|#Case Type' "$3"/bench_"$FilterThreshold"_"$filename".log  | grep -v '#\|--\|OR' | tr '\n' '\t' | grep -v '%' > tmpfile
	awk -F'\t' 'OFS="\t"{print ($2+$4)*2+$5+$6+$7, ($3*2)+$5+$6, $7}' tmpfile \
	| awk 'OFS="\t"{print $0, sprintf("%.3f",$1/($1+$3)*100), sprintf("%.3f",$1/($1+$2)*100)}' \
	| awk 'OFS="\t"{print $0, 2*($4*$5)/($4+$5)}' | awk 'OFS="\t";BEGIN{print "TP","FP","FN","Recall","Precision","F1score"}0' > $ResultDir/bench_"$FilterThreshold"_"$filename".score
	rm -rf tmpfile
fi

