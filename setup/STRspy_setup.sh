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

#clear


# This file is part of STRspy.

## some warnings before to start
echo -e "\n"
echo -e "\t\t\t\t#### Welcome to the installation of third-party software for STRspy pipeline use ####"
echo -e "\t\t\t\t\t\t\t#### Before to Run this script ####"
echo -e "\n"
echo -e "#Make sure internet connection works properly in your privileges."
echo -e "# bash ./STRspy_setup.sh"
echo -n "Continue ? (y/n) : "
read ans
if [[ "${ans}" != "y" ]] && [[ "${ans}" != "Y" ]]; then
	echo -e "\n"
	clear
	echo -e "#Please note that without tool packages, the pipeline STRspy may not work for you !!"
	echo -e "Required tools:"
	echo -e "\n1. bedtools\n2. minimap2\n3. samtools\n4. xatlas\n5. gnu-parallel"
	echo -e "\n^^^^^^^^^^^^^^^^^^^^^^^^^^BYE-BYE^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n#Thank you for using STRspy pipeline.\n"
	exit 0;
fi


#########################
#### Install Programs ###
#########################
#clear
echo -e "checking if strspy_env is already present...."
if hash conda >/dev/null 2>&1; then
	ENV=$(conda info --envs | grep ^strspy_env | awk '{print $1}')
	if [[ $ENV == "strspy_env" ]]; then
		echo -e "\n#The STRspy virtual environment has already been created/present, and packages should installed there as well"
		echo -e "#Please use the STRspy package templets to manually create ToolConfig.txt\n"
		exit 1;
	fi
else
	echo -e "#conda/miniconda appears to have NOT installed ! please install it to continue.."
	exit 1;
fi

# ## required tools to run STRspy ##
# ## 1. bedtools >=v2.30.0
# ## 2. minimap2 >=v2.18-r1015
# ## 3. samtools >=v1.12
# ## 4. xatlas >=v0.2.1
# ## 5. gnu parallel >=20210222

if hash conda >/dev/null 2>&1; then
	echo -e "\n"
	echo -e "#conda appears to have already installed !"
	echo -e "#attempting to make a conda env and install required packages.."
	conda env create -n strspy_env -f ./environment.yml
	## reload terminal
	source ~/.bashrc
	source ~/.bash_profile
	echo -e "#Installation done"
	exit 1;
else
	clear
	echo -e "#conda/miniconda appears to have NOT installed ! please install it to continue.."
	exit !;
fi

## grab tools from strspy_env



################ End of the Installation ###################
## reload terminal
#source ~/.bashrc
#source ~/.bash_profile
#clear
#exec bash --login


