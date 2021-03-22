 %  model_section is intended to be used once the FeMIP_regrid script has been run for the model of choice.
 %  Using the output .mat file produced by GEOTRACES_section, model_section extracts the same section as that
 %  from GEOTRACES_section but from the model data.
 %
 %  model_section allows for four inputs of which three are manditory
 %
 %  section: section of interest (the .mat file must be present)
 %  file: name of the model file produced after running FeMIP
 %  modelvar: The name of the model variable of interest in the model data
 %  modelname: This is an optional input as it will save the created .mat
 %  file with the modelname included. If left blank, the output name will
 %  be 'FeMIP'.
 %
 %  EXAMPLE
 %  model_section('GA02_var73','FeMIP_01_BFM.nc','N7f','BFM')
 %
 %  The output of model_section will be a .mat file with four variables:
 %
 %  [extension]_latitude:
 %  [extension]_longitue
 %  [extension]_depth
 %  [extension_variable
 %
 %
 %  NOTE: Use addpath command for the location of the .mat and model files
 %        Requires the mll2grid.m script
 %
 %  Jonathan J Rogerson
 %  27 February 2020

%% Load the .mat file of the desired station

function model_section(section,file,var,modelname)
% Basic check

if ~exist('section','var')
    error('No section file chosen, please input the generated section eg: "GA02_var73" '); 
end

if ~exist('file','var')
    error('No model input, please provide model file'); 
end

if ~exist('var','var')
    error('No variable from model file has been chosen'); 
end

% if ~exist('section','var') || ~exist('file','var') || ~exist('var','var')   
%         error('Not enough input arguments')
% end

load(strcat(section,'.mat'))    % Load the structure file of interest

%% Load the model of interest and read in the lon lat variables

lon_grid = ncread(file, 'lon');  % model longitude
lat_grid = ncread(file, 'lat');  % model latitude

%% Use extraction script to locate the longitudes and latitudes from the model

[Lon,Lat] = meshgrid(lon_grid,lat_grid);     % Create the grid

C = who('-file',strcat(section,'.mat'));
sec_lat = eval(C{5});    % List variables in section.mat and asign to sec_lat and 
sec_lon = eval(C{6});    % sec_lon

for i = 1:length(sec_lat)
    [a(i),b(i)] = mll2grid(sec_lat(i),sec_lon(i),Lat,Lon);  % Loop over and find corresponding points
end
   
%% Index the model with the lon and lat values from the GEOTRACES data

lon_grid = lon_grid(a); % index model grid
lat_grid = lat_grid(b); % index model grid

%% Load the model varibale and extract the section

modelvar = ncread(file, var);  % variable of choice from the model
modelvar(modelvar==0) = NaN;    % If file uses zero instead of NaN, replace
var_mean = nanmean(modelvar,4);    % variable mean across time dimension

for i = 1:length(lon_grid)
    tab(i,:) = squeeze(var_mean(a(i),b(i),:)); % Extract locations in the model
end

tab = tab';

%% Create the strucutre

depth = ncread(file,'depth'); % Read and append the depth dimension
section = extractBefore(section,'_');

if ~exist('modelname','var')
    modelname = 'FeMIP';
end

data = struct(strcat(modelname,'_',section,'_',var,'_longitude'),lon_grid,strcat(modelname,'_',section,'_',var,'_latitude'),...
    lat_grid,strcat(modelname,'_',section,'_',var),tab,strcat(modelname,'_',section,'_',var,'_depth'),depth);  % Create data structure
save(strcat(modelname,'_',section,'_',var),'-struct','data');    % Save structure

end

