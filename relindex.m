function y = relindex(obsData,simData)
% RELINDEX compute reliability index
%   RI = RELINDEX(O,P) calculates the reliability index of
%   the matrix O and P (observations and predictions)
%
%   References:
%   Legget and Williams, 1981; Stow et al., 2009

% Copyright (C) 2009  M. Vichi 
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.

    % Check the input array and build the time axis in case none is given
    ncol = size(obsData,2);
    if ncol>2
       error('The function accepts column arrays only.')
    elseif ncol==1
       % add a fake time coordinate, equal for obs and model data
       faketime = 1:numel(obsData);
       obsData = [faketime' obsData];
       simData = [faketime' simData];
    end
    % find matching values
    [v loc_obs loc_sim] = intersect(obsData(:,1), simData(:,1));

    % and create subset of data with elements= Time, Observed, Simulated
    MatchedData = [v obsData(loc_obs,2) simData(loc_sim,2)];
    % remove zeros
    %z = all(MatchedData(:,2:3),2);
    %MatchedData(z,:)=[];
    clear v loc_obs loc_sim z

    [r c] = size(MatchedData); 

    if r >= 2
       E = log(MatchedData(:,2)) - log(MatchedData(:,3));
       N = numel(MatchedData(:,2));
       y = exp(sqrt(sum(E.^2)/N));
    else % cannot compute statistics
        error('MATLAB:divideByZero',['Intesecting data resulted in too few elements to compute.',...
           ' \n Function has been terminated.',' If this is unexpected, \n check your index vectors of the two arrays.']);
    end
