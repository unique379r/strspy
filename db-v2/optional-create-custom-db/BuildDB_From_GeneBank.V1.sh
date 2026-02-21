#!/bin/bash -x

#printf "\033c"
### bash $script -n genebank -f faNcbi -g $ref -r no -o Results

SECONDS=0
echo -e "#############################Utility Script for STRspy########################################"
echo -e "## This script aims to generate repeat fasta and bed file from genebank files (*.gb, *.fa)"
echo -e "## STR Project : https://www.ncbi.nlm.nih.gov/bioproject/380127"
echo -e "## Assembly :: GRCh38 (GCF_000001405)"
echo -e "##############################################################################################"

usage="[-h] [-n -f -g -r -o] #<-- Arguments

where:
	-h show the help
	-n genebank dir (*.gb)
	-f ncbi fasta dir (*.fa)
        -g genome fasta (hg38.fa)
	-r remove the temp dir (yes/no) [default: yes]
	-o results dir"

if [[ ( $@ == "--help" ) ||  $@ == "-h" ]]; then
	echo -e "\n"
  	echo "Usage: bash `basename $0` $usage"
  exit 0;
fi

if [[ $# -eq 0 ]]; then
        echo -e "\n"
        echo "#Error: No arguments provided"
        echo -e "\n"
        echo -e "bash `basename $0` [-h] -n (genebank dir) -f (ncbi fasta dir) -g genome fasta (hg38.fa) -r (remove temp dir[yes/no])> -o (results dir)"
        echo -e "\n"
        echo -e "Example: bash `basename $0` -n gbdir -f fadir -g hg38.fa -r no -o Results"
        echo -e "\n"
        echo -e "--> Get more help by --help/-h"
        echo -e "\n"
    exit 1;
fi

while getopts 'g:r:o:f:n:' option
do
    case "${option}" in
        n) genebank_dir=${OPTARG};;
	f) ncbifa_dir=${OPTARG};;
        g) genomeFa=${OPTARG};;
	r) deleteTemp=${OPTARG};;
	o) results_dir=${OPTARG};;
    esac
done

## setting default values if not assinged
if [[ -z "$deleteTemp" ]]
then
  	echo "Note: deleteTemp (-r) option is not opted; Setting default [yes] value for deleteTemp"
  	deleteTemp="yes"
fi

## CHECK IN-OUT AVAILABILITY

if [[ ! -d $genebank_dir ]]; then
	echo -e "\n"
	echo -e "#Error: Genebank dir (-s) does not exist"
	echo -e "\n"
	echo "Usage: bash `basename $0` $usage"
	exit 1;
fi

if [[ ! -d $ncbifa_dir ]]; then
	echo -e "\n"
	echo -e "#Error: NCBI fasta dir (-f) does not exist"
	echo -e "\n"
	echo "Usage: bash `basename $0` $usage"
	exit 1;
fi

if [[ ! -d $results_dir ]]; then
	echo -e "\n"
	echo -e "#Error: Results dir (-o) does not exist"
	echo -e "\n"
	echo "Usage: bash `basename $0` $usage"
	exit 1;
fi

echo -e "\n"
echo -e "###############Inputs#################"
echo -e "Input genebank dir =" $genebank_dir
echo -e "Input ncbi fasta dir =" $ncbifa_dir
echo -e "Input Genome Fa =" $genomeFa
echo -e "Remove temp dir =" $deleteTemp
echo -e "Results dir =" $results_dir
echo -e "#####################################"

############################################################START ANALYSIS#################################################
if which seqkit >/dev/null; then
        echo "#Seqkit found.."
else
        echo -e "#ERROR: #Required seqkit tool (https://bioinf.shenwei.me/seqkit/) to run this program"
        echo -e "Tip: You may need to activate => conda env strspy_env"
        exit 1;
fi

if which bedtools >/dev/null; then
        echo "#Bedtools found.."
else
        echo -e "#ERROR: #Required Bedtools (https://anaconda.org/bioconda/bedtools) to run this program"
        echo -e "Tip: You may need to activate => conda env strspy_env"
        exit 1;
fi

# make dir
mkdir -p $results_dir/NCBI2DB
mkdir -p $results_dir/NCBI2DB/tempDIR
cp -r $genebank_dir/*.gb $results_dir/NCBI2DB
cp -r $ncbifa_dir/*.fa $results_dir/NCBI2DB
cd $results_dir/NCBI2DB
rm -f *.tab *.rep

(

echo -e "##################################################"
echo -e "## 1. Create a tab file with all STR info from gb"
echo -e "##################################################"
makeTabRepTwoSTR () {
        local gbfile=$1
        grep 'Chromosome\|Chrom. Location\|Length-based allele\|STR locus name\|VERSION\|repeat_region\|Repeat Location' $gbfile | \
        sed 's/VERSION/VERSION\t::/' | sed 's/repeat_region/repeat_region \t ::/g' | sed 's/ //g' | tr '::' '\t' > "$gbfile".txt
        csplit -s -z "$gbfile".txt /VERSION/ '{*}' 2>/dev/null
        touch "all_rep_"$gbfile".tab"
        for i in x*
        do
                if [[ $gbfile == "DYS461-60.gb" ]]; then
                        awk '{print $2}' $i | tr '\n' '\t' | awk '{for(i=1;i<=NF-2;i++) printf $i"\t"; print "",$7","$8}' | \
                        awk '{$1=$1}1' OFS="\t" >> all_rep_"$gbfile".tab
                else
                        awk '{print $2}' $i | tr '\n' '\t' | awk '{for(i=1;i<=NF-2;i++) printf $i"\t"; print "",$8","$7}' | \
                        awk '{$1=$1}1' OFS="\t" >> all_rep_"$gbfile".tab
                fi
                rm -f $i
        done
        awk 'OFS="\t" {print $1,$2,$3,"bracket-skipped",$4,$5,$6,"NA",$7}' "all_rep_"$gbfile".tab" > tmp && \
        mv tmp "all_rep_"$gbfile".tab"
        awk -v OFS="\t" '{print $1, $(NF-1), $NF}' "all_rep_"$gbfile".tab" | sed 's/\.\./\:/g' | \
        sed 's/\,/\t/g' > "all_rep_"$gbfile".rep"
        echo -e "GenBankID\tLocus\tAlleleLength\tBracketedRepeat\tChromosome\tChromLocation\tRepeatLocation\tIndel\tRepeatRegion" \
                | cat - "all_rep_"$gbfile".tab" > tmp && yes | mv tmp "all_rep_"$gbfile".tab"
}
## only one STR within the locus
makeTabRep () {
        local gbfile=$1
        grep -w 'Chromosome\|STR locus name\|VERSION\|Chrom. Location\|Repeat Location\|repeat_region\|Bracketed repeat\|Length-based allele\|range bracket\|ISFG minimum range\|Chrom. location\|del\|ins\|Deletion\|Insertion\|deletion\|insertion' \
        $gbfile | sed "s/Length-based allele/Length-based-Allele/g" | grep -w -v 'allele\|reported\|of' \
        | sed "s/\/note\=\"del /Indel\t  :: /g" | sed 's/\/note\=\"+36 del /Indel\t  :: /g' | \
        sed 's/\/note\=\"-1 del /Indel\t  :: /g' | sed 's/"//g' | \
        sed 's/VERSION/VERSION\t::/g' | sed 's/repeat_region/repeat_region\t::/g' > $gbfile".txt"
        csplit -s -z $gbfile".txt" /VERSION/ '{*}' 2>/dev/null
        touch "all_rep_"$gbfile".tab"
        rm -f $gbfile".txt"
        for j in x*
        do
                linecount=$(cat $j | wc -l | sed 's/^ *//')
                if [[ $linecount == 7 ]]; 
                then
                        awk -F '::' '{print $2}' $j | sed 's/^ *//' | tr '\n' '\t' | cut -f1-7 | awk 'OFS="\t" {print $0, "NA", "missing" }' | sed 's/\;//g' >> "all_rep_"$gbfile".tab"
                elif [[ $linecount == 8 ]]; then
                        awk -F '::' '{print $2}' $j | sed 's/^ *//' | tr '\n' '\t' | cut -f1-8 | awk -F '\t' '{for(i=1;i<=NF-1;i++) printf $i"\t"; print "NA\t"$8}' \
                        | sed 's/\;//g' >> "all_rep_"$gbfile".tab"
                elif [[ $linecount == 9 ]]; then
                        sed "s/\/note\=/\/note\=    :: /g" $j | awk -F '::' '{print $2}' | sed 's/^ *//;s/\;//g' | tr '\n' '\t' | cut -f1-9 | sed 's/"//g' \
                        | sed 's/\<del\>//;s/\<ins\>//;s/\<Deletion\>//;s/\<Insertion\>//;s/\<deletion\>//;s/\/-//;s/\/+//;s/-\///;s/+\///g' \
                        | sed 's/Penta D/PentaD/;s/Penta E/PentaE/g' \
                        | awk -F '\t' -v OFS="\t" '{if ($NF ~ /^[a-zA-Z]/) {t=$(NF-1); $(NF-1)=$NF; $NF=t;print} else {print $0} }'  >> "all_rep_"$gbfile".tab"
                else
                        echo -e 'ERROR: split files has more 9 or less than 6.'
                        exit 1;
                fi
                rm -f $j
        done
        ## awk -v OFS='\t' '{$1=$1}1' make tab for every space or tab
        ## impute NA incase left somehow
        awk 'BEGIN { FS = OFS = "\t" } { for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = "NA" };1' "all_rep_"$gbfile".tab" > temp && mv temp "all_rep_"$gbfile".tab"
        #awk -F '\t' -v OFS="\t" 'NF==8 {$7=$7"\tNA"}1' "all_rep_"$gbfile".tab" > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167020.1" {sub(/missing/,"41..100"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167019.1" {sub(/missing/,"41..100"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167018.1" {sub(/missing/,"14..69"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167017.1" {sub(/missing/,"41..96"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167016.1" {sub(/missing/,"41..96"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167015.1" {sub(/missing/,"41..96"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167012.1" {sub(/missing/,"41..92"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167011.1" {sub(/missing/,"41..92"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167010.1" {sub(/missing/,"41..92"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        awk '$1 == "MH167009.1" {sub(/missing/,"41..92"); print}1' "all_rep_"$gbfile".tab" | sort -u > temp && mv temp "all_rep_"$gbfile".tab"
        ## extract three columns only ncbi id, locus and repeat_region
        awk -v OFS="\t" '{print $1, $(NF-1), $NF}' "all_rep_"$gbfile".tab" | sed 's/\.\./\:/g' > "all_rep_"$gbfile".rep"
        echo -e "GenBankID\tLocus\tAlleleLength\tBracketedRepeat\tChromosome\tChromLocation\tRepeatLocation\tIndel\tRepeatRegion" \
        | cat - "all_rep_"$gbfile".tab" > tmp && yes | mv tmp "all_rep_"$gbfile".tab"
}

## Autosome with/without indels
for i in *.gb
do      
        echo -e "working for:" $i
        if [[ $i == "DYS389I-II.gb" ]]; then
                makeTabRepTwoSTR $i
        elif [[ $i == "DYF387S1.gb" ]]; then
                makeTabRepTwoSTR $i
        elif [[ $i == "DYS461-60.gb" ]]; then
                makeTabRepTwoSTR $i
        else
                makeTabRep $i
        fi
done

## move temp files to dir
mv *.tab *.gb tempDIR

## phase one: keep aside the indels STR
## Autosome without indels
for i in *.rep
do      
        awk '$2!="NA"' $i > $i.filt_indels
        mv $i.filt_indels tempDIR
        awk '$2=="NA"' $i > temp && mv temp $i
done

echo -e "#Done"
echo -e "#######################################################"
echo -e "## 2. list of fasta and create directories for all loci"
echo -e "#######################################################"

ls *.fa | awk '{print $NF}' | sed 's/.fa//g' > listsample
while read line
do
        mkdir "$line"dir 
        mv *$line*.fa "$line"dir
        mv *$line*.rep "$line"dir
done<listsample
echo -e "#Done"

echo -e "########################"
echo -e "## 3. Format the header"
echo -e "########################"
echo -e "Correcting headers"
for i in *dir
do
        cd $i 
        faname=$(echo *.fa | sed 's/.fa//g')
        if [[ "$faname" == "DYS385ab" ]]; then
                sed "s/Homo sapiens microsatellite //;s/ FS//;s/ sequence//g" "$faname".fa | sed 's/ FS,PS//g' | \
                sed 's/ FS, PS//g' | sed 's/ FS//g' | sed 's/,PS//g' | sed "s/FS,_PS//g" | sed "s/GF,_PS//g" | \
                sed "s/PS//g" | sed 's/Penta D/PentaD/g' | sed 's/Penta E/PentaE/g' | sed "s/FS,_//g" | sed "s/,_GF,//g" | \
                sed "s/ GF//g" | sed "s/ FS,GF,PS//g" | sed "s/_-94G_A//g" | sed "s/\"FS, PS\"//g" | \
                awk '{third = $4; $4=""; print $0,third}' | sed 's/ /_/g' | sed 's/___//g' | sed 's/__/_/g' | \
                sed "s/,,//g" | sed "s/,,,//g" | sed "s/,//g" | sed "s/\_\-107C_AGF//g" | sed "s/_\"FS_\"//g" | \
                sed "s/GF//g" | sed 's/_$//' | sed 's/ss.*_//g' > "$faname".corr.fa
        elif [[ "$faname" == "DYS389I-II" ]]; then
                sed "s/Homo sapiens microsatellite //;s/ FS//;s/ sequence//g" "$faname".fa | sed 's/ FS,PS//g' | \
                sed 's/ FS, PS//g' | sed 's/ FS//g' | sed 's/,PS//g' | sed "s/FS,_PS//g" | sed "s/GF,_PS//g" | \
                sed "s/PS//g"| sed 's/Penta D/PentaD/g' | sed 's/Penta E/PentaE/g' | sed "s/FS,_//g" | \
                sed "s/,_GF,//g" | sed "s/ GF//g" | sed "s/ FS,GF,PS//g" | sed "s/_-94G_A//g" | sed "s/\"FS, PS\"//g" | \
                sed 's/_rs.*_/ /g'| sed 's/_ss.* / /g' | sed 's/_ss.*_/ /g' | sed 's/ss.*/ /g' | sed 's/ *.$//g' | \
                sed 's/DYS389 I/DYS389I/g' | sed 's/DYS389 II/DYS389II/g'  | awk -F ' ' 'OFS="_" {print $1,$2,$6,$7,$4}' | \
                sed 's/,//g' | sed 's/\____//g' > DYS389I.corr.fa

                sed "s/Homo sapiens microsatellite //;s/ FS//;s/ sequence//g" "$faname".fa | \
                sed 's/ FS,PS//g' | sed 's/ FS, PS//g' | sed 's/ FS//g' | sed 's/,PS//g' | sed "s/FS,_PS//g" | \
                sed "s/GF,_PS//g" | sed "s/PS//g"| sed 's/Penta D/PentaD/g' | sed 's/Penta E/PentaE/g' | sed "s/FS,_//g" | \
                sed "s/,_GF,//g" | sed "s/ GF//g" | sed "s/ FS,GF,PS//g" | sed "s/_-94G_A//g" | sed "s/\"FS, PS\"//g" | \
                sed 's/_rs.*_/ /g'| sed 's/_ss.* / /g' | sed 's/_ss.*_/ /g' | sed 's/ss.*/ /g' | sed 's/ *.$//g' | \
                sed 's/DYS389 I/DYS389I/g' | sed 's/DYS389 II/DYS389II/g'  | \
                awk -F ' ' 'OFS="_" {print $1,$3,$8,$9,$10,$11,$12,$13,$5}' | \
                sed 's/,//g' | sed 's/\_______//g' | sed 's/__/_/g' | sed 's/_$//' > DYS389II.corr.fa
        elif [[ "$faname" == "DYS461-60" ]]; then
                sed "s/Homo sapiens microsatellite //;s/ FS//;s/ sequence//g" "$faname".fa | sed 's/ FS,PS//g' | \
                sed 's/ FS, PS//g' | sed 's/ FS//g' | sed 's/,PS//g' | sed "s/FS,_PS//g" | \
                sed "s/GF,_PS//g" | sed "s/PS//g"| sed 's/Penta D/PentaD/g' | sed 's/Penta E/PentaE/g' | \
                sed "s/FS,_//g" | sed "s/,_GF,//g" | sed "s/ GF//g" | sed "s/ FS,GF,PS//g" | sed "s/_-94G_A//g" | \
                sed "s/\"FS, PS\"//g" | sed 's/_rs.*_/ /g'| sed 's/_ss.* / /g' | sed 's/_ss.*_/ /g' | \
                sed 's/ss.*/ /g' | sed 's/\,//g' | awk -F ' ' 'OFS="_" {print $1,$3,$8,$9,$5}' | \
                sed 's/\____//g' | sed 's/__/_/g' > DYS460.corr.fa

                sed "s/Homo sapiens microsatellite //;s/ FS//;s/ sequence//g" "$faname".fa | sed 's/ FS,PS//g' | \
                sed 's/ FS, PS//g' | sed 's/ FS//g' | sed 's/,PS//g' | sed "s/FS,_PS//g" | sed "s/GF,_PS//g" | \
                sed "s/PS//g"| sed 's/Penta D/PentaD/g' | sed 's/Penta E/PentaE/g' | sed "s/FS,_//g" | sed "s/,_GF,//g" | \
                sed "s/ GF//g" | sed "s/ FS,GF,PS//g" | sed "s/_-94G_A//g" | sed "s/\"FS, PS\"//g" | sed 's/_rs.*_/ /g'| \
                sed 's/_ss.* / /g' | sed 's/_ss.*_/ /g' | sed 's/ss.*/ /g' | sed 's/\,//g' | \
                awk -F ' ' 'OFS="_" {print $1,$2,$6,$7,$4}' | sed 's/\____//g' | sed 's/__/_/g' > DYS461.corr.fa

        else
                sed "s/Homo sapiens microsatellite //;s/ FS//;s/ sequence//g" "$faname".fa | sed 's/ FS,PS//g' \
                | sed 's/ FS, PS//g' | sed 's/ FS//g' | sed 's/,PS//g' | sed "s/FS,_PS//g" | sed "s/GF,_PS//g" | sed "s/PS//g" \
                | sed 's/Penta D/PentaD/g' | sed 's/Penta E/PentaE/g' | sed "s/FS,_//g" | sed "s/,_GF,//g" | sed "s/ GF//g" \
                | sed "s/ FS,GF,PS//g" | sed "s/_-94G_A//g" | sed "s/\"FS, PS\"//g" | awk '{third = $3; $3=""; print $0,third}' \
                | sed 's/ /_/g' | sed 's/___//g' | sed 's/__/_/g' | sed "s/,,//g" | sed "s/,,,//g" | sed "s/,//g" \
                | sed "s/\_\-107C_AGF//g" | sed "s/_\"FS_\"//g" | sed "s/GF//g" | sed 's/ _+4A_G//g' | sed 's/_+4A_G//g' > "$faname".corr.fa
        fi
        cd ..
done
echo "#Done"
echo -e "############################################################################"
echo -e "## 4. split ncbi multifasta to single fasta of each repeats within the locus"
echo -e "############################################################################"
while read line
do
        cd "$line"dir
        for i in *.corr.fa
        do
                faname=$(echo $i | sed 's/.fa//g')
                if [[ "$faname" == "DYS389I.corr" ]]; then
                        mkdir -p singleLineFa1
                        seqkit split2 --by-size 1 $i -O singleLineFa1
                elif [[ "$faname" == "DYS389II.corr" ]]; then
                        mkdir -p singleLineFa2
                        seqkit split2 --by-size 1 $i -O singleLineFa2
                elif [[ "$faname" == "DYS460.corr"  ]]; then
                        mkdir -p singleLineFa1
                        seqkit split2 --by-size 1 $i -O singleLineFa1
                elif [[ "$faname" == "DYS461.corr" ]]; then
                        mkdir -p singleLineFa2
                        seqkit split2 --by-size 1 $i -O singleLineFa2
                else
                        mkdir -p singleLineFa
                        seqkit split2 --by-size 1 $i -O singleLineFa
                fi
        done
        cd ..
done<listsample
echo -e "#Done"

# echo -e "#######################################"
# echo -e "## 5. extract repeats from NCBI fasta"
# echo -e "#######################################"
extractRepeats () {
        local singleLineFaDir=$1
        local repList=$2
        local filename=$3
        for i in $singleLineFaDir/*.fa
        do
                fa_id=$(grep '^>' $i | awk -F '_' '{print $1}' | sed 's/>//g')
                #echo -e "fasta id" $fa_id
                while read Line
                do
                #echo -e "rep line" $Line
                gb_id=$(echo $Line| awk '{print $1}')
                #echo -e "gb_id" $gb_id
                num=$(echo $Line| awk '{print $3}')
                if [[ "$fa_id" == "$gb_id" ]]; then
                        echo -e "Match Found"
                        if [[ "$filename" == "DYS389II" ]]; then
                                num2=$(echo $Line | awk '{print $4}')
                                seqkit subseq -r "$num2" $i >> "$filename"_repeats.fasta
                                echo -e "done"
                        elif [[ "$faname" == "DYS460.corr" ]]; then
                                num2=$(echo $Line | awk '{print $4}')
                                seqkit subseq -r "$num2" $i >> "$filename"_repeats.fasta
                                echo -e "done"
                        else
                                seqkit subseq -r "$num" $i >> "$filename"_repeats.fasta
                                echo -e "done"
                        fi
                fi
                done<$repList
        done
}

## conditional loop for DYS389I-II or normal any STR
while read line
do
        cd "$line"dir
        for i in *.corr.fa
        do
                echo -e "Extracting repeats fasta:" $i
                faname=$(echo $i | sed 's/.corr.fa//g')
                if [[ $faname == "DYS389I" ]]; then
                        extractRepeats singleLineFa1 all_rep_DYS389I-II.gb.rep $faname
                elif [[ $faname == "DYS389II" ]]; then
                        extractRepeats singleLineFa2 all_rep_DYS389I-II.gb.rep $faname
                elif [[ $faname == "DYS460" ]]; then
                        extractRepeats singleLineFa1 all_rep_DYS461-60.gb.rep $faname
                elif [[ $faname == "DYS461" ]]; then
                        extractRepeats singleLineFa2 all_rep_DYS461-60.gb.rep $faname
                else
                        extractRepeats singleLineFa all_rep_"$faname".gb.rep $faname
                fi
        done
        cd ..
done<listsample

echo -e "####################################################"
echo -e "## 6. deduplicate (by seq) ncbi fasta and rep file"
echo -e "####################################################"
######### NOTE: removing dup by seq has issues as once repeat seq are same will be removed also this will remove if there is 
######### differences in flanking region by SNP. Note sure if this will solve by xATLAS or any other prediction tool.
while read line
do
        cd "$line"dir
        for i in *_repeats.fasta
        do
                faname=$(echo $i | sed 's/_repeats.fasta//g')
                echo -e "final header corrections"
                sed 's/_rs.*_/ /g' $i | sed 's/_ss.* / /g' | sed 's/_ss.*_/ /g' | sed 's/ /_/g' \
                > tmp && mv tmp "$faname"_repeats.fasta
                echo -e "remove duplicated entry by seq similarity"
                seqkit rmdup -w 0 -s -i -o "$faname"_repeats_clean.fasta -d "$faname"_duplicated.fa -D "$faname"_duplicated.id "$faname"_repeats.fasta
        done
        cd ..
done<listsample
echo -e "#Done"

# # # #### ^^^no use^^^ ####

# # # # echo -e "###############################################################################################"
# # # # echo -e "## 6. putting back indels of flanking regions fa seq which might have been filtered as dup"
# # # # echo -e "################################################################################################"
# # # # while read line
# # # # do
# # # #         cd "$line"dir
# # # #         awk '$(NF-1)!="NA"' ../tempDIR/all_rep_"$line".gb.rep | grep -v 'GenBankID' | cut -f1 > "$line".indel
# # # #         if [[ -s "$line".indel ]]; then
# # # #                 ## get the indel fasta
# # # #                 seqkit grep -r -f "$line".indel "$line"_duplicated.fa -o "$line".indel.fa
# # # #                 ## merge back to clean set
# # # #                 cat "$line"_repeats_clean.fasta "$line".indel.fa > temp && mv temp "$line"_repeats_clean.fasta
# # # #                 rm -f temp
# # # #         else
# # # #                 ## delete the empty
# # # #                 rm -f "$line".indel
# # # #         fi
# # # #         cd ..
# # # # done<listsample
# # # # echo -e "#Done"

# # # #### ^^^no use^^^ ###

## temp files
mv *dir/*.rep tempDIR/
mv -f listsample tempDIR/

echo -e "Making full fasta (repeat + 500 flanking region) and repeat bed.."
cd tempDIR/
echo -e "tab to bed"
for i in *.gb.tab
do
        name=$(echo $i | sed 's/all_rep_//g' | sed 's/.gb.tab//g')
        if [[ "$name" == "DYS385ab" ]]; then
                echo -e "Y\t18639713\t18639780\tDYS385b" > "DYS385b.bed"
                echo -e "Y\t18680608\t18680687\tDYS385a" > "DYS385a.bed"
        elif [[ "$name" == "DYS389I-II" ]]; then
                cor1=$(sed '1d' $i | cut -f7 | sort -u | awk -F ',' '{print $1}' | tr '..' '\t')
                cor2=$(sed '1d' $i | cut -f7 | sort -u | awk -F ',' '{print $2}' | tr '..' '\t')
                chr=$(sed '1d' $i | cut -f5 | sort -u)
                echo -e $chr"\t"$cor1"\tDYS389I" > DYS389I.bed
                echo -e $chr"\t"$cor2"\tDYS389II" > DYS389II.bed
        elif [[ $name == "DYF387S1" ]]; then
                cor1=$(sed '1d' $i | cut -f7 | sort -u | awk -F ',' '{print $1}' | tr '..' '\t')
                chr=$(sed '1d' $i | cut -f5 | sort -u)
                echo -e $chr"\t"$cor1"\t"$name > "$name".bed
        elif [[ $name == "DYS461-60" ]]; then
                cor1=$(sed '1d' $i | cut -f7 | sort -u | awk -F ',' '{print $1}' | tr '..' '\t')
                cor2=$(sed '1d' $i | cut -f7 | sort -u | awk -F ',' '{print $2}' | tr '..' '\t')
                chr=$(sed '1d' $i | cut -f5 | sort -u)
                echo -e $chr"\t"$cor1"\tDYS461" > DYS461.bed
                echo -e $chr"\t"$cor2"\tDYS460" > DYS460.bed
        else
                cor=$(sed '1d' $i | cut -f7 | sort -u | tr '..' '\t')
                chr=$(sed '1d' $i | cut -f5 | sort -u)
                echo -e $chr"\t"$cor"\t"$name > "$name".bed
        fi
done

#echo -e "corrections"
#rm -rf D5S818.bed ## need to take a look
if [[ -f "vWA.bed" ]]; then
        ## all of the STRs belongs to chr12 but one OK330027.1 has at chr13, why ? who knows !
        awk -v OFS="\t" '{print $1,$3,$4,$5}' vWA.bed > temp && mv temp vWA.bed
fi

if [[ -f "TPOX.bed" ]]; then
        #grep 'TPOX' TPOX.bed | awk '{print "2\t"$0}' > temp && mv temp TPOX.bed
        awk -v OFS="\t" '{print $1,$4,$5,$6}' TPOX.bed > temp && mv temp TPOX.bed
fi

#echo -e "correct space and extend 1 base left + add chr"
for i in *.bed
do
        awk -v OFS="\t" '{print "chr"$1,$2-1,$3,$4}' $i > temp && mv temp $i
done

#echo -e "add 500 to left and 500 to right)"
for i in *.bed
do
    bedname=$(echo $i | sed 's/.bed//g')
    awk -v OFS="\t" '{print $1,$2-500,$3+500,$4}' $i > "$bedname".500bp.bed
done

#echo -e "convert bed to fasta"
for i in *.500bp.bed
do
     bedname=$(echo $i | sed 's/.bed//g')
     bedtools getfasta -fi $genomeFa -bed $i -name > "$bedname".fasta
done

# #echo -e "get the left and right 500 bases"
for i in *.fasta
do
    seqkit subseq $i -r 1:500 -w 0 | seqkit fx2tab > $i.left
    seqkit subseq $i -r -500:-1 -w 0 | seqkit fx2tab > $i.right
done

#echo -e "part one done"
for i in *.left
do
        leftstr=$(basename $i .left)
        for j in *.right
        do
                rightstr=$(basename $j .right)
                if [[ $leftstr == $rightstr ]]; then
                        echo -e "working for:" $leftstr $rightstr
                        join <(sort $i) <(sort $j) > "$leftstr".flanks
                        echo -e "done"
                fi
        done
done

mkdir -p rough
mv *.right *.left rough
mv *.500bp.bed rough
mv *.fai rough
mv *.fasta rough

#echo -e "make fasta of only repeats"
for i in *.bed
do
        bedname=$(echo $i | sed 's/.bed//g')
        bedtools getfasta -fi $genomeFa -bed $i -name > $bedname.repeats.fa
done
#echo -e "fasta to tab"
for i in *.repeats.fa
do
        seqkit fx2tab $i > $i.tab
done

#echo -e "full ncbi co-ordinates + 500bp, seq of co-ordinates from genome, genomic flanking left and right"
for i in *.repeats.fa.tab
do
        tab=$(basename $i .repeats.fa.tab)
        repeats=$(cat $i | awk '{print $2}')
        for j in *.flanks
        do
                flank=$(basename $j .500bp.fasta.flanks)
                if [[ $tab == $flank ]]; then
                        echo -e "working for:" $tab $flank
                        echo -e `cat $j` $repeats > "$tab".full.flank
                        echo -e "done"
                fi
        done
done

mv *.tab rough
mv *.repeats.fa rough
mv *.flanks rough
cat *.flank > All.flnaks
mv *.flank rough
cp -r ../*dir/*_repeats_clean.fasta .

# #echo -e "part two done"

echo -e "bind the flanking regions in the repeat we extracted form gb and ncbi fa"

if [[ -f DYS385ab_repeats_clean.fasta ]]; then
        cp DYS385ab_repeats_clean.fasta DYS385b_repeats_clean.fasta
        sed "s/\_a\/b\_/b\_/g" DYS385b_repeats_clean.fasta | sed "s/\_b/b/g" > temp && mv temp DYS385b_repeats_clean.fasta
        mv DYS385ab_repeats_clean.fasta DYS385a_repeats_clean.fasta
        sed "s/\_a\/b\_/a\_/g" DYS385a_repeats_clean.fasta | awk '!/_b_/' RS=">" ORS=">" > temp && mv temp DYS385a_repeats_clean.fasta
fi

declare -a arr=(*repeats_clean.fasta)
for i in "${arr[@]}"
do
   echo "$i"
   falocus=$(basename $i _repeats_clean.fasta)
   while read line 
   do
        locus=$(echo $line | awk -F "::" '{print $1}')
        left=$(echo $line | awk -F " " '{print $2}')
        right=$(echo $line | awk -F " " '{print $3}')
        if [[ "$falocus" == "$locus" ]]; then
                echo "match found:" "$falocus" "$locus"
                cat "$i" | seqkit mutate -i 0:$left --quiet | seqkit mutate -i -1:$right --quiet > $locus"_finalDB.fa"
        fi
   done <All.flnaks
done
mkdir -p ../finalDB
mv *_finalDB.fa ../finalDB
mv *.bed ../finalDB

# #echo -e "part third done"
cd ..
## delete temp file 
if [[ $deleteTemp == "yes" ]] || [[ $deleteTemp == "Yes" ]]; then
        rm -rf tempDIR/
        rm -rf *dir/singleLineFa*
        echo -e "#temp dir deleted"
fi

cd ..
# datetimestamp=$(date +"%F+%H:%M:%S")
# logfile="log-"$datetimestamp".log"

) 2>&1 | tee -a logfile.txt
echo -e "###################################################"
echo -e "\nAnalysis done\n"
echo -e "\nCheck the output in:" $results_dir/NCBI2DB/finalDB 
echo -e "###################################################"
duration=$SECONDS
echo -e "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed.\n"

