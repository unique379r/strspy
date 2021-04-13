#!/usr/bin/Rscript

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


rm(list=ls()) # clean work space if you have anything
cat("#Plotting started....\n")
cat ("date..\n")
date()
# # input arg
agr <- commandArgs(TRUE)

if(length(agr) < 4)
{
  stop("Incorrect number of arguments ! \nUSAGE:
Rscript ./Stutters_Line_plot.R <depth_30X.tab> <depth_15X.tab> <name.30X> <name.15X>\n")
}


## assign inputs
freq.30X <- agr[1]
freq.15X <- agr[2]
name.30X <- agr[3]
name.15X <- agr[4]

plotname=paste(name.15X,name.30X, sep="_vs_")

library(ggpubr)
library(ggthemes)

depth.30X <- read.table(freq.30X, header = T)
depth.15X <- read.table(freq.15X, header = T)

TrueSTRs <-nrow(depth.30X[depth.30X$Types=="TrueSTRs", ])
ParentAlleles <-rep("True Alleles", TrueSTRs)
Stutter<-nrow(depth.30X[depth.30X$Types=="Stutters", ])
Stutter<-rep("n+/-1(Stutters)", Stutter)
NonStutters<-nrow(depth.30X[depth.30X$Types=="NonStutters", ])
NonStutters<-rep("Other Artifacts", NonStutters)
Prediction<-c(ParentAlleles, Stutter, NonStutters)
depth.30X$Prediction <- Prediction

TrueSTRs <-nrow(depth.15X[depth.15X$Types=="TrueSTRs", ])
ParentAlleles <-rep("True Alleles", TrueSTRs)
Stutter<-nrow(depth.15X[depth.15X$Types=="Stutters", ])
Stutter<-rep("n+/-1(Stutters)", Stutter)
NonStutters<-nrow(depth.15X[depth.15X$Types=="NonStutters", ])
NonStutters<-rep("Other Artifacts", NonStutters)
Prediction<-c(ParentAlleles, Stutter, NonStutters)
depth.15X$Prediction <- Prediction

q.30X<-ggline(depth.30X, "STR", "NormCounts", 
          color = "Prediction", title = name.30X)
q.30X<-q.30X + theme_economist()+coord_flip()
q.30X<-q.30X + geom_hline(yintercept=0.4, linetype="dashed", 
                          color = "lemonchiffon3", size=1)


q.15X<-ggline(depth.15X, "STR", "NormCounts", 
              color = "Prediction", title = name.15X)
q.15X<-q.15X + theme_economist()+coord_flip()
q.15X<-q.15X + geom_hline(yintercept=0.4, linetype="dashed", 
                          color = "lemonchiffon3", size=1)

myfile=paste(plotname, "pdf", sep=".")
#pdf(myfile, width = 20, height = 20)
#ggsave(myfile, width = 25, height = 20, units = "cm")
cairo_pdf(myfile,onefile = F, width=14,height=11,pointsize = 9)
ggarrange(q.30X, q.15X, ncol = 2, nrow = 1, common.legend = TRUE)
dev.off()

#Define the file name that will be deleted
fn <- "Rplots.pdf"
#Check its existence
if (file.exists(fn)) {
  #Delete file if it exists
  file.remove(fn)
}

# q<-ggline(freq, "STR", "NormCounts", 
#        color = "Types", group = 1)
# q+theme(axis.text.x = element_text(angle = 45, vjust = 0.97, hjust=1))+coord_flip()    
# q<-ggline(freq, "STR", "NormCounts", 
#           color = "Types", group = 1)
# q<-q+theme(axis.text.x = element_text(angle = 90, vjust = 0.97, hjust=1))
# q
# q+ theme_economist(axis.text.x = element_text(angle = 90, vjust = 0.97, hjust=1))
