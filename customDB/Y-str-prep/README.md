# This utlility script is used to create chr Y STR database (DB)

## Step 1 [Generate a fasta based on permutation]

Just keep in mind that the out fasta will not have flanking regions (500bp) or reverse compliment the sequences

### single repeats only
```
USAGE:

bash ./Proj-Forensic-ChrY-perm-repeat-script_final_v4_outFA.sh <input motif repeats> <motif name> <string_avaible(yes/no) <string_side(left/right/NA)>

EXAMPLE: bash ./Proj-Forensic-ChrY-perm-repeat-script_final_v4_outFA.sh DYS19.txt DYS19 yes left

```

### batch lists of repeats

```
while read line
do
        locus=$(echo $line | cut -f1)
        string=$(echo $line | awk '{print $(NF-2)}')
        string_side=$(echo $line | awk '{print $(NF-1)}')
        sample=$(echo $line | awk '{print $NF}')
        motif=$(echo $line | awk -F"\t" '{print $3}')
        echo $line | awk -F"\t" '{print $3}' > motif_file
        echo -e "Working for:" $locus "("$motif")" $string $string_side $sample
        bash Proj-Forensic-ChrY-perm-repeat-script_final_v4_outFA.sh motif_file $locus $string $string_side
        rm -f motif_file
done <test_input.txt > logs

```

Note: N42 type of bases between the motifs will just randomize by ACGT and will be added to out fasta


## Step 2 [Concatenate flanking regions or optionally, reverse compliment the entire fasta sequences]

`conda install -c bioconda seqkit`

Note: Pre-computed left and right 500 bases are prepared from reference chrY

```
declare -a arr=(*.fa)   ## output fasta (permutation based fasta) from step 1

for i in "${arr[@]}"
do
   echo "$i"
   falocus=$(echo "$i" | awk -F"_" '{print $1}')
   while read line
        do
                locus=$(echo $line | awk '{print $1}')
                left=$(echo $line | awk '{print $4}')
                right=$(echo $line | awk '{print $5}')
                if [[ "$falocus" == "$locus" ]]; then
                        echo "match found"
                        cat "$i" | seqkit mutate -i 0:$left --quiet | seqkit mutate -i -1:$right --quiet > $locus"_"$falocus"_out_perm_flank.fa"
                fi
        done<left-right500.tab.txt
done

```


## Step 3 [Used these prepared DB to run the original STRspy]


## Contacts for any feedback or comment
bioinforupesh200 DOT au AT gmail DOT com

rupesh DOT kesharwani AT bcm DOT edu

