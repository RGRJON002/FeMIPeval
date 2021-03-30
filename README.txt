--------------
FeMIPeval Introduction
--------------

This package consists of the following bash and MATLAB scripts:

	FeMIP_regrid
	FeMIP_makegrid
	GEOTRACES_section.m
	model_section.m
	modelplot.m
	mll2grid.m
	skillplot.m
	rmsd.m
	pvalues.m
	relindex.m
	nashsutcliffe.m

The collection of scripts allows a user to conduct observational data vs model comparisons with the 
GEOTRACES_IDP2017_v2 data set

-------------- --------------
FeMIPeval – Quick Start Guide
-------------- --------------

1. What do you need? 
A netcdf version of the 2017 GEOTRACES Intermediate Data Product 
CDO and NCO installed
Matlab, including m_map
Your model output as a netcdf (ideally CMOR-ised)

2. What is the workflow?

(A)	Extract the GEOTRACES data for the section and variable of interest using GEOTRACES_section.m matlab script
(B)	Regrid your model output using FEMIP_regrid shell script
(C)	Extract the model data for the GEOTRACES section using model_section.m matlab script
(D)	Construct the skill assessment using modelplot.m matlab script

--------------
Flow Diagram
--------------

Download and unzip GEOTRACES_IDP2017_v2_Discrete_Sample_Data.zip to extract the netcdf file
and also provide the desired model file.

The following is a flow diagram showing the order in which the various scripts must be run:


	GEOTRACES_section.m	   FeMIP_regrid & FeMIP_makegrid (optional)
		|				|	
		|				|
		|				|
		|				|
		------>  modelsection.m  <-------
				|
				|
				|
			   modelplot.m	

When running the scripts, execute FeMIP_regrid with the desired options and edit FeMIP_makegrid appropriately.
Run GEOTRACES_section.m in conjunction with GEOTRACES_IDP2017_v2_Discrete_Sample_Data.nc.
modelsection.m will use the outputs of FeMIP_regrid and GEOTRACES_section.m to create the necessary
process files for modelplot.m

-------------------
Useful NCO commands
-------------------

For FeMIP_regrid, the model file(s) must have certain attributes and variable names. Ideally, the model outputs
should be CMOR-ized (https://cmor.llnl.gov/) in their file structure to be compatible with FeMIP_regrid.
Therefore, here are a number of common NCO and CDO commands that can be used to preprocess a file 
before running FeMIP_regrid.

Associate your lon and lat variables with a specific variable

ncatted -a coordinates,VAR,c,c,"YOURLON YOURLAT" FILE.nc

Move your lon and lat variables from one file and place them in another

ncks -A -v YOURLAT,YOURLON FILE_OLD.nc FILE_NEW.nc

Can use the following to rename your variables 

ncrename -a OLDNAME, NEWNAME FILE.nc

Subset a file with only selected variables

cdo select,name=VAR1,VAR2, … ,VARN FILE.nc FILE_NEW.nc

-------------------
Acknowledgements
-------------------
The work of WG 151 presented in this article results, in part, from funding provided by national committees of the Scientific Committee on Oceanic Research (SCOR) and from a grant to SCOR from the U.S. National Science Foundation (OCE-1840868).


March 2020
Edited December 2020
Jonathan J Rogerson
