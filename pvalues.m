function [pval,pref,p] = pvalues(nboot,bootfun,scoretype,varargin)
%PVALUES Empirical p-values statistics.
%   [PVAL,PREF,P] = PVALUES(NSAMP,FUN,SCORETYPE,D1,D2) draws NSAMP data pair
%   samples D1 and D2, computes statistics on each sample using the function FUN,
%   and returns the results in the matrix P. SCORETYPE sets the direction
%   of the score, 'positive' or 'negative' and the tail on which the
%   p-value will be computed.
%   NSAMP must be a positive integer.  
%   FUN is a function handle specified with @.
%   Each row of P contains the results of applying FUN to one
%   sample.  If FUN returns a matrix or array, then this
%   output is converted to a row vector for storage in P.
%   P is the density distribution of the hypotheses
%   that the two data pair are randomly correlated by means of the function
%   FUN. The p-value PVAL is derived from the proportion of scores larger
%   than the reference score PREF

%   M. Vichi (INGV-CMCC), modified from MATLAB BOOTSTRP function
%   Do not distribute since it contains copyrighted material

% Initialize matrix to identify scalar arguments to bootfun.
la = length(varargin);
scalard = zeros(la,1);

% find out the size information in varargin.
n = 1;
for k = 1:la
   [row,col] = size(varargin{k});
   if max(row,col) == 1
      scalard(k) = 1;
   end
   if row == 1 && col ~= 1
      row = col;
      varargin{k} = varargin{k}(:);
   end
   n = max(n,row);
end


if isempty(bootfun)
   p = zeros(nboot,0);
   return
end

% Get result of bootfun on actual data, force to a row.
pref = feval(bootfun,varargin{:});
p = pref(:)';

% Initialize an array to contain the results of all the bootstrap
% calculations, preserving the output type
p(nboot,1:numel(p)) = p;

% Do bootfun - nboot times.
if la==1 && ~any(scalard)
   % For special case of one non-scalar argument and one output, try to be fast
   X1 = varargin{1};
   for bootiter = 1:nboot
      onesample = randperm(n);
      tmp = feval(bootfun,X1(onesample,:));
      p(bootiter,:) = (tmp(:))';
   end
elseif la==2 && ~any(scalard)
   % For two non-scalar arguments and one output, try to be fast
   X1 = varargin{1};
   X2 = varargin{2};
   for bootiter = 1:nboot
      onesample = randperm(n);
      tmp = feval(bootfun,X1(:,:),X2(onesample,:));
      p(bootiter,:) = (tmp(:))';
   end
else
   % General case
   db = cell(la,1);
   for bootiter = 1:nboot
      onesample = randperm(n);
      for k = 1:la
            db{k} = varargin{k};
      end
      % permute the second set of data
      db{2} = varargin{2}(onesample,:);
      tmp = feval(bootfun,db{:});
      p(bootiter,:) = (tmp(:))';
   end
end

% Compute the p-value
switch scoretype
   case 'positive'
      out = numel(find(p>pref));
   case 'negative'
      out = numel(find(p<pref));
   otherwise
      error('No ordering specified')
end
pval = out/nboot*100;