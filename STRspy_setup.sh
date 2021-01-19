#!/bin/bash

clear


# This file is part of STRspy.

## some warnings before to start
echo -e "\n"
echo -e "\t\t\t\t#### Before to Run this script ####"
echo -e "\n"
echo -e "#Make sure internet connection works properly in your privileges."
echo -e "# bash ./STRspy_PackagesInstall.v0.1.sh"
echo -n "Continue ? (y/n) : "
read ans
if [[ "${ans}" != "y" ]] && [[ "${ans}" != "Y" ]]; then
	echo -e "\n"
	clear
	echo -e "Please note that without system packages, dependencies script STRspy.sh may not be able to run !!"
	echo -e "Thank you for using STRspy pipeline."
	exit 0;
fi

# #check OS (Unix/Linux or Mac)
os=`uname`;

# # get the right download program based on OS
if [[ "$os" = "Darwin" ]]; then
	# use curl as the download program
	get="curl -L -o"
else
	# use wget as the download program
	get="wget --no-check-certificate -O"
fi

################ Set preferred installation directory ###################

echo "Where should missing software prerequisites be INSTALLED ? (Please give absolute path) "
read ans
#ans=${ans:-$PREFIX_BIN}
PREFIX_BIN=$ans
if [[ ! -d $PREFIX_BIN ]]; then
    echo "Directory $PREFIX_BIN does not exist!"
    echo -n "Do you want to create $PREFIX_BIN folder ? (y/n)  : "
    read reply
    if [[ "${reply}" = "y" || "${reply}" = "Y" ]]; then
	mkdir -p $PREFIX_BIN/bin
    else
	die "Must specify a directory to install required software!"
    fi
fi
if [[ ! -w $PREFIX_BIN ]]; then
    die "Cannot write to directory $PREFIX_BIN."
fi

echo -e "\n"
echo -e "\n"
################ Set preferred source directory ###################
echo "Where should missing software be DOWNLOAD ? (Please give absolute path) "
read ans
source=$ans
if [[ ! -d $source ]]; then
    echo "Directory $source does not exist!"
    echo -n "Do you want to create $source folder ? (y/n)  : "
    read reply
    if [[ "${reply}" = "y" || "${reply}" = "Y" ]]; then
	mkdir -p $source
    else
	die "Must specify a directory to download and install required software!"
    fi
fi

if [[ ! -w $source ]]; then
    die "Cannot write to directory $source."
fi

#########################
#### Install Programs ###
#########################
clear
echo -e "Installing programs...."

###### samtools ######
# is already installed?
if hash samtools >/dev/null 2>&1; then
	echo -e "\n"
	echo -e "#samtools appear to have already installed !"
else
	echo -e "\n"
	echo -e "#samtools appear to have NOT installed !"
	echo -e "\nDownloading samtools, please wait...."
	$get $source/samtools-1.11.tar.bz2 2>/dev/null https://github.com/samtools/samtools/releases/download/1.11/samtools-1.11.tar.bz2
	cd $source
	tar -xvjpf samtools-1.11.tar.bz2
	cd samtools-1.11
	./configure --prefix=$PREFIX_BIN
	make
	echo -e "\nmaking symbolic link..\n"
	ln -s ./* $PREFIX_BIN
	cd ..
	cd ..
fi
clear
### double check if excutable file has copied..
if [[ -x $PREFIX_BIN/samtools ]]; then
	my_color_text "samtools is installed successfully." cyan
	# # Add binary directory to path globally
	echo 'export PATH=$PATH:'$PREFIX_BIN >> ~/.bashrc
	echo 'PATH=$PATH:'$PREFIX_BIN >> ~/.bash_profile
	## reloading .bashrc
	source ~/.bashrc
	source ~/.bash_profile
	echo -e "\n"
else
	echo -e "Not able to install samtools, please install it manually."
	exit 1;
fi

################ End of the Installation ###################
## reload terminal
#source ~/.bashrc
#source ~/.bash_profile
#clear
#exec bash --login


