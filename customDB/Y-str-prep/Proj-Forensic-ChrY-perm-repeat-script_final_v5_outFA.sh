#!/bin/bash


# # This file is part of forensic project

# # Date of edit: Oct 29, 2021

#^^^^^^^^^^^^^^^^^^^^^^^^^##^^^^^^^^^^^^^^^^^^^^^^^^^##^^^^^^^^^^^^^^^^^^^^^^^^^#
## this is first stpe script to make permutation repeats of chr-Y
## the secondstpe would be to generate the fasta sequences 
## and the third and the last stpe to run STRspy on it
#^^^^^^^^^^^^^^^^^^^^^^^^^##^^^^^^^^^^^^^^^^^^^^^^^^^##^^^^^^^^^^^^^^^^^^^^^^^^^#

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

# # ==============================================================================================================================================#

# USAGE:
# bash ./Proj-Forensic-ChrY-perm-repeat-script_final_v3_outFA.sh <motif repeats in file> <locus name> <string_avaible(yes/no) <string_side(left/right/NA)>
# EXAMPLE: bash ./Proj-Forensic-ChrY-perm-repeat-script_final_v3_outFA.sh DYS19.txt DYS19 yes left

## input file should similar to one of them: 
## [TCTA]12 / [TCTA]12 [TCTA]3 / [TCTA]12 ccta [TCTA]3 / [TCTA]8 [TCTG]2 [TCTA]4 / [TAGA]4 CAGA [TAGA]8 [CAGA]8 / [TAGA]11 [TACA]2 [TAGA]2 [TACA]2 [TAGA]4
## [AGAGAT]13 N42 [AGAGAT]8


# # ==============================================================================================================================================#

#################################### WE REQUEST YOU TO PLEASE DO NOT TOUCH BELOW THIS LINE ##############################


##input file
repeat_string="$1"
strname="$2"
string="$3" ##(yes/no)
string_side="$4" ## (left/right)


print_USAGE()
{
echo -e "\n"
echo -e "#Please Provide all inputs !!"
echo -e "\n"
echo -e "USAGE:
bash ./Proj-Forensic-ChrY-perm-repeat-script_final_v3_outFA.sh <input motif repeats> <motif name> <string_avaible(yes/no) <string_side(left/right/NA)>"
echo -e "EXAMPLE: bash ./Proj-Forensic-ChrY-perm-repeat-script_final_v3_outFA.sh DYS19.txt DYS19 yes left"
echo -e "\n"
}

## check file input
if [[ $# != 4 ]]; then
        print_USAGE
        exit 0;
fi


## length of brakcet repeats
rep_count=$(awk -F\[ '{print NF-1}' $repeat_string)


## fucntion to generate long perm-repeats from the given list
gen_repeats () {
	pre_list=$1
	n_times=$2
	gawk -v n="$n_times" '
	{
   	rec = rec $0 RS
	}
	1
	END {
   	for (i=2; i<=n; ++i) {
       	x=gensub(/([^[:digit:]])1([^[:digit:]])/, "\\1" i "\\2", "g", rec)
       	printf "%s", gensub(/([^[:digit:]])1([^[:digit:]])/, "\\1" i "\\2", "g", x)
   	}
	}' "$pre_list"
}

## functions for bracket repeats = 1; [TCTA]12
permutation_repeats_for_one () {
	bracket_repeats_string=$1
	strname=$2
	mystr1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $1}')
	mynum1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $2}')
	mynum1_start=$(($mynum1 - 5))
	mynum1_end=$(($mynum1 + 5))
	## remove negative to 1
	if [[ $mynum1_start -le 0 ]]
	then
    		mynum1_start=1
	fi
	## repeats the string/bracket strings
	part_one=$(for (( c=$mynum1_start; c<=$mynum1_end; c++)); do echo -e $mystr1"\t"$c; done)
	lengthoffirst=$(printf "%s\n" "${part_one[@]}" | wc -l)
	#printf "%s\n" "${part_one[@]}"
	printf "%s\n" "${part_one[@]}" > $strname"_temp"
	while read line; do
		sec_num=$(echo $line |  awk '{print $2}')
		myrepeat1=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr1})
		echo -e ">"$strname"_["$mystr1"]"$sec_num"_"$sec_num
        	echo -e $myrepeat1
    	done<$strname"_temp" > $strname"_perm.fa"
    	rm -f $strname"_temp"
}

## functions for bracket repeats = 2; [TCTA]12 [TCTA]3 / [TCTA]12 ccta [TCTA]3
permutation_repeats_for_two () {
	bracket_repeats_string=$1
	middle=$2
	strname=$3
	mystr1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $1}')
	mynum1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $2}')
	## second repeats
	if [[ $middle == "yes" ]]; then
		mystr2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $4}')
		mynum2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $NF}')
	else
		mystr2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
		mynum2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $NF}')
	fi
	## logic to handle if second number is greater than first (primary repeats)
	mynum1_start=$(($mynum1 - 5))
	## remove negative to 1
	if [[ $mynum1_start -le 0 ]]
	then
    		mynum1_start=2
	fi
	mynum2_start=$(($mynum2 - 5))
	## remove negative to 1
	if [[ $mynum2_start -le 0 || $mynum2_start -gt 1 ]]
	then
    		mynum2_start=1
	fi
	## now i added 5 to num2 if its bigger than fum1
	if (( $mynum2 >= $mynum1 )); then
		sum2=$(( $mynum2 + 5))
		mynum1_end=$(($mynum1 + $sum2))
	else
		mynum1_end=$(($mynum1 + 5))
	fi
	## repeats the string/bracket strings
	part_one=$(for (( c=$mynum1_start; c<=$mynum1_end; c++)); do echo -e $mystr1"\t"$c; done)
	lengthoffirst=$(printf "%s\n" "${part_one[@]}" | wc -l)
	part_two=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo -e $mystr2"\t"$mynum2_start; done)
	## side by side
	if [[ $middle == "yes" ]]; then
		midstring0=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
		midstring1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
		findN=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $1}')
		if [[ $findN == "N" ]]; then
			ntime=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $2}')
			midstring1=$(echo -e "ACGT" | fold -w1 | shuf -r -n $ntime | tr -d '\n')
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		else
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		fi
		paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${midstring[@]}") <(printf "%s\n" "${part_two[@]}") > temp_list
	else
		paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${part_two[@]}") > temp_list
	fi

	# print use function to gene repeats
	if (( $mynum2 >= $mynum1 )); then
		n_times=$(( $mynum2 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	else
		gen_repeats temp_list 7 > $strname"_temp"
		rm -f temp_list
	fi
	## fasta work
	if [[ $middle == "yes" ]]; then
		while read line; do
			first_num=$(echo $line |  awk '{print $2}')
			sec_num=$(echo $line |  awk '{print $NF}')
			myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
			myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
			motif=$(echo $first_num $sec_num | awk '{print $1 + $2}')
			echo -e ">"$strname"_["$mystr1"]"$first_num"_"$midstring0"_["$mystr2"]"$sec_num"_"$motif
			echo -e $myrepeat1$midstring1$myrepeat2
    		done<$strname"_temp" > $strname"_perm.fa"
    		rm -f $strname"_temp"
    	else
    		while read line; do
			first_num=$(echo $line |  awk '{print $2}')
			sec_num=$(echo $line |  awk '{print $NF}')
			myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
			myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
			motif=$(echo $first_num $sec_num | awk '{print $1 + $2}')
			echo -e ">"$strname"_["$mystr1"]"$first_num"_["$mystr2"]"$sec_num"_"$motif
			echo -e $myrepeat1$myrepeat2
    		done<$strname"_temp" | tr '[:lower:]' '[:upper:]' > $strname"_perm.fa"
    		rm -f $strname"_temp"
    	fi
}

## functions for bracket repeats = 3; [TCTA]8 [TCTG]2 [TCTA]4 / [TAGA]4 CAGA [TAGA]8 [CAGA]8
permutation_repeats_for_three () {
	bracket_repeats_string=$1
	middle=$2
	string_side=$3
	strname=$4
	## first repeats
	mystr1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $1}')
	mynum1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $2}')
	## second repeats
	if [[ $middle == "yes" ]] && [[ $string_side == "left" ]]; then
		mystr2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $4}')
		mynum2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
	else
		mystr2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
		mynum2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $4}')
	fi
	## thirds repeats
	if [[ $middle == "yes" ]]; then
		mystr3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $6}')
		mynum3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $NF}')
	else
		mystr3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
		mynum3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $NF}')
	fi
	## logic to handle if second number is greater than first (primary repeats)
	mynum1_start=$(($mynum1 - 5))
	## remove negative to 1
	if [[ $mynum1_start -le 0 ]]
	then
    		mynum1_start=2
	fi
	mynum2_start=$(($mynum2 - 5))
	## remove negative to 1
	if [[ $mynum2_start -le 0 || $mynum2_start -gt 1 ]]
	then
    		mynum2_start=1
	fi
	mynum3_start=$(($mynum3 - 5))
	## remove negative to 1
	if [[ $mynum3_start -le 0 || $mynum3_start -gt 1 ]]
	then
    		mynum3_start=1
	fi
	## now i added 5 to num2 if its bigger than num1
	if (( $mynum2 >= $mynum1 )); then
		sum2=$(( $mynum2 + 5))
		mynum1_end=$(($mynum1 + $sum2))
	elif (( $mynum3 >= $mynum1 )); then
		sum2=$(( $mynum3 + 5))
		mynum1_end=$(($mynum1 + $sum2))
	else
		mynum1_end=$(($mynum1 + 5))
	fi
	## repeats the string/bracket strings
	part_one=$(for (( c=$mynum1_start; c<=$mynum1_end; c++)); do echo -e $mystr1"\t"$c; done)
	lengthoffirst=$(printf "%s\n" "${part_one[@]}" | wc -l)
	part_two=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo -e $mystr2"\t"$mynum2_start; done)
	part_tree=$(for (( c=$mynum3_start; c<=$lengthoffirst; c++)); do echo -e $mystr3"\t"$mynum3_start; done)
	## print side by side
	if [[ $middle == "yes" ]] && [[ $string_side == "left" ]]; then
		midstring0=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
		midstring1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
		findN=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $1}')
		if [[ $findN == "N" ]]; then
			ntime=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $2}')
			midstring1=$(echo -e "ACGT" | fold -w1 | shuf -r -n $ntime | tr -d '\n')
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		else
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		fi
		paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${midstring[@]}") <(printf "%s\n" "${part_two[@]}") <(printf "%s\n" "${part_tree[@]}") > temp_list
	elif [[ $middle == "yes" ]] && [[ $string_side == "right" ]]; then
		midstring0=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
		midstring1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
		findN=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $1}')
		if [[ $findN == "N" ]]; then
			ntime=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $2}')
			midstring1=$(echo -e "ACGT" | fold -w1 | shuf -r -n $ntime | tr -d '\n')
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		else
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		fi
		paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${part_two[@]}") <(printf "%s\n" "${midstring[@]}") <(printf "%s\n" "${part_tree[@]}") > temp_list
	else
		paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${part_two[@]}") <(printf "%s\n" "${part_tree[@]}") > temp_list
	fi

	# print use fucntion to gene repeats
	if (( $mynum2 >= $mynum1 )); then
		n_times=$(( $mynum2 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	else
		gen_repeats temp_list 7 > $strname"_temp"
		rm -f temp_list
	fi
	## fasta work
	if [[ $middle == "yes" ]] && [[ $string_side == "left" ]]; then
		while read line; do
			first_num=$(echo $line |  awk '{print $2}')
			sec_num=$(echo $line |  awk '{print $5}')
			third_num=$(echo $line |  awk '{print $NF}')
			myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
			myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
			myrepeat3=$(printf -v spaces '%*s' $third_num ''; printf '%s\n' ${spaces// /$mystr3})
			motif=$(echo $first_num $sec_num $third_num | awk '{print $1 + $2 + $3}')
			echo -e ">"$strname"_["$mystr1"]"$first_num"_"$midstring0"_["$mystr2"]"$sec_num"_["$mystr3"]"$third_num"_"$motif
			echo -e $myrepeat1$midstring1$myrepeat2$myrepeat3
    		done<$strname"_temp" > $strname"_perm.fa"
    		rm -f $strname"_temp"
    	elif [[ $middle == "yes" ]] && [[ $string_side == "right" ]]; then
    		while read line; do
			first_num=$(echo $line |  awk '{print $2}')
			sec_num=$(echo $line |  awk '{print $4}')
			third_num=$(echo $line |  awk '{print $NF}')
			myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
			myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
			myrepeat3=$(printf -v spaces '%*s' $third_num ''; printf '%s\n' ${spaces// /$mystr3})
			motif=$(echo $first_num $sec_num $third_num | awk '{print $1 + $2 + $3}')
			echo -e ">"$strname"_["$mystr1"]"$first_num"_["$mystr2"]"$sec_num"_"$midstring0"_["$mystr3"]"$third_num"_"$motif
			echo -e $myrepeat1$myrepeat2$midstring1$myrepeat3
    		done<$strname"_temp" > $strname"_perm.fa"
    		rm -f $strname"_temp"
    	else
    		while read line; do
			first_num=$(echo $line |  awk '{print $2}')
			sec_num=$(echo $line |  awk '{print $4}')
			sec_num=$(echo $line |  awk '{print $NF}')
			myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
			myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
			myrepeat3=$(printf -v spaces '%*s' $third_num ''; printf '%s\n' ${spaces// /$mystr3})
			motif=$(echo $first_num $sec_num $third_num | awk '{print $1 + $2 + $3}')
			echo -e ">"$strname"_["$mystr1"]"$first_num"_["$mystr2"]"$sec_num"_["$mystr3"]"$third_num"_"$motif
			echo -e $myrepeat1$myrepeat2$myrepeat3
    		done<$strname"_temp" | tr '[:lower:]' '[:upper:]' > $strname"_perm.fa"
    		rm -f $strname"_temp"
    	fi
}

## functions for bracket repeats = 4; [TAGA]11 [TACA]2 [TAGA]2 [TACA]2 [TAGA]4
permutation_repeats_for_four () {
	bracket_repeats_string=$1
	middle=$2
	strname=$3
	## first repeats
	mystr1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $1}')
	mynum1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $2}')
	## second repeats
	mystr2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
	mynum2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $4}')
	## thirds repeats
	if [[  $middle == "yes" ]]; then
		mystr3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $6}')
		mynum3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $7}')
	else
		mystr3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
		mynum3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $6}')
	fi
	## four repeats
	if [[  $middle == "yes" ]]; then
		mystr4=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $8}')
		mynum4=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $NF}')
	else
		mystr4=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $7}')
		mynum4=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $NF}')
		mynum4_start=$(($mynum4 - 5))
	fi
	## logic to handle if second number is greater than first (primary repeats)
	mynum1_start=$(($mynum1 - 5))
	## remove negative to 1
	if [[ $mynum1_start -le 0 ]]
	then
    		mynum1_start=2
	fi
	mynum2_start=$(($mynum2 - 5))
	## remove negative to 1
	if [[ $mynum2_start -le 0 || $mynum2_start -gt 1 ]]
	then
    		mynum2_start=1
	fi
	mynum3_start=$(($mynum3 - 5))
	## remove negative to 1
	if [[ $mynum3_start -le 0 || $mynum3_start -gt 1 ]]
	then
    		mynum3_start=1
	fi
	mynum4_start=$(($mynum4 - 5))
	## remove negative to 1
	if [[ $mynum4_start -le 0 || $mynum4_start -gt 1 ]]
	then
    		mynum4_start=1
	fi
	## now i added 5 to num2 if its bigger than num1
	if (( $mynum2 >= $mynum1 )); then
		#echo "num2 is begger than num1"
		sum2=$(( $mynum2 + 5))
		mynum1_end=$(($mynum1 + $sum2))
		#echo $mynum1_end
	elif (( $mynum3 >= $mynum1 )); then
		#echo "num3 is begger than num1"
		sum2=$(( $mynum3 + 5))
		mynum1_end=$(($mynum1 + $sum2))
		#echo $mynum1_end
	elif (( $mynum4 >= $mynum1 )); then
		#echo "num4 is begger than num1"
		sum2=$(( $mynum4 + 5))
		mynum1_end=$(($mynum1 + $sum2))
		#echo $mynum1_end
	else
		mynum1_end=$(($mynum1 + 5))
		echo $mynum1_end
	fi

	## repeats the string/bracket strings
	part_one=$(for (( c=$mynum1_start; c<=$mynum1_end; c++)); do echo -e $mystr1"\t"$c; done)
	lengthoffirst=$(printf "%s\n" "${part_one[@]}" | wc -l)
	part_two=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo -e $mystr2"\t"$mynum2_start; done)
	part_three=$(for (( c=$mynum3_start; c<=$lengthoffirst; c++)); do echo -e $mystr3"\t"$mynum3_start; done)
	part_four=$(for (( c=$mynum4_start; c<=$lengthoffirst; c++)); do echo -e $mystr3"\t"$mynum4_start; done)
	## side by side
	if [[ $middle == "yes" ]]; then
		midstring0=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
		midstring1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
		findN=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $1}')
		if [[ $findN == "N" ]]; then
			ntime=$(echo $midstring1 | sed 's/N/N /g' | awk '{print $2}')
			midstring1=$(echo -e "ACGT" | fold -w1 | shuf -r -n $ntime | tr -d '\n')
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		else
			midstring=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo $midstring1; done)
		fi
		paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${part_two[@]}") <(printf "%s\n" "${midstring[@]}") <(printf "%s\n" "${part_three[@]}") <(printf "%s\n" "${part_four[@]}") > temp_list
	else
		paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${part_two[@]}") <(printf "%s\n" "${part_three[@]}") <(printf "%s\n" "${part_four[@]}") > temp_list
	fi

	# print use function to gene repeats
	if (( $mynum2 >= $mynum1 )); then
		#echo "num2 is begger than num1"
		n_times=$(( $mynum2 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	elif (( $mynum3 >= $mynum1 )); then
		#echo "num3 is begger than num1"
		n_times=$(( $mynum3 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	elif (( $mynum4 >= $mynum1 )); then
		#echo "num4 is begger than num1"
		n_times=$(( $mynum4 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	else
		gen_repeats temp_list 7 > $strname"_temp"
		rm -f temp_list
	fi
	## fasta work
	if [[ $middle == "yes" ]]; then
		while read line; do
			first_num=$(echo $line |  awk '{print $2}')
			sec_num=$(echo $line |  awk '{print $4}')
			third_num=$(echo $line |  awk '{print $7}')
			fourth_num=$(echo $line |  awk '{print $NF}')
			myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
			myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
			myrepeat3=$(printf -v spaces '%*s' $third_num ''; printf '%s\n' ${spaces// /$mystr3})
			myrepeat4=$(printf -v spaces '%*s' $fourth_num ''; printf '%s\n' ${spaces// /$mystr4})
			motif=$(echo $first_num $sec_num $third_num $fourth_num | awk '{print $1 + $2 + $3 + $4}')
			echo -e ">"$strname"_["$mystr1"]"$first_num"_["$mystr2"]"$sec_num"_"$midstring0"_["$mystr3"]"$third_num"_["$mystr4"]"$fourth_num"_"$motif
			echo -e $myrepeat1$myrepeat2$midstring1$myrepeat3$myrepeat4
    		done<$strname"_temp" > $strname"_perm.fa"
    		rm -f $strname"_temp"
    	else
    		while read line; do
			first_num=$(echo $line |  awk '{print $2}')
			sec_num=$(echo $line |  awk '{print $4}')
			third_num=$(echo $line |  awk '{print $6}')
			fourth_num=$(echo $line |  awk '{print $NF}')
			myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
			myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
			myrepeat3=$(printf -v spaces '%*s' $third_num ''; printf '%s\n' ${spaces// /$mystr3})
			myrepeat4=$(printf -v spaces '%*s' $fourth_num ''; printf '%s\n' ${spaces// /$mystr4})
			motif=$(echo $first_num $sec_num $third_num $fourth_num | awk '{print $1 + $2 + $3 + $4}')
			echo -e ">"$strname"_["$mystr1"]"$first_num"_["$mystr2"]"$sec_num"_["$mystr3"]"$third_num"_["$mystr4"]"$fourth_num"_"$motif
			echo -e $myrepeat1$myrepeat2$myrepeat3$myrepeat4
    		done<$strname"_temp" | tr '[:lower:]' '[:upper:]' > $strname"_perm.fa"
    		rm -f $strname"_temp"
    	fi
}


## functions for bracket repeats = 5; [TAGA]11 [TACA]2 [TAGA]2 [TACA]2 [TAGA]4
permutation_repeats_for_five () {
	bracket_repeats_string=$1
	strname=$2
	## first repeats
	mystr1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $1}')
	mynum1=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $2}')
	## second repeats
	mystr2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
	mynum2=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $4}')
	## thirds repeats
	mystr3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $5}')
	mynum3=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $6}')
	## four repeats
	mystr4=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $7}')
	mynum4=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $8}')
	## fifth repeats
	mystr5=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $9}')
	mynum5=$(cat $bracket_repeats_string | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $10}')
	## logic to handle if second number is greater than first (primary repeats)
	mynum1_start=$(($mynum1 - 5))
	## remove negative to 1
	if [[ $mynum1_start -le 0 ]]
	then
    		mynum1_start=2
	fi
	mynum2_start=$(($mynum2 - 5))
	## remove negative to 1
	if [[ $mynum2_start -le 0 || $mynum2_start -gt 1 ]]
	then
    		mynum2_start=1
	fi
	mynum3_start=$(($mynum3 - 5))
	## remove negative to 1
	if [[ $mynum3_start -le 0 || $mynum3_start -gt 1 ]]
	then
    		mynum3_start=1
	fi
	mynum4_start=$(($mynum4 - 5))
	## remove negative to 1
	if [[ $mynum4_start -le 0 || $mynum4_start -gt 1 ]]
	then
    		mynum4_start=1
	fi
	mynum5_start=$(($mynum5 - 5))
	## remove negative to 1
	if [[ $mynum5_start -le 0 || $mynum5_start -gt 1 ]]
	then
    		mynum5_start=1
	fi
	## now i added 5 to num2 if its bigger than num1
	if (( $mynum2 >= $mynum1 )); then
		sum2=$(( $mynum2 + 5))
		mynum1_end=$(($mynum1 + $sum2))
	elif (( $mynum3 >= $mynum1 )); then
		sum2=$(( $mynum3 + 5))
		mynum1_end=$(($mynum1 + $sum2))
	elif (( $mynum4 >= $mynum1 )); then
		sum2=$(( $mynum4 + 5))
		mynum1_end=$(($mynum1 + $sum2))
	elif (( $mynum5 >= $mynum1 )); then
		sum2=$(( $mynum5 + 5))
		mynum1_end=$(($mynum1 + $sum2))
	else
		mynum1_end=$(($mynum1 + 5))
	fi

	## repeats the string/bracket strings
	part_one=$(for (( c=$mynum1_start; c<=$mynum1_end; c++)); do echo -e $mystr1"\t"$c; done)
	lengthoffirst=$(printf "%s\n" "${part_one[@]}" | wc -l)
	part_two=$(for (( c=$mynum2_start; c<=$lengthoffirst; c++)); do echo -e $mystr2"\t"$mynum2_start; done)
	part_three=$(for (( c=$mynum3_start; c<=$lengthoffirst; c++)); do echo -e $mystr3"\t"$mynum3_start; done)
	part_four=$(for (( c=$mynum4_start; c<=$lengthoffirst; c++)); do echo -e $mystr3"\t"$mynum4_start; done)
	part_five=$(for (( c=$mynum5_start; c<=$lengthoffirst; c++)); do echo -e $mystr3"\t"$mynum5_start; done)
	## side by side
	paste <(printf "%s\n" "${part_one[@]}") <(printf "%s\n" "${part_two[@]}") <(printf "%s\n" "${part_three[@]}") \
	<(printf "%s\n" "${part_four[@]}") <(printf "%s\n" "${part_five[@]}") > temp_list

	# print use function to gene repeats
	if (( $mynum2 >= $mynum1 )); then
		#echo "num2 is begger than num1"
		n_times=$(( $mynum2 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	elif (( $mynum3 >= $mynum1 )); then
		#echo "num3 is begger than num1"
		n_times=$(( $mynum3 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	elif (( $mynum4 >= $mynum1 )); then
		#echo "num4 is begger than num1"
		n_times=$(( $mynum4 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	elif (( $mynum5 >= $mynum1 )); then
		#echo "num5 is begger than num1"
		n_times=$(( $mynum5 + 5))
		gen_repeats temp_list $n_times > $strname"_temp"
		rm -f temp_list
	else
		gen_repeats temp_list 7 > $strname"_temp"
		rm -f temp_list
	fi
## fasta work
while read line; do
	first_num=$(echo $line |  awk '{print $2}')
	sec_num=$(echo $line |  awk '{print $4}')
	third_num=$(echo $line |  awk '{print $6}')
	fourth_num=$(echo $line |  awk '{print $8}')
	fifth_num=$(echo $line |  awk '{print $NF}')
	myrepeat1=$(printf -v spaces '%*s' $first_num ''; printf '%s\n' ${spaces// /$mystr1})
	myrepeat2=$(printf -v spaces '%*s' $sec_num ''; printf '%s\n' ${spaces// /$mystr2})
	myrepeat3=$(printf -v spaces '%*s' $third_num ''; printf '%s\n' ${spaces// /$mystr3})
	myrepeat4=$(printf -v spaces '%*s' $fourth_num ''; printf '%s\n' ${spaces// /$mystr4})
	myrepeat5=$(printf -v spaces '%*s' $fifth_num ''; printf '%s\n' ${spaces// /$mystr5})
	motif=$(echo $first_num $sec_num $third_num $fourth_num $fifth_num | awk '{print $1 + $2 + $3 + $4 + $5}')
	echo -e ">"$strname"_["$mystr1"]"$first_num"_["$mystr2"]"$sec_num"_["$mystr3"]"$third_num"_["$mystr4"]"$fourth_num"_["$mystr5"]"$fifth_num"_"$motif
	echo -e $myrepeat1$myrepeat2$myrepeat3$myrepeat4$myrepeat5
done<$strname"_temp" > $strname"_perm.fa"
rm -f $strname"_temp"
}

################################### input runs here ###################################################

#^^^^^^^^^^^^^^^^^^^^^^^^^#
## case 1
#^^^^^^^^^^^^^^^^^^^^^^^^^#
if [[ $rep_count == 2 ]]; then
	echo -e "#Number of Repeats found:" $rep_count
	echo -e "#Working on permutation for bracket repeats:" `cat $repeat_string`
	permutation_repeats_for_two $repeat_string $string $strname
	#permutation_repeats_for_two $repeat_string $string > $strname"_final_list.txt"
	echo -e "#fasta generated."
	exit 0;
#^^^^^^^^^^^^^^^^^^^^^^^^^#
## case 2
#^^^^^^^^^^^^^^^^^^^^^^^^^#
elif [[ $rep_count == 1 ]]; then
	echo -e "#Number of Repeats found:" $rep_count
	echo -e "#Working on permutation for bracket repeat:" `cat $repeat_string`
	permutation_repeats_for_one $repeat_string $strname
	#permutation_repeats_for_one $repeat_string $strname > $strname"_list.txt"
	# for i in {1..5}; do
	# 	cat $strname"_list.txt" >> $strname"_final_list.txt"
	# done
	#rm -f $strname"_list.txt"
	## printf "`cat myone_list.txt`\n%.0s" {1..5} > $strname"_final_list.txt"
	## cat $strname"_list.txt"
	echo -e "#fasta generated."
	exit 0;
else
	echo -e "#Seems repeats are greater than 2, skipping.."
fi

#^^^^^^^^^^^^^^^^^^^^^^^^^#
## case 3
#^^^^^^^^^^^^^^^^^^^^^^^^^#
if [[ $rep_count == 3 ]]; then
	echo -e "#Number of Repeats found:" $rep_count
	echo -e "#Working on permutation for bracket repeats:" `cat $repeat_string`
	permutation_repeats_for_three $repeat_string $string $string_side $strname
	#permutation_repeats_for_three $repeat_string $string $string_side > $strname"_final_list.txt"
	echo -e "#fasta generated."
	exit 0;
else
	echo -e "#Seems repeats are greater than 3, skipping.."
fi

#^^^^^^^^^^^^^^^^^^^^^^^^^#
## case 4
#^^^^^^^^^^^^^^^^^^^^^^^^^#
if [[  $rep_count == 4 ]]; then
	echo -e "#Number of Repeats found:" $rep_count
	echo -e "#Working on permutation for bracket repeats:" `cat $repeat_string`
	permutation_repeats_for_four $repeat_string $string $strname
	#permutation_repeats_for_four $repeat_string $string > $strname"_final_list.txt"
	echo -e "#fasta generated."
	exit 0;
else
	echo -e "#Seems repeats are greater than 4, skipping.."
fi

#^^^^^^^^^^^^^^^^^^^^^^^^^#
## case 5
#^^^^^^^^^^^^^^^^^^^^^^^^^#
if [[  $rep_count == 5 ]]; then
	echo -e "#Number of Repeats found:" $rep_count
	echo -e "#Working on permutation for bracket repeats:" `cat $repeat_string`
	permutation_repeats_for_five $repeat_string $strname
	#permutation_repeats_for_five $repeat_string > $strname"_final_list.txt"
	echo -e "#fasta generated."
	exit 0;
else
	echo -e "#Seems repeats are greater than 5, skipping.."
fi

#########################################################################################################
