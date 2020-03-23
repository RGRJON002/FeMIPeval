%   modelplot can be run after running GEOTRACES_section.m and model_section.m.
%   Using the created .mat files, modelplot will create a composite plot
%   consisting of:
%
%   (a) - Section plot of the obervational data
%   (b) - World map showing the location of the section
%   (c) - Section plot of model output
%   (d) - Goodness-of-fit plot
%   (e) - Distribuion plot
%   (f) - Table of relevant statistical scores
%
%   modelplot requires two inputs:
%
%   section.mat file of observational data produced by GEOTRACES_section.m
%   and the .mat file from model_section.mat
%
%   EXAMPLE 1
%
%   modelplot('GA02_var73','FeMIP_GA02_FER');
%
%   In addition, modelplot has three optional inputs:
%
%   axis -  (create the section plots using either lon or lat), use 'lon' to
%   create a plot along longitude and 'lat' for latitude. The default is 
%   for latitude
%
%   scale_model - If not done so already, scale the model output to the
%   units of the observational data. Default is set to 0.
%
%   units - Set the units that will appear on the plots
%
%   EXAMPLE 2:
%
%   modelplot('GA02_var73','FeMIP_GA02_FER','lat',3,'umol Fe/m^3')
%   
%   NOTE: To create some of the plots, this script requires the mapping
%   package m_map which is available at https://www.eoas.ubc.ca/~rich/map.html
%   In addition, skillplot.m and the other secondary scripts are required
%   to do the statistical tests.
%
%   Jonathan J Rogerson
%   23 February 2020

%% Create function modelplot

function modelplot(section,model_section,axis,scale_model,units)

%% Load the reguired mat files

load(strcat(section,'.mat'));         % Load the OBS
load(strcat(model_section,'.mat'));    % Load the MODEL


OBS = who('-file',strcat(section,'.mat'));
depth_obs = eval(OBS{7});
iron_obs = eval(OBS{4});
lat_obs = eval(OBS{5});
lon_obs = eval(OBS{6});    % List variables in section.mat and asign to sec_lat and 


MODEL = who('-file',strcat(model_section,'.mat'));
iron_model = eval(MODEL{1});
depth_model = eval(MODEL{2});      % Assign variables
lat_model = eval(MODEL{3});
lon_model = eval(MODEL{4});

if ~exist('axis','var')
    axis_plotobs = lat_obs;
    axis_plotmodel = lat_model;   % If no axis is selcted make 'lat' default
    label = 'Latitude';
elseif exist('axis','var')
    if  axis == 'lat'
        axis_plotobs = lat_obs;
        axis_plotmodel = lat_model;     % Set the axis for plotting
        label = 'Latitude';
    elseif axis == 'lon'
        axis_plotobs = lon_obs;
        axis_plotmodel = lon_model;
        label = 'Longitude';
    end
end

if ~exist('scale_model','var')     % Scale the model data, default is power of 0
    scale_model = 0;
end

if ~exist('units','var')
    units = ' ';                   % If no units are specified, have null
end
%% Create the basic figure
figure

subplot(3,2,1)                            % OBS section plot
pcolor(axis_plotobs,-depth_obs,iron_obs)
title('(a)')
xlabel(label)
ylabel('Depth [m]')
shading interp
colormap jet 
c_lim = (round(nanmean(reshape(iron_obs,[],1)) + nanstd(reshape(iron_obs,[],1))) * 1.1);
caxis([0 c_lim])
y = colorbar;
vartype = extractAfter(section,'_');
ylabel(y, strcat('Concentration of',{' '},vartype ,{' '},'[',units,']'))

subplot(3,2,2)          % World Map

title('(b)')
m_proj('miller','lat',[-70 70]);  
m_coast('patch',[.7 1 .7],'edgecolor','none');
m_coast('Color', 'k', 'LineWidth', 1);
m_grid('box','fancy','linestyle','-','gridcolor','w','backcolor',[.2 .65 1]); 
hold on
sectionname = extractBefore(section,'_');
list = {sectionname};
text = {'k','k','k'};
s = m_scatter(lon_obs,lat_obs,14,'filled');
s.LineWidth = 0.2;
s.MarkerEdgeColor = 'k';
s.MarkerFaceColor = [0.85 0.85 0.85];
m_text(lon_obs(end),lat_obs(end),list{1},'Color',text{1})


subplot(3,2,3)           % Section plot of MODEL

grr = iron_model * 10^(scale_model);

pcolor(axis_plotmodel,-depth_model,grr)
title('(c)')
xlabel(label)
ylabel('Depth [m]')
shading interp
colormap jet 
caxis([0 c_lim])
y = colorbar;
ylabel(y, strcat('Concentration of',{' '},vartype ,{' '},'[',units,']'))

subplot(3,2,4)      % GOF plot

ironobs = reshape(iron_obs,[],1);
ironmodel = reshape(grr,[],1);
ind_mis = find(isnan(ironobs));
ironobs(ind_mis) = [];
ironmodel(ind_mis) = [];
ind_mis = find(isnan(ironmodel));
ironobs(ind_mis) = [];
ironmodel(ind_mis) =[];
ind_mis = find(ironmodel < 0);
ironobs(ind_mis) = [];
ironmodel(ind_mis) = [];
skill = skillplot(ironobs, ironmodel,[0 round(c_lim *2)],1);

subplot(3,2,5)    % Distribution plot

histogram(ironobs)
hold on 
histogram(ironmodel,'FaceColor','g')
title('(e)')
xlabel(strcat('Concentration of',{' '},vartype ,{' '},'[',units,']'))
ylabel('Density')
legend('OBS','MODEL')
xlim([0 c_lim*2])

h = subplot(3,2,6);     % Stats table

cnames = {string(strcat('Concentration of',{' '},vartype ,{' '},'[',units,']'))};
rnames = {'Model mean','Obs mean','Model std',...
    'Obs std','Pearson r','RMSD','B','AAE (MAE)',...
    'RMSD_CP','MEF','RI'};

data = [skill.mean, skill.meanobs, skill.stdev, skill.stdevobs,...
    skill.corrP, skill.RMSDtot, skill.B, skill.AAE, skill.RMSDcp,...
    skill.MEF, skill.RI];
    

hPos = get(h, 'Position');          
set(gca,'xtick',[])
set(gca,'ytick',[])
title('(f)')

% Create the uitable
t = table(data','RowName',rnames);
T = uitable('Data',t{:,:},'ColumnName',cnames,'RowName',rnames,'Units', 'Normalized', 'Position', hPos,'FontSize',11);        
T.FontSize = 11;
T.FontWeight = 'bold';

end