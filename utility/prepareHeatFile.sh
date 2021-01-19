#Inputs: command line arguments
Results="$1"
OutputMatrixName="$2"

print_USAGE()
{
echo -e "USAGE: bash ./prepapreHeatFile.sh <ResultsFile> <OutputMatrixName>\n"
echo "EXAMPLE:"
echo "bash ./prepapreHeatFile.sh Output30_0.4_0.4_Results.txt Output30_0.4_0.4_ResultsMatrix.txt"
echo -e "\n"
}

if [[ $# -ne 2 ]]; then
		echo "#ERROR: Please privide all and correct inputs"
		echo -e "\n"
		print_USAGE
		exit;
fi

## TP = 1; FP = 2; FN = 3

if [[ -f "$Results" ]]; then
	## total Results
	echo -e "#Counts of Partial Match.."
	grep 'OneMatch' "$Results" | wc -l
	echo -e "#Counts of Exact Match (Both Alleles).."
	grep 'BothMatch' "$Results" | wc -l
	grep 'BothMatch' "$Results" | awk 'OFS="\t" {print $1,$2=1,$3=1,$4=1,$5=1,$6="TP"}' > TP1
	echo -e "#Counts of incorrect Match"
	grep 'Nomatch' "$Results" | wc -l
	grep 'Nomatch' "$Results" | awk 'OFS="\t" {print $1,$2=1,$3=1,$4=0,$5=3,$6="FN"}' > FN1
	## erros findings
	#########################
	echo -e "\n#Case Type 1: 12,12 == 12,0; (Results: homozygous == homozygous i.e. Correct Prediction)"
	#echo -e "#one match but one predicted Zero therefore it is Correct Prediction..." 
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2==$3 && $5 == "0") print $0}' | awk 'OFS="\t" {print $1,$2=1,$3=1,$4=1,$5=1,$6="TP"}' > TP2
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2==$3 && $5 == "0") print $0}' | wc -l
	echo "#Example:"
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2==$3 && $5 == "0") print $0}' | head -n2
	

	#########################
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2==$3 && $5 != "0") print $0}' | awk 'OFS="\t" {print $1,$2=1,$3=1,$4=1,$5=2,$6="FP"}' > FP1
	echo -e "\n#Case Type 2: 12,12 == 12,14; (Results: homozygous == hetrozygous i.e. FP)"
	#echo -e "#validated same but pred found one exact only.."
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2==$3 && $5 != "0") print $0}' | wc -l 
	echo "#Example:"
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2==$3 && $5 != "0") print $0}' | head -n2


	#########################
	#echo -e "#one match but one predicted wrong as hetrozygous (FP)..."
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2!=$3 && $5 != "0") print $0}' | awk 'OFS="\t" {print $1,$2=1,$3=1,$4=1,$5=2,$6="FP"}' > FP2 
	echo -e "\n#Case Type 3 (a): 12,13 == 12,14; (Results: hetrozygous == hetrozygous i.e. FP)"
	echo -e "OR"
	echo -e "#Case Type 3 (b): 12,0 == 12,14;  (Results: homozygous == hetrozygous i.e. FP)"
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2!=$3 && $5 != "0") print $0}' | wc -l
	echo "#Example:"
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2!=$3 && $5 != "0") print $0}' | head -n2
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2!=$3 && $5 != "0") print $0}' | awk '$3=="0"'| head -n2

	#########################
	echo -e "\n#Case Type 4: 12,13 == 12,0; (Results: hetrozygous == homozygous i.e. FN)"
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2!=$3 && $5 == "0") print $0}' | awk 'OFS="\t" {print $1,$2=1,$3=1,$4=1,$5=3,$6="FN"}' > FN2
	#echo -e "#one match but one predicted wrong as homozygous..."
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2!=$3 && $5 == "0") print $0}' | wc -l 
	echo "#Example:"
	grep 'OneMatch' "$Results" | awk 'OFS="\t" {if ($2!=$3 && $5 == "0") print $0}' | head -n2

	## merge all into matrix
	cat TP* FP* FN* > "$OutputMatrixName"
	rm TP* FP* FN*
	echo -e "All Done."
else
	echo -e "ERROR: Result files do not exists !!"
fi



