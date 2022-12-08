#!/bin/bash
#SBATCH --job-name=test-arg   			# Job name
#SBATCH --mail-type=END,FAIL          			# Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=rupesh.kesharwani@bcm.edu   # Where to send mail	
#SBATCH --nodes=1                    			# Run all processes on a single node
#SBATCH --ntasks=1                    			# Run on a single CPU
#SBATCH --cpus-per-task=4            			# Number of CPU cores per task
#SBATCH --mem=90gb                     			# Job memory request
#SBATCH --time=23:00:00               			# Timelimit hrs:min:sec
#SBATCH --output=test-arg_%j.log   		# Standard output and error log
#SBATCH --partition=scavenger				# type of Q:scavenger/medium/compute

cd /stornext/snfs4/next-gen/scratch/rupesh/ProjectFritz/NIHprojct/ArgTest/ArgScript
 
echo -e "All autosomes Analysis started for new sample agaisnt NCBI_DB_Work.."
date_analysis=$(date +'%m/%d/%Y')
echo "Analysis started :" "$date_analysis" 
bash STRspy_run_v1.1_Args.sh -i InputConfig.txt -t UserToolsConfig.txt -j normal
echo -e "All DONE" 
