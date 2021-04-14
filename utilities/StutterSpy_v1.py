#!/usr/bin/env python3

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

import sys
import os
import argparse
import time
import glob
import os.path

VERSION="0.1"

def in_progress(args):
    """placeholder"""
    print('working on it...')

def version(args):
    """Print the version"""
    print("StutterSpy v%s" % VERSION)
## arguments ask
USAGE = """\
StutterSpy v%s - A simple script to find stutters, non-stutters and True alleles in a given samples.
""" % VERSION

## ====================================================functions====================================================
## Arguments check/file validation
def check_dir(indir):
    if not os.path.isdir(indir):
        #print("ERROR: Provided input is not a directory !!")
        sys.exit("ERROR: Provided input is not a directory !!")

def check_file(infile):
    if not os.path.exists(infile):
        #print("ERROR: Provided input is not a file !!")
        sys.exit("ERROR: Provided input is not a file !!")

def check_multiplefiles(dirfiles):
    if not glob.glob(dirfiles):
        #print("ERROR: Provided input is not a file !!")
        sys.exit("ERROR: Input dir exists but files do not exist, it must be bam or fastq files.")

def num(s):
    try:
        return int(s)
    except ValueError:
        return float(s)

def run(args):
    ##check file type
    motif_file = args.motif_file
    count_file = args.count_file
    locusname = args.locusname
    samplename = args.samplename
    depthreplicate = args.depthreplicate
    check_file(motif_file)
    check_file(count_file)
    print("True Allele Motif file:\t", motif_file)
    print("Count file            :\t", count_file)
    print("Locus                 :\t", locusname)
    print("Sample Name           :\t", samplename)
    print("Depth & replicates    :\t", depthreplicate)

    ##running program
    f1 = open(motif_file, "r")
    Lines1 = f1.readlines()
    NC = []
    for line in Lines1:
        line = line.strip('\n')
        col_list = line.split("\t")
        if col_list[0] == locusname :
            NC.append(col_list)
    f1.close()
    print("\n")
    fo0 = open(locusname + "_" + samplename + "_"+ depthreplicate + "_TrueSTRs.out", "w")
    fo1 = open(locusname + "_" + samplename + "_"+ depthreplicate + "_Stutters.out", "w")

    print("Stutters Output:")
    print("\n")
    for line in NC:
        # print("\n")
        # print("\n")
        print("--------------")
        print(line)
        print("--------------")
        x = -1
        y = -1
        z = -1
        x = num(line[-1])
        #print(x)
        yy = line[1].split("]")
        if len(yy) == 2:
            y = num(yy[1])
        #print(y)
        zz = line[2].split("]")
        if len(zz) == 2: 
            z = num(zz[1])
        #print(z)
        f2 = open(count_file, "r")
        Lines2 = f2.readlines()
        for line in Lines2:
            line = line.strip('\n')
            col_list = line.split("\t")
            first_col = col_list[0].split("_")
            x1 = -1
            y1 = -1
            z1 = -1
            #print (first_col[-1])
            x1 = num(first_col[-1])
            #print(x)
            yy1 = first_col[1].split("]")
            if len(yy1) == 2:
                y1 = num(yy1[1])
            #print(y)
            zz1 = first_col[2].split("]")
            if len(zz1) == 2:
                z1 = num(zz1[1])
            #print(z)
            if x1 == x:
                ## Truth sets
                truth_filt = line
                #print(truth_filt)
                fo0.write(line)
                fo0.write("\n")
            elif (x1 == x+1 or x1 == x-1) and (y1 == y or y1 == y+1 or y1 == y-1) and (z1 == z or z1 == z-1 or z1 == z+1):
                ## stutters
                stutters_sets = line
                #print(stutters_sets)
                print(line)
                fo1.write(line)
                fo1.write("\n")
            # else:
                #print('Printing nothing for non-stutters')
                ## non-stutters but have duplicates
                # non_Stutters_sets = line
                # fo2.write(line)
                # fo2.write("\n")
        f2.close()
    fo0.close()
    fo1.close()
    #fo2.close()     

    ##remove duplicates from stutters list
    stutters = str(locusname + "_" + samplename + "_"+ depthreplicate + "_Stutters.out")
    stutters_undup = str(locusname + "_" + samplename + "_"+ depthreplicate + "_Stutters_undup.out")

    lines_seen = set()  # holds lines already seen
    outfile = open(stutters_undup, "w")
    infile = open(stutters, "r")

    for line in infile:
        if line not in lines_seen:
            outfile.write(line)
            lines_seen.add(line)
    outfile.close()
    infile.close()

    ##rename files
    os.remove(stutters)


    ##cat *_Stutters.out *predictedTruth.out > temp2select
    filt= str(locusname + "_" + samplename + "_"+ depthreplicate + "_TrueSTRs.out")
    stutters_undup = str(locusname + "_" + samplename + "_"+ depthreplicate + "_Stutters_undup.out")
    filenames = [filt, stutters_undup]
    with open('filtered_Stutters.txt', 'w') as outfile:
        for names in filenames:
            with open(names) as infile:
                for line in infile:
                    outfile.write(line)
    outfile.close()

    ## make non-stutters file
    doc = open('filtered_Stutters.txt', 'r')
    doc1 = open(count_file, 'r')
    f1 = [x for x in doc.readlines()]
    f2 = [x for x in doc1.readlines()]
    dif = [line for line in f2 if line not in f1] # lines present only in f2
    doc.close()
    doc1.close()
    non_Stutters_out = str(locusname + "_" + samplename + "_" + depthreplicate + "_NonStutters.out")
    with open(non_Stutters_out, 'w') as file_out:
        for match in dif:
            file_out.write(match)
        file_out.close()

    ## now remove the *_Stutters.out *predictedTruth.ou i.e. filtered_Stutters.txt
    os.remove('filtered_Stutters.txt')

def main():
    """
    Argument parsing
    """
    parser = argparse.ArgumentParser(prog="StutterSpy", description=USAGE, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-i1", "--input1", default=None, metavar="INPUT_motif_file", dest="motif_file", type=str, help="Truth allele Motif", required=True)
    parser.add_argument("-i2","--input2", default=None, metavar="INPUT_count_file", dest="count_file", type=str, help="Freq counts file", required=True)
    parser.add_argument("-t","--locus_name", default=None, metavar="LOCUS_NAME", type=str, dest="locusname", help="locus name", required=True)
    parser.add_argument("-s","--samplename", default=None, metavar="samplename",type=str,  dest="samplename", help="dir of all str bed", required=True)
    parser.add_argument("-d","--depthreplicate", default=None, metavar="DEPTH", type=str, dest="depthreplicate", help="depth such as 30X or 15X and replicates type_number", required=True)
    #parser.add_argument("-o","--output_dir", default=None, type=str, metavar="DIR", dest="output", help="output directory to save the results", required=True)
    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)

if __name__=="__main__":
    print("====================================")
    start = time.process_time()
    #print('\nSTR spying begins at:'+str(start))
    main()
    print("====================================\n")
    end = time.process_time()
    #print('\nSTR spying end at:'+str(end))
    print("The Program run time is : %.03f seconds" %(end-start))


