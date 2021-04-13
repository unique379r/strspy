
#!/bin/bash

# This file is part of STRspy project.

# MIT License

# Copyright (c) 2020 unique379r

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
StutterDirofTab="$1" 

print_USAGE()
{
echo -e "USAGE: bash ./Stutters_Line_Plot_wrapper.sh <StutterDirofTab>\n"
echo "EXAMPLE:"
echo "bash ./Stutters_Line_Plot_wrapper.sh ../StutterDirofTab"
echo -e "\n"
}

if [[ $# -ne 1 ]]; then
		echo "#ERROR: Please privide all and correct inputs"
		echo -e "\n"
		print_USAGE
		exit;
fi

if [[ ! -d $StutterDirofTab ]]; then
	echo "Error: Its not a dir"
	exit 1;
fi

script="./Stutters_Line_plot.R"

cd $StutterDirofTab

echo "#Working..."

for i in *15*.tab
do
	str_fift=$(echo $i | awk -F'_' '{print $1"_"$2}')
	depth_fift=$(echo $i | awk -F'_' '{print $3}' | gsed 's/.tab//g')
	dna_fift=$(echo $i | awk -F'_' '{print $3}' | gsed 's/.tab//g' | awk -F'-' '{print $2"-"$3}')
	for j in *30*.tab
	do
		str_thirty=$(echo $j | awk -F'_' '{print $1"_"$2}')
		depth_thirty=$(echo $j | awk -F'_' '{print $3}' | gsed 's/.tab//g')
		dna_thirty=$(echo $j | awk -F'_' '{print $3}' | gsed 's/.tab//g' | awk -F'-' '{print $2"-"$3}')
		if [[ $str_fift == $str_thirty ]] && [[ $dna_fift == $dna_thirty ]]  
		then
			echo "Potting for -->" $i $j $str_fift"_"$depth_fift $str_thirty"_"$depth_thirty
			## Norm Counts plots
			Rscript $script $i $j $str_fift"_"$depth_fift $str_thirty"_"$depth_thirty
		fi
	done
done

echo "#Done"

cd ..
