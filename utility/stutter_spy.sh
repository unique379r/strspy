#!/bin/bash

#Inputs: command line arguments
CountsFreqDir="$1" 
ValidatedSTR="$2" 
ResultDir="$3"
filename="$4"
DeleteTemp="$5"

print_USAGE()
{
echo -e "USAGE: bash ./stutter_spy.sh <CountsFreqDir> <ValidatedSTRfile> <ResultDir> <filename> <DeleteTemp(yes/no)>\n"
echo "EXAMPLE:"
echo "bash ./stutter_spy.sh ../Countings ../ValidatedSTRThreeColumns.txt ../ResultsDir Output30_05 yes"
echo -e "\n"
}

if [[ $# -ne 5 ]]; then
		echo "#ERROR: Please privide all and correct inputs"
		echo -e "\n"
		print_USAGE
		exit;
fi

## benchmarking from predcted vs validated
((
echo -e "^^^^^^^^^^^^^^^Input^^^^^^^^^^^^^"
echo -e "Counts dir:\t" $CountsFreqDir
echo -e "Validated STRs:\t" $ValidatedSTR
echo -e "Output dir:\t" $ResultDir
echo -e "Output name:\t" $filename
echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

# create a output dir regardless of existance
mkdir -p $ResultDir
cp $ValidatedSTR $ResultDir
echo -e "#Prepare a three columns (locus, motif and norm_value) files from predicted dir.."
for i in $CountsFreqDir/*Allele_freqs.txt
do
	sed '1d' $i | tr '_' ' ' | sed 's/\]/] /g' | awk '{print $1"\t"$(NF-2)"\t"$NF}' | sort -r -k3,3 > "$i".three.tab
done
mv $CountsFreqDir/*.three.tab $ResultDir
cd $ResultDir
echo -e "#Done."

echo -e "#Rename within sample.."
for i in  *three.tab; do 
  	sample=$(echo $i | tr '.' ' ' | awk '{print $1"."$2}');
  	awk -v f="$sample" 'OFS="\t" {print f,$2,$3}' $i > "$i".rename.tab
done
echo -e "#Done."

# echo -e "#Ingnore the truth sets from vaildated alleles and make the stutter files for each samples+STR"
# for i in *.rename.tab;  
# do
# 	sample=$(cat $i | awk '{print $1}' | head -1); validlocus=$(cat $ValidatedSTR | grep "$sample" ); allele1=$(echo $validlocus | awk '{print $2}'); allele2=$(echo $validlocus | awk '{print $3}');
# 	awk -v f=$allele1 -v g=$allele2 '$2==f+1 || $2==f-1 || $2==g+1 || $2==g-1' $i > "$i"_"$filename"_stutter.txt
# done

echo -e "#Ingnore the truth sets from vaildated alleles and make the stutter files for each samples+STR"
for i in *.rename.tab;  
do
	sample=$(cat $i | awk '{print $1}' | head -1); validlocus=$(cat $ValidatedSTR | grep "$sample" ); allele1=$(echo $validlocus | awk '{print $2}'); allele2=$(echo $validlocus | awk '{print $3}');
	## check the true alleles if it is a interger or a flating numbers.
	if [[ "$allele1" =~ ^[+-]?[0-9]*$ ]];then
		echo -e "Given first allele is an integer in sample:" "$sample"
		awk -v f=$allele1 '$2==f+1 || $2==f-1' $i > "$i"_"$filename"_stutter.txt
	else
		[[ "$allele1" =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]
		echo -e "Given first allele is a floating in sample:" "$sample"
		allele1k=$(echo $allele1| awk -F'.' '{print $1}')
		awk -v f=$allele1 -v k=$allele1k '$2==f+1 || $2==f-1 || $2==k+1 || $2==k-1' $i > "$i"_"$filename"_stutter.txt
	fi
	## checking for second alles
	if [[ "$allele2" =~ ^[+-]?[0-9]*$ ]];then
		echo -e "Given second allele is an integer in sample:" "$sample"
		awk -v g=$allele2 '$2==g+1 || $2==g-1' $i >> "$i"_"$filename"_stutter.txt
	else
		[[ "$allele2" =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]
		echo -e "Given second allele is a floating in sample:" "$sample"
		allele2k=$(echo $allele2| awk -F'.' '{print $1}')
		awk -v g=$allele2 -v p=$allele2k '$2==g+1 || $2==g-1 || $2==p+1 || $2==p-1' $i >> "$i"_"$filename"_stutter.txt
	fi
done

stutterfiles=(*_stutter.txt)
# rename files
if [[ ${#stutterfiles[@]} -gt 0 ]]; then
	#echo "stutter files present"
	for i in *stutter.txt
	do 
		mv "$i" "${i/.txt.three.tab.rename.tab/}"
	done
	echo -e "#Done."
else
	echo "stutter files does not found."
	exit 1;
fi
cd ..

if [[ "$DeleteTemp" == "yes" || "$DeleteTemp" == "Yes" ]]; then
	echo -e "#deleting temp files.."
	rm -f $ResultDir/*three.tab
	rm -f $ResultDir/*rename.tab
	rm -f $ResultDir/$ValidatedSTR
	echo -e "#Done."
fi

) 2>&1) | tee -a "$3"/stutter_"$filename".log

