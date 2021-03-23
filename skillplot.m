function skill = skillplot(obs,mod,dlim,NBOOT)
% SKILLPLOT plots comparison of timeseries and computes skills
%
% SKILL = SKILLPLOT(DATE,OBS,MOD,DLIM,NBOOT)
%
% This function compares two timeseries, OBS and MOD, graphically,
% with a linear regression G-O-F analysis and by means of statistical
% skill scores.
% DLIM is the vector containing axes limits for display (set to empty []
% for automatic limits).
% NBOOT, if different from 0, activates the computation of
% empirical distributions for the P-VALUES and confidence limits
% estimates. NBOOT is the number of permutations
%
% The output SKILL is a structure containing:
%
% Univariate pattern statistics
% SKILL.mean: the model mean
% SKILL.meanobs: the observation mean
% SKILL.B: bias
% SKILL.stdev: the model standard deviation
% SKILL.stdevobs: the obs standard deviation
% SKILL.AAE: absolute average error
% SKILL.RMSDtot: total RMSD
% SKILL.RMSDcp: unbiased RMSD
% SKILL.corrS: Spearman correlation coefficient
% SKILL.corrP: Pearson correlation coefficient
%
% Univariate performance indices
% SKILL.MEF: Modelling Efficiency (Nash and Sutcliffe, 1970)
% SKILL.RI: Reliability index (Legget and Williams, 1981)
%
% Regression information
% SKILL.beta: coefficients of the regression 
% SKILL.r2: determination coefficient
% SKILL.preg: p-value of the F statistics
% SKILL.Freg: value of the F statistics
%
% Empirical statistics and confidence intervals (activated if NBOOT>0)
% SKILL.corrPpv: p-values of the Pearson correlation coefficient
% SKILL.corrPci: confidence intervals of the Pearson correlation
%                coefficient
%
% see also: PVALUES, BOOTCI, NASHSUTCLIFFE, RELINDEX

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

% compute linear regression model
stats = regstats(obs,mod,'linear');
beta = stats.beta;
SIGMA = stats.covb;
dfe = stats.fstat.dfe;
r2 = stats.rsquare;
% test significance H0:beta(2)=1
H=[0 1];
c=1;
[p,F] = linhyptest(beta,SIGMA,c,H,dfe);

plot(mod,obs,'k.')
set(gca,'ylim',dlim,'xlim',dlim)
hold on
h3=refline(1,0);
set(h3,'color',[0 0 0])
xlabel('MODEL');ylabel('DATA')
%axis square
set(gca,'ylim',dlim,'xlim',dlim)
title('(d)')
% overlay regression
H=refline(beta(2),beta(1));
set(H,'linestyle','--')
set(gca,'ylim',dlim,'xlim',dlim)

% compute skill scores
skill.mean = mean(mod);
skill.meanobs = mean(obs);
skill.stdev = std(mod);
skill.stdevobs = std(obs);
skill.beta = beta;
skill.r2 = r2;
skill.preg = p;
skill.Freg = F;
skill.corrS = corr(obs,mod,'type','spearman');
skill.corrP = corr(obs,mod,'type','pearson');
[skill.RMSDtot skill.RMSDcp] = rmsd(obs,mod);
skill.B = mean(mod)-mean(obs);
skill.AAE = mean(abs(mod-obs));
skill.MEF = nashsutcliffe(obs,mod);
skill.RI = relindex(obs,mod);

% compute empirical statistics
if NBOOT>0
   skill.corrPci = bootci(NBOOT,@corr,obs,mod);
   [skill.corrPpv,a,b] = pvalues(NBOOT,@corr,'positive',obs,mod);
   skill.RIci = bootci(NBOOT,@relindex,obs,mod);
   [skill.RIpv,a,b] = pvalues(NBOOT,@relindex,'negative',obs,mod);
   skill.MEFci = bootci(NBOOT,@nashsutcliffe,obs,mod);
   [skill.MEFpv,a,b] = pvalues(NBOOT,@nashsutcliffe,'positive',obs,mod);
end
