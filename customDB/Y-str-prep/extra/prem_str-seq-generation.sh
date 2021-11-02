#!/bin/bash

# # This file is part of forensic project


##input file
file="$1"
strname="$2"

print_USAGE()
{
echo -e "\n"
echo -e "#Please Provide a all input !!"
echo -e "\n"
echo -e "USAGE:
bash prem_str.sh <input motif repeats> <motif name>"
echo -e " bash prem_str.sh DYS19.txt DYS19"
echo -e "\n"
}
## check file input
if [[ $# != 2 ]]; then
        print_USAGE
        exit 0;
fi

################################################################ Program ######################################################################

echo -e "1. running permutation.."
while read line
do
        mystr1=$(echo $line | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $1}')
        mynum1=$(echo $line | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $2}')
        midstring=$(echo $line | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $3}')
        mystr2=$(echo $line | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $4}')
        mynum2=$(echo $line | tr '[' ' ' | tr ']' ' ' | sed -E 's/[0-9]+/& /g' | sed 's/^ //g' | awk '{print $NF}')
        myrepeat1=$(printf -v spaces '%*s' $mynum1 ''; printf '%s\n' ${spaces// /$mystr1})
        myrepeat2=$(printf -v spaces '%*s' $mynum2 ''; printf '%s\n' ${spaces// /$mystr2})
        motif=$(echo $mynum1 $mynum2 | awk '{print $1 + $2}')
	echo -e ">"$strname"_["$mystr1"]"$mynum1"_"$midstring"_["$mystr2"]"$mynum2"_"$motif
        echo -e $myrepeat1$midstring$myrepeat2
done < $file > $strname"_out_perm.fa"

if [[ -f $strname"_out_perm.fa" ]]; then
        echo -e "2. running reverse compliment.."
        bioawk -c fastx '{print ">"$name;print revcomp($seq)}' $strname"_out_perm.fa" | tr '[:lower:]' '[:upper:]' > $strname"_out_perm_rev.fa"
else
        echo -e "permuation output not found"
        exit 1;
fi


if [[ -f $strname"_out_perm_rev.fa" ]]; then
        echo -e "3. adding flanking regions 500bp.."
        left="TGTCACAGTAGGAATATTTTCAAATTGGTTTGCAAAGAATTTCAAAGTGTGTTTTAGACCATTACGGTGGCCATGCCTAATAATTACTTATTTTTATAAGTGCTGGATGGGTTTTACCCAACGTAATATCAGATACAGACTTTTAAGCTTGAAACCTGTGTCATAGCTCTGAACATTTGGTTGTATGTTGAAATAACTCTCAAGCAAAAATTGATTTTGAAATTAGCACTATAAATAAATTAAATAAATGAGGTAAAGTCATAAATATCTGCATGAAATGCTTATAAAGAGGTCAGCCTTAAAAATGTCATGAAGTCTAATATGCCACCCTTTTATTATTTCTACGGATATTACTTGGACTGGAAGACAAGGACTCAGGAATTTGCTGGTCAATCTCTGCACCTGGAAATAGTGGCTGGGGCACCAGGAGTAATACTTCGGGCCATGGCCATGTAGTGAGGACAAGGAGTCCATCTGGGTTAAGGAGAGTGTCACTATAT"
        right="AAACACTATATATATATAACACTATATATATAATACTATATATATATTAAAAAACACTATAACAGAAACTCAGTAGTCATAGTGAAATCAAAAAATAATCACAGTCAATTTGATCTCATACCTAGACTGAAATATGAAACTTCAAAAGAAAAGAATGTTAAGAACTTTGGGCTTGTCAAAATTTTCCTACATAGATAAAATTATTGGTGACTTTAACTCACTAGAAAACATAAACAAAAATCGATGTTTTGTATATGTGTAAATGAAAATATTTTTATTTCTATTAGTTATGACATGCAAACAAGTAATAAAGTGAAAGTACAATAATAAATAATAAAATTATATAAGGAAATTTATGTGTCAAAAAATTCCATTGAGACTATCAATTTTATAAAACTGTAGAGAATGCTTCATGAAACTACATTATACATTACTTTTTAGTATTTCACTTACATTTTAAATAATCAACAAATTAAAGGAAATTCTGAATCATTATTTCT"
        cat DYS19_out_perm_rev.fa | seqkit mutate -i 0:$left --quiet | seqkit mutate -i -1:$right --quiet > DYS19_out_perm_rev_flank.fa
else
        echo -e "perm_rev fasta not found"
        exit 1;
fi

rm -rf $strname"_out_perm.fa" $strname"_out_perm_rev.fa"

echo "All done"

