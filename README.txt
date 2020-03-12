--------------
Introduction
--------------

This package consists of the following bash and MATLAB scripts:

	FeMIP
	makegrid
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

--------------
Flow Diagram
--------------

Download and unzip GEOTRACES_IDP2017_v2_Discrete_Sample_Data.zip to extract the netcdf file
and also provide the desired model file.

The following is a flow diagram showing the order in which the various scripts must be run:


	GEOTRACES_section.m		FeMIP & makegrid (optional)
		|				|	
		|				|
		|				|
		|				|
		------>  modelsection.m  <-------
				|
				|
				|
			   modelplot.m	

When running the scripts, place FeMIP and makegrid in the same directory as the model output file.
Run GEOTRACES_section.m in conjunction with GEOTRACES_IDP2017_v2_Discrete_Sample_Data.nc.
modelsection.m will use the outputs of FeMIP and GEOTRACES_section.m to create the necessary
process files for modelplot.m

-------------------
Useful NCO commands
-------------------

For FeMIP, the model file must have certain attributes and variable names. Therefore, here are a 
number of common NCO and CDO commands that can be used to preprocess a file before running FeMIP.

Associate your lon and lat variables with a specific variable

ncatted -a coordinates,VAR,c,c,"YOURLON YOURLAT" FILE.nc

Move your lon and lat variables from one file and place them in another

ncks -A -v YOURLAT,YOURLON FILE_OLD.nc FILE_NEW.nc

Can use the following to rename your variables 

ncrename -a OLDNAME, NEWNAME FILE.nc


March 2020
Jonathan J Rogerson


 	
