function [sig,stat]=do_perm(Ma1,Ma2,varargin)

% this funtion makes a t-test permutation between two matrices. The test is
% perfomed across columns (default: all columns) specified by nbins. nperm
% is the number of permutation (1000 as default). sig is the binary
% significant values and stat is a structure array containing the min and
% max permutation distributions, the upper and lower confidence interval (assuming a
% p=0.05 two-tailed) and and the original t statistics

[r1,c1] = size(Ma1);
[r2,c2] = size(Ma2);

if r1<=r2       
    nobs = r1;
else
    nobs = r2;
end

if nargin==2
    nperm = 1000;
    if c1<=c2
        nbin = c1;
    else
        nbin = c2;
    end
elseif nargin==3
    nperm =varargin{1};
    if c1<=c2
        nbin = c1;
    else
        nbin = c2;
    end
elseif nargin == 4
    nbin  = varargin{2};
    nperm = varargin{1};
end


t_ori = zeros(1,nbin);
for a=1:nbin
    sg1 = Ma1(:,a);
    sg2 = Ma2(:,a);
    sg1(isnan(sg1))= [];
    sg2(isnan(sg2))= [];
    sg1(isinf(sg1))= [];
    sg2(isinf(sg2))= [];
    if ~isempty(sg1) && ~isempty(sg2)
        [~,~,~,stat]=ttest2(sg1,sg2);
        t_ori(1,a) = stat.tstat;
    else
        t_ori(1,a) = NaN;
    end
end

max_dist = zeros(1,nperm);
min_dist = zeros(1,nperm);
disp('%%%%%%%%%%%%%%%% STARTING PERMUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%')
for b=1:nperm
    fprintf('Perm %d\n',b)
    t_perm = zeros(1,nbin);
    pMa1 = Ma1;
    pMa2 = Ma2;
    prand = rand(1,nobs)>0.5;
    pMa1(prand,:) = Ma2(prand,:);
    pMa2(prand,:) = Ma1(prand,:);
    for a=1:nbin
        sg1 = pMa1(:,a);
        sg2 = pMa2(:,a);
        sg1(isnan(sg1))= [];
        sg2(isnan(sg2))= [];
        sg1(isinf(sg1))= [];
        sg2(isinf(sg2))= [];
        if ~isempty(sg1) && ~isempty(sg2)
            [~,~,~,stat]=ttest2(sg1,sg2);
            t_perm(1,a) = stat.tstat;
        else
            t_perm(1,a) = NaN;
        end
    end
    max_dist(1,b) = max(t_perm);
    min_dist(1,b) = min(t_perm);
end

upp_val = prctile(max_dist,97.5); 
low_val = prctile(min_dist,2.5) ; 
sig = t_ori>upp_val | t_ori<low_val;

stat          = [];
stat.t_ori    = t_ori; 
stat.upp_val  = upp_val;
stat.low_val  = low_val;
stat.max_dist = max_dist;
stat.min_dist = min_dist;
