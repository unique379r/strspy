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
PredictedStutterDir="$1" 

print_USAGE()
{
echo -e "USAGE: bash ./Prepare_filesforLinePlot.sh <PredictedStutterDir>\n"
echo "EXAMPLE:"
echo "bash ./Prepare_filesforLinePlot.sh ../PredictedStutterDir "
echo -e "\n"
}

if [[ $# -ne 1 ]]; then
		echo "#ERROR: Please privide all and correct inputs"
		echo -e "\n"
		print_USAGE
		exit;
fi

cd $PredictedStutterDir

echo "#Preparing..."

echo "--10%"
for i in *.out
do
	sample=$(echo $i | awk -F'_' '{print $NF}' | gsed 's/.out//g')
	awk -v s=$sample '{print $0"\t"s}' $i > temp && yes | mv temp $i
done

echo "---50%"

for i in *Stutters_undup.out
do
	gsed -i 's/undup/Stutters/g' $i
done

echo "-----80%"
for i in *.out
do
	depth=$(echo $i | awk -F'_' '{print $3}')
	str=$(echo $i | awk -F'_' '{print $1"_"$2}')
	cat *$str"_"$depth* | sort -k4r > $str"_"$depth.tab
	gsed -i '1iSTR\tCounts\tNormCounts\tTypes' $str"_"$depth.tab
done

echo "---------100%"
echo "#Done"

cd ..
