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
echo -e "\n"

############################################################START ANALYSIS#################################################
if which seqkit >/dev/null; then
        echo "#Seqkit found.."
else
        echo -e "#ERROR: #Required seqkit tool (https://bioinf.shenwei.me/seqkit/) to run this program"
        echo -e "Tip: You may need to activate conda activate strspy_env"
        exit 1;
fi

if which bedtools >/dev/null; then
        echo "#Bedtools found.."
else
        echo -e "#ERROR: #Required Bedtools (https://anaconda.org/bioconda/bedtools) to run this program"
        echo -e "Tip: You may need to activate conda activate strspy_env"
        exit 1;
fi

## make dir
mkdir -p $results_dir/NCBI2DB
mkdir -p $results_dir/NCBI2DB/tempDIR
cp -r $genebank_dir/*.gb $results_dir/NCBI2DB
cp -r $ncbifa_dir/*.fa $results_dir/NCBI2DB
cd $results_dir/NCBI2DB
rm -f *.tab *.rep

##((

echo -e "##################################################"
echo -e "## 1. Create a tab file with all STR info from gb"
echo -e "##################################################"
makeTabRep () {
        local gbfile=$1
        grep -w 'Chromosome\|STR locus name\|VERSION\|Chrom. Location\|Repeat Location\|repeat_region\|Bracketed repeat\|Length-based allele\|range bracket\|ISFG minimum range\|Chrom. location\|del\|ins\|Deletion\|Insertion\|deletion\|insertion' \
        $gbfile | sed "s/Length-based allele/Length-based-Allele/g" | grep -w -v 'allele\|reported\|of' \
        | sed "s/\/note\=\"del /Indel\t  :: /g" | sed 's/VERSION/VERSION\t::/g' | sed 's/repeat_region/repeat_region\t::/g' > $gbfile".txt"
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
        ## extract three columns only ncbi id, locus and repeat_region
        awk -v OFS="\t" '{print $1, $(NF-1), $NF}' "all_rep_"$gbfile".tab" | sed 's/\.\./\:/g' > "all_rep_"$gbfile".rep"
        echo -e "GenBankID\tLocus\tAlleleLength\tBracketedRepeat\tChromosome\tChromLocation\tRepeatLocation\tIndel\tRepeatRegion" \
        | cat - "all_rep_"$gbfile".tab" > tmp && yes | mv tmp "all_rep_"$gbfile".tab"
}

## Autosome with/without indels
for i in *.gb
do      
        echo -e "working for:" $i
        makeTabRep $i
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
        sed "s/Homo sapiens microsatellite //;s/ FS//;s/ sequence//g" "$faname".fa | sed 's/ FS,PS//g' \
        | sed 's/ FS, PS//g' | sed 's/ FS//g' | sed 's/,PS//g' | sed "s/FS,_PS//g" | sed "s/GF,_PS//g" | sed "s/PS//g" \
        | sed 's/Penta D/PentaD/g' | sed 's/Penta E/PentaE/g' | sed "s/FS,_//g" | sed "s/,_GF,//g" | sed "s/ GF//g" \
        | sed "s/ FS,GF,PS//g" | sed "s/_-94G_A//g" | sed "s/\"FS, PS\"//g" | awk '{third = $3; $3=""; print $0,third}' \
        | sed 's/ /_/g' | sed 's/___//g' | sed 's/__/_/g' | sed "s/,,//g" | sed "s/,,,//g" | sed "s/,//g" \
        | sed "s/\_\-107C_AGF//g" | sed "s/_\"FS_\"//g" | sed "s/GF//g" > temp && mv temp "$faname".fa
        cd ..
done
echo "#Done"
echo -e "############################################################################"
echo -e "## 4. split ncbi multifasta to single fasta of each repeats within the locus"
echo -e "############################################################################"

while read line
do
        cd "$line"dir
        mkdir -p singleLineFa
        faname=$(echo *.fa | sed 's/.fa//g')
        seqkit split2 --by-size 1 $faname.fa -O singleLineFa
        cd ..
done<listsample
echo -e "#Done"

echo -e "#######################################"
echo -e "## 5. extract repeats from NCBI fasta"
echo -e "#######################################"
while read line
do
        cd "$line"dir
        faname=$(echo *.fa | sed 's/.fa//g')
        for i in singleLineFa/*.fa
        do
                fa_id=$(grep '^>' $i | awk -F '_' '{print $1}' | sed 's/>//g')
                #echo -e "fasta id" $fa_id
                while read Line
                do
                        #echo -e "rep line" $Line
                        gb_id=$(echo $Line| awk '{print $1}')
                        #echo -e "gb_id" $gb_id
                        num=$(echo $Line| awk '{print $3}')
                        if [[ $fa_id == $gb_id ]]; then
                                echo -e "Match Found"
                                seqkit subseq -r "$num" $i >> "$faname"_repeats.fasta
                                echo -e "done"
                        fi
                done<all_rep_"$faname".gb.rep
        done
        cd ..
done<listsample
echo -e "#Done"

echo -e "###############################################################################################"
echo -e "## 6. deduplicate (by seq) ncbi fasta and rep file"
echo -e "################################################################################################"
while read line
do
        cd "$line"dir
        faname=$(echo *_repeats.fasta | sed 's/_repeats.fasta//g')
        echo -e "final header corrections"
        sed 's/_rs.*_/ /g' "$faname"_repeats.fasta | sed 's/_ss.* / /g' | sed 's/_ss.*_/ /g' | sed 's/ /_/g' \
        > tmp && mv tmp "$faname"_repeats.fasta
        echo -e "remove duplicated entry by seq similarity"
        seqkit rmdup -w 0 -s -i -o "$faname"_repeats_clean.fasta -d "$faname"_duplicated.fa -D "$faname"_duplicated.id "$faname"_repeats.fasta
        cd ..
done<listsample
echo -e "#Done"

# echo -e "###############################################################################################"
# echo -e "## 6. putting back indels of flanking regions fa seq which might have been filtered as dup"
# echo -e "################################################################################################"
# while read line
# do
#         cd "$line"dir
#         awk '$(NF-1)!="NA"' ../tempDIR/all_rep_"$line".gb.rep | grep -v 'GenBankID' | cut -f1 > "$line".indel
#         if [[ -s "$line".indel ]]; then
#                 ## get the indel fasta
#                 seqkit grep -r -f "$line".indel "$line"_duplicated.fa -o "$line".indel.fa
#                 ## merge back to clean set
#                 cat "$line"_repeats_clean.fasta "$line".indel.fa > temp && mv temp "$line"_repeats_clean.fasta
#                 rm -f temp
#         else
#                 ## delete the empty
#                 rm -f "$line".indel
#         fi
#         cd ..
# done<listsample
# echo -e "#Done"

## temp files
rm -rf *dir/singleLineFa
mv *dir/*.rep tempDIR/
#mv *dir/*.{rep,fa,id} tempDIR/
#mv *dir/*_repeats.fasta tempDIR/
mv -f listsample tempDIR/

echo -e "Making full fasta (repeat + 500 flanking region) and repeat bed.."
cd tempDIR/
## tab to bed
for i in *.gb.tab
do
        name=$(echo $i | sed 's/all_rep_//g' | sed 's/.gb.tab//g')
        cor=$(sed '1d' $i | cut -f7 | sort -u | tr '..' '\t')
        chr=$(sed '1d' $i | cut -f5 | sort -u)
        echo -e $chr"\t"$cor"\t"$name > $name.bed
done

# corrections
#rm -rf D5S818.bed ## need to take a look
if [[ -f vWA.bed ]]; then
        ## all of the STRs belongs to chr12 but one OK330027.1 has at chr13, why ? who knows !
        awk -v OFS="\t" '{print $1,$3,$4,$5}' vWA.bed > temp && mv temp vWA.bed
fi

if [[ -f TPOX.bed ]]; then
        #grep 'TPOX' TPOX.bed | awk '{print "2\t"$0}' > temp && mv temp TPOX.bed
        awk -v OFS="\t" '{print $1,$4,$5,$6}' TPOX.bed > temp && mv temp TPOX.bed
fi

# correct space and extend 1 base left + add chr
for i in *.bed
do
        awk -v OFS="\t" '{print "chr"$1,$2-1,$3,$4}' $i > temp && mv temp $i
done

# add 500 to left and 500 to right)
for i in *.bed
do
    bedname=$(echo $i | sed 's/.bed//g')
    awk -v OFS="\t" '{print $1,$2-500,$3+500,$4}' $i > "$bedname".500bp.bed
done

## convert bed to fasta
for i in *.500bp.bed
do
     bedname=$(echo $i | sed 's/.bed//g')
     bedtools getfasta -fi $genomeFa -bed $i -name > "$bedname".fasta
done

# get the left and right 500 bases
for i in *.fasta
do
    seqkit subseq $i -r 1:500 -w 0 | seqkit fx2tab > $i.left
    seqkit subseq $i -r -500:-1 -w 0 | seqkit fx2tab > $i.right
done

#echo "part one done"

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

# make fasta of only repeats
for i in *.bed
do
        bedname=$(echo $i | sed 's/.bed//g')
        bedtools getfasta -fi $genomeFa -bed $i -name > $bedname.repeats.fa
done
## fasta to tab
for i in *.repeats.fa
do
        seqkit fx2tab $i > $i.tab
done

## full ncbi co-ordinates + 500bp, seq of co-ordinates from genome, genomic flanking left and right
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

#echo "part two done"

## bind the flanking regions in the repeat we extracted form gb and ncbi fa
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

#echo "part third done"
cd ..
## delete temp file 
if [[ $deleteTemp == "yes" ]] || [[ $deleteTemp == "Yes" ]]; then
        rm -rf tempDIR/
        echo -e "#temp dir deleted"
fi

cd ..
##) 2>&1) | tee -a Logs.log
echo -e "\nAnalysis done\n"
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

