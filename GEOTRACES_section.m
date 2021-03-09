function GEOTRACES_section(section,variable,vgrid)

% This script is intended to be used in conjuction with the
% GEOTRACES_IDP2017_v2_Discrete_Sample_Data.nc available at
% http://www.geotraces.org/dp/idp2017. 
%
% GEOTRACES_section extracts data for a chosen variable from station locations where depth profiles of that variable were
% taken. The output will be a .mat file with the name of the desired section
% containing the following variables: 
%   Latitude
%   Longitude
%   Depth
%   Date
%   Variable
%   vertical_grid
%   [Variable]_interp (interpolation of data to vertical grid)
%
% The function GEOTRACES_section allows for four inputs: 
% - the section of interest (refer to list of sections),  
% - the variable of interest (refer to documentation on naming conventions 
%   of variables in nc_variables.txt) 
% - a vertical grid, in a file named 'levels'. 
%   If no grid is specified, the default interpolation is
%   to the World Ocean Atlas 2001 (WOA01) (Conkright et al. 2002)
% - the file path to GEOTRACES_IDP2017_v2_Discrete_Sample_Data.nc, unless
%   added to the the search path (with the addpath command)
%
% EXAMPLE 1:
% GEOTRACES_section without any argument is equivalent to running 
% GEOTRACES_section('GA02','var73') if the path 
%
% If you choose to use a custom grid (FeMIP_makegrid), then you can apply 
% it to the GEOTRACES Data
%
% EXAMPLE 2:
% The user has the option to use the grid generated with FeMIP_makegrid. 
% Use 'T' if you would like to use your custom grid from makegrid; else
% leave blank or set to 'F' to use the default WOA01 vertical grid
%
% GEOTRACES_section('GA02','var73','T')
%
% Refer to the makegrid file and the README.txt for more information.
% NOTE: if you set the vgrid option to 'F', but you used makegrid, this may
% generate an error if the grid dimension and design are not identical
%
% List of sections available:
%   'GA01'
%   'GA02'
%   'GA03'
%   'GA04'
%   'GA06'
%   'GA10'
%   'GA11'
%   'GAc01'
%   'GAc02'
%   "GI04'
%   'GIPY01'
%   'GIPY02'
%   'GIPY04'
%   'GIPY05'
%   'GIPY06'
%   'GIPY11'
%   'GIPY13'
%   'GIpr01'
%   'GP02'
%   'GP13'
%   'GP16'
%   'GP18'
%   'GPc01'
%   'GPc02'
%   'GPc03'
%   'GPpr01'
%   'GPpr02'
%   'GPpr04'
%   'GPpr05'
%   'GPpr07'
%   'GPpr10'
%
%
% Author: Jonathan J Rogerson (UCT)
% Contributors: Marcello Vichi (UCT)

%% Read the data
% default values
IDP = 'GEOTRACES_IDP2017_v2_Discrete_Sample_Data.nc';
VAR = 'var73'; % dissolved Fe
SEC = 'GA02';

if ~exist(IDP,'file')
    error(['GEOTRACES file ',IDP,' not found! e.g. addpath ../GEOTRACES/discrete_sample_data/netcdf'])
else
    file = IDP;
end

if ~exist('section','var'); section = SEC; end
if ~exist('variable','var'); variable = VAR; end

% ncdisp(file); optional to display file contents

%% Read in the station and extract the index of the desired location

station = ncread(file, 'metavar1');  % read in the station variable
station = station';     % transpose to rectify format
station = cellstr(station);     % Convert from a character to a cell-array
list_station = unique(station);  % List of all the stations

if ~any(strcmp(list_station,section))
   error('Station not found, refer to list of stations using: help GEOTRACE')
end

index = find(ismember(station, section)); % find the index of the desired station
station = station(index); % Only the stations of interest

%% Read in the other key varibales

lon = ncread(file, 'longitude');
lat = ncread(file, 'latitude');
depth = ncread(file, 'var2');
var = ncread(file,variable);    % The variable of choice

time = ncread(file, 'date_time');
time2=datenum(time+datenum('01-Jan-0006'));
TimeDT = datetime(time2, 'ConvertFrom',  'datenum', 'Format', 'yyyy-MM-dd');  % Convert format of time 

%% Index the variables to the station

lon = lon(index);
lat = lat(index);
depth = depth(:,index); % Index the key variables to that of the station
var = var(:,index);   % Get all the station depth profiles
TimeDT = TimeDT(index);

%% Remove all columns containing all missing values

locate_mis = nansum(var);  % Answer of zero is a NaN column
col_mis = find(locate_mis == 0);    % find the indices of the missing columns
var(:,col_mis) = [];   % Remove missing columns from iron
depth(:,col_mis) = [];  % Remove missing columns from depth
lat(col_mis) = [];  % Remove the corresponding column in latitude
lon(col_mis) = [];  % Remove the corresponding column in longitude
station(col_mis) = [];  % Remove the corresponding column from station
TimeDT(col_mis) = [];   % Remove the corresponding column from time

if isempty(var)
    disp(['No variable data for:',cellstr(section)])  % If there is no variable data
    return
else

%% Create vertical grid

if ~exist('vgrid','var') || vgrid == 'F'
   array = [0 10 20 30 50 75 100 125 150 200 250 ...
            300 400 500 600 700 800 900 1000 1100 ... 
            1200 1300 1400 1500 1750 2000 2500 3000 ...
            3500 4000 4500 5000 5500];   % Default WOA01 array if no vertical grid is given
elseif  vgrid == 'T'
%    array = [vgrid(:)];   % Vertical grid is specified by the user
    array = dlmread('levels');  % Vertical grid read from the makegrid
    array(end)=[];              % Fix
end

%% Loop through each column and identify the missing values and then interpolate

for k = 1:size(var,2)
    Index_Nan = ~isnan(var(:,k)); % Index of non-missing values in var column k
    column_var = var(:,k);    % Assign column of var to a variable
    var_new = column_var(Index_Nan); % var_new contains no missing values 
    column_depth = depth(:,k);  % Assign column k of depth to a variable
    depth_new = column_depth(Index_Nan);    % Index column_depth with no missing value indices of var
    Index_nan = ~isnan(depth_new);  % To ensure no missing values, find all non_missing values in depth_new   
    var_new = var_new(Index_nan);     % Index var_new with non_missing values in depth
    depth_new = depth_new(Index_nan);   % Index depth_new with non-missing values of depth_new
    if length(depth_new) ~= length(var_new)
        continue       % If the number of measurements do not correspond 
    else
    var_plot = var_new;   % Change variable name to var_plot
    depth_plot = depth_new; % Change variable name to depth_plot
    [depth_plot, index_o] = unique(depth_plot,'first'); % Identify the unique values in depth_plot and the indices
    if size(depth_plot,1) == 1  % if only one depth occurs in a column
        continue                 % Only interesting in locations where a depth profile is taken/present
    else
        same = sum(1:size(depth_new,1)) - sum(index_o); % Check to see if depth is repeated, if 0, no depths are repeated
        if same ~= 0    % Depth is repeated when it is not zero
            depthvar =  [depth_new, var_plot];
            [C,ia,idx] = unique(depthvar(:,1),'stable');
            val = accumarray(idx,depthvar(:,2),[],@mean);
            your_mat = [C val];     % Average out duplicate or triplicate measurements
            depth_plot = your_mat(:,1);
            var_plot = your_mat(:,2);
        end
    end
    var_complete(:,k) = [var_plot; NaN(size(var,1) - size(var_plot,1),1)];   % Collect the uninterpolated variable data
    depth_complete(:,k) = [depth_plot; NaN(size(var,1) - size(var_plot,1),1)];  % Actual depth profiles
    lat_complete(:,k) = lat(k);          % Lat position of all stations
    lon_complete(:,k) = lon(k);          % Lon position of all stations
    TimeDT_complete(:,k) = TimeDT(k);    % Time of all the stations
    interpolation(:,k) = interp1(depth_plot, var_plot, array, 'linear'); % Do the linear interpolation using WOA01
    end
end
%% Clean up the created variables

locate_row = nansum(var_complete,2); % Look for any rows that only have NaN
row_mis = find(locate_row == 0);  % Find the indice of Nan rows
var_complete(row_mis,:) = [];   % Remove from var_complete
depth_complete(row_mis,:) = [];  % Remove from depth
lon_complete = wrapTo180(lon_complete);  % Convert format of longitude to range -180 to 180
format short g
depth_complete = round(depth_complete);
data = struct(strcat(section,'_',variable,'_longitude'),lon_complete,strcat(section,'_',variable,'_latitude'),lat_complete,...
    strcat(section,'_',variable,'_depth'),depth_complete,strcat(section,'_',variable),var_complete,...
    strcat(section,'_',variable,'_date'),TimeDT_complete,strcat(section,'_',variable,'_interp'),interpolation,...
    strcat(section,'_',variable,'_vgrid'),array);  % Create data structure
save(strcat(section,'_',variable),'-struct','data');    % Save structure

end
end