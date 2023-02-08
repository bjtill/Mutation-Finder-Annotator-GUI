February 6, 2023  Bradley J. Till 

Example data for testing the Mutation Finder and Annotator tool 

The rice VCF contains data for six samples for chromosome 9. This is from the publication:  

Jankowicz-Cieslak J, Hofinger BJ, Jarc L, Junttila S, Galik B, Gyenesei A, et al. Spectrum and Density of Gamma and X-ray Induced Mutations in a Non-Model Rice Cultivar. Plants (Basel). 2022;11:3232.

The samples A43801 and A43802 are non-mutagenized controls.
The samples A43807 and A43808 are technical replicates from a plant treated with 150 Gy of gamma irradiation.
The samples A43818 and A43819 are technical replicates from a plant treated with 75 Gy X-rays.  

The MFA tool uses SnpEff and before testing the rice data you must load the Oryza_sativa. 
After installing SnpEff, open a terminal and cd to the SnpEff directory containing the .jar file and load the genome by typing  java -jar snpEff.jar download -v Oryza_sativa in a terminal window. When running MFA with the rice example data enter Oryza_sativa when promted by the program to enter a SnpEff genome name.  

The coffee VCF data contains data from three samples for chromosome NC_0399181.1 .  

Sample AH1CC3SS28_S28 was derived from treatment of in vitro material with the chemical mutagen EMS
Sample AH1CC3SS55_S55 was derived from treatment of seed with sodium azide 
Sample AH1CC3SS105_S105 was derived from treatment of in vitro material with sodium azide 

Choosing samples to evaluate:  
Induced mutations are expected to be unique to a single seed/in vitro material.  As such, different mutant lines will harbor different mutations.  Technical replicates are included in the rice example.  Run MFA by selecting both replicates. The other four samples serve as controls to subtract any natural variation that is segregating in the population. In general, inclusion of more samples will improve the filtering of unwanted natural variants (using a small number of samples such as in these examples will cause an over-estimation of mutation density).  In the coffee example data, data from three unique mutant lines are provided and as such, the MFA tool should be run using only a single sample.  

 
