#!/bin/bash
#B.T. January 24, 2023
#GUI version
##################################################################################################################################

zenity --width 1000 --info --title "Mutation Finder and Annotator (MFA) GUI: Click OK to start" --text "

ABOUT: 
This program identifies DNA sequence variants unique to one or more selected samples preset in a mulit-sample VCF file.  Both heterozygous and homozygous alternative alleles are returned in a new VCF file titled output.vcf. Putative induced mutations are next annotated using the program SnpEff producing the following files:  annotated_output.vcf, snpEff_genes.txt, snpEff_summary.html

PREREQUISITES:
1) A multisample VCF that is compressed with bgzip (ending in .vcf.gz), 2) an index of the .vcf.gz file (using tabix), 3) A SnpEff genome database that matches the genome assembly used to generate the VCF file, 4) the following tools installed: 
SnpEff, SnpSift, Java, bash, zenity, awk, tr, datamash, bcftools. This program was built to run on Ubuntu 20.04 and higher. See the readme file for information on using with other opperating systems.  

TO RUN:
Click OK to start. When prompted, enter the name for your analysis directory. A new directory will be created and the files created will be deposited in the directory.  Follow the information to select files and start the program.  

LICENSE:  
MIT License

Copyright (c) 2023 Bradley John Till

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the *Software*), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Version Information:  Version 1.5, February 07, 2023"

directory=`zenity --width 500 --title="DIRECTORY" --text "Enter text to create a new directory (e.g. Sample1234).  
WARNING: No spaces or symbols other than an underscore." --entry`

if [ "$?" != 0 ]
then
    exit
    fi
mkdir $directory
cd $directory

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>MFAt.log 2>&1
now=$(date)  
echo "Mutation Finder and Annotator (MFA) GUI, Version 1.5
Script Started $now."  

zenity --width 500 --info --title "VCF Selection" --text "Click OK to select the VCF file. The file should be compressed and end in .vcf.gz "
ZAR=$(zenity --file-selection --title="Select the .vcf.gz file" --file-filter=*.gz)
if [ "$?" != 0 ]
then
    exit
    fi
echo $ZAR >> variantpath

#Extract samples from VCF file and format for display in zenity checklist
b=$(head -1 variantpath)
bcftools query -l $b > samplelist1 #used later
awk '{print $1, "Blank"}' samplelist1 | datamash transpose | rev | cut -c6- | rev | tr '\t' ' '  > SL5
#rev script.tab | cut -c3- | rev > script2.tab
zenlist=$(head -1 SL5)
MUT=$(zenity --width 600 --height 600 --list --title="Choose one or more samples that share unique mutations"  --separator="\n" --column="Select" --column="Sample" echo $zenlist --checklist)

if [ "$?" != 0 ]
then
    exit
    fi
echo $MUT >> MutantL

#For multiple mutants:
tr ' ' '\t' < MutantL > MutantTab
datamash transpose < MutantTab > Mutants


#Make the file for mutant selection to be used by SNPsift:  
#1 = isHom ( GEN[sample] ) & isVariant( GEN[sample]
#2 = isRef ( GEN[sample])
awk 'NR==FNR{a[$1]=$1;next}{if (a[$1]) print $1, "1" ;else print $0, "2"}'  Mutants samplelist1 > SSlist

SEG=$(zenity --width 600 --entry --title "Enter the exact name of the SNPeff genome. This is case sensitive." --text="SNPeff Genome Name")
if [ "$?" != 0 ]
then
    exit
    fi
echo $SEG >> SNPeffGenome

zenity --width 500 --info --title "SnpEff Location" --text "Click OK to choose the SnpEff.jar file"
SEP=$(zenity --file-selection --title="Select the SnpEff.jar file")
if [ "$?" != 0 ]
then
    exit
    fi

echo $SEP >> SnpEffpath

zenity --width 500 --info --title "SnpSift Location" --text "Click OK to choose the SnpSift.jar file"
SSP=$(zenity --file-selection --title="Select the SnpSift.jar file")
if [ "$?" != 0 ]
then
    exit
    fi
echo $SSP >> SnpSIFTpath

zenity --width 500 --info --title "READY TO LAUNCH" --text "Click OK to start the Mutation Finder and Annotation program. Progress is indicated by a progress bar. A log file titled MFA.log will be created."

(#Start progress bar
echo "# Finding unique mutations in the selected samples"; sleep 2

#Split samples list by sample name and create the SnpSift expression for the chosen genotype status

awk '{print > ($1".b")}' SSlist
for i in *.b; do 
awk '{if ($2==2) print "isRef (GEN["$1"]) &"; else if ($2==1) print "(isHom (GEN["$1"]) & isVariant(GEN["$1"]) || isHet ( GEN["$1"])) & "}' $i > ${i%.*}.bb
done

paste *.bb > script.stage
#Clean up the tabs
tr '\t' ' ' < script.stage > script.tab
rev script.tab | cut -c3- | rev > script2.tab
#Collect the paths for SnpSift and the VCF file and create a shell script to run SnpSift
a=$(head -1 SnpSIFTpath)
b=$(head -1 variantpath)
awk -v awkvar1="$a" -v awkvar2="$b" '{print "#!/bin/bash" "\n" "#Induced mutation identification" "\n" "java -Xmx64g -jar " awkvar1 " filter \x22"$0"\x22 " awkvar2 " > output.vcf"}' script2.tab > MutHunt.sh

# give permission for the shell script to run.  
chmod +x MutHunt.sh

echo "75" 
echo "# Running genotype selection script"; sleep 2 
./MutHunt.sh

echo "85" 
echo "# Running SNPeff on resulting VCF"; sleep 2
 
#Collect the path for SnpEff and the name of the genome database to be used for SnpEff
c=$(head -1 SnpEffpath)
d=$(head -1 SNPeffGenome)

#Run SnpEff
java -Xmx32g -jar $c $d output.vcf >  annotated_ouput.vcf

echo "95" 
echo "# Final processing steps.  Program almost finished."; sleep 2
) | zenity --width 800 --title "PROGRESS" --progress --auto-close
now=$(date)  
echo "Program finished $now."
#Collect information to add to log file.  The program is not technically finished, but the above line ensures an end time appears on the log file. 
datamash transpose < Mutants > mut1
awk '{print "Mutants selected:", $0}' mut1 > mut2
awk '{print "SNPeff genome used:", $1}' SNPeffGenome > sng
awk '{print "Path to VCF file used:", $1}' variantpath > vpath
awk '{print "Path to SnpEFF.jar:", $1}' SnpEffpath > sepath
awk '{print "Path to SnpSIFT.jar:", $1}' SnpSIFTpath > sspath
cat MFAt.log mut2 sng vpath sspath sepath > MFA.log
#Remove temporary files 
rm *.b *.bb MutHunt.sh script.stage script.tab script2.tab samplelist1 SL5 SSlist mut1 mut2 Mutants MFAt.log variantpath vpath SnpEffpath sepath SnpSIFTpath sspath sng 
rm MutantL MutantTab SNPeffGenome
#End of program 
##################################################################################################################################
