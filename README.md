# Mutation-Finder-Annotator
A tool with graphical user interface to facilitate finding and annotating induced mutations from sequencing data
____________________________________________________________

Use at your own risk.

I cannot provide support.
All information obtained/inferred with this script is without any
implied warranty of fitness for any purpose or use whatsoever.

ABOUT: 
This program identifies DNA sequence variants unique to one or more selected samples preset in a mulit-sample VCF file.  Both heterozygous and homozygous alternative alleles are returned in a new VCF file titled output.vcf. Putative induced mutations are next annotated using the program SnpEff producing the following files:  annotated_output.vcf, snpEff_genes.txt, snpEff_summary.html

PREREQUISITES:
1) A multisample VCF that is compressed with bgzip (ending in .vcf.gz)
2) an index of the .vcf.gz file (using tabix)
3) A SnpEff genome database that matches the genome assembly used to generate the VCF file
4) The following tools installed: SnpEff, SnpSift, Java, bash, zenity, awk, tr, datamash, bcftools. This GUI program was built to run on Ubuntu 20.04 and higher. See installation notes about running on other systems.  

INSTALLATION: 

Linux/Ubuntu: Download and uncompress the SppEff package.  All other tools can be installed in the linx command line by typing the name of the tool and following the instructions if not already installed.  Downlaod the .sh file and provide it permission to execute using chmod +x .

Mac:

Windows: *NOT TESTED*  In theory you can install linux bash shell on Windows (https://itsfoss.com/install-bash-on-windows/) and install the dependecies from the command line (except for SnpEff and SnpSit). If you try this and it works, please let me know. I don't have a Windows machine for testing.  



TO RUN:
Launch in a terminal window using ./  A graphical window will appear with information. Click OK to start. When prompted, enter the name for your analysis directory. A new directory will be created and the files created will be deposited in the directory.  Follow the information to select files and start the program.  
