function c = IUBDcdf(s,a,b,stepsz,xmax)
    if ~exist('stepsz','var'), stepsz=1E-4; end;
    if ~exist('xmax','var'), xmax=10; end;
    if a<=0 || b<=0, c = nan(size(s)); return; end;
        
%     global IUBDkeys__ IUBDx__ IUBDpdf__ IUBDcdf__ IUBDstepsz__;
%     
%     if isempty(IUBDkeys__)
%         IUBDkeys__ = {};
%         IUBDx__ = eps:stepsz:xmax;
%     end;
%     gkey = sprintf('%f,%f',a,b);
%     gidx = find(ismember(gkey, IUBDkeys__));
%     if isempty(gidx) || true
%         gidx = length(IUBDkeys__)+1;
%         IUBDkeys__{gidx} = gkey;
%         IUBDcdf__(gidx,:) = cumsum([0 IUBDpdf(IUBDx__, a, b)]);
%         IUBDcdf__(gidx,:)   = IUBDcdf__(gidx,:)./IUBDcdf__(gidx,end);
%         
%     end;
%     
   % c = zeros(size(s));
    x = stepsz:stepsz:xmax;
    cidx = min(length(x),max(1,round(s/stepsz)));
    cdf = cumsum([0 IUBDpdf(x, a, b)]);
    cdf = cdf./cdf(end);
    c = cdf(cidx);
    %c = IUBDcdf__(gidx,cidx);

    %if any(isnan(c)) && ~isnan(a) && ~isnan(b)
    %    error('Unexpected NaN')
    %end;
