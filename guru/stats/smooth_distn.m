function [sub_d, new_bins, org_d] = smooth_distn(distn, bins, resampling, windowsize, showfig)
% [sub_d, new_bins] = smooth_distn(distn, bins, resampling, windowsize, showfig)
%
% distn: original discrete probability mass function
% bins: 
% resampling: how many subdivisions to resample to
% windowsize: width of gaussian window (std is fixed to windowsize)
% showfig: replot?
%
% sub_d: output resampled distribution

%
if ~exist('showfig','var'), showfig = false; end;

% Choose # samples
if ~exist('resampling','var') || isempty(resampling), resampling = 16; end;
nsamples = round(numel(bins)^2*resampling);
if nsamples > 1E7, error('will be computing %e samples...', nsamples); end;

% Sample and rebin
new_bins = guru_newbins(bins, resampling); % Compute the new bins
[~,x] = sample_discrete(distn, [1 nsamples], bins);      % Get the samples
new_x = guru_hist(x,new_bins);                           % rebin

% gaussian window for smoothing
if ~exist('windowsize','var') || isempty(windowsize), windowsize=4*round(sqrt(length(new_bins))); end;

% Loop over all values, and smooth with gaussian kernel
gw = normpdf(-windowsize/2:windowsize/2,0,sqrt(windowsize)); gw=gw/sum(gw);%/sum(normpdf(-5:5));
pad_x = [zeros(1, floor(length(gw)/2)) new_x zeros(1, ceil(length(gw)/2))];
new_d = zeros(1,length(new_bins));
for ii=1:length(new_bins)
  new_d(ii) = sum( pad_x(ii-1+[1:length(gw)]) .* gw );
end;
sub_d = new_d/sum(new_d); %renormalize smoothed distribution
%sub_d = new_d(round(length(gw)/2+1):round(end-length(gw)/2)); sub_d = sub_d/sum(sub_d);

% now, resample back down, and weight based on these
idx = reshape(1:length(new_bins), [resampling length(new_bins)/resampling]);
org_d = sum(new_d(idx),1);
org_d = org_d./sum(org_d);

if showfig
    figure; set(gcf, 'position', [3         219        1278         465]);

    subplot(1,3,1); set(gca, 'FontSize', 14);
    bar(bins, distn./sum(distn)); 
    hold on;
    bh = bar(bins, org_d, 'r');
    ch = get(bh,'child');
    set(ch,'facea',.5);
    axis tight; 
    title('Original pmf', 'FontSize', 16);

    subplot(1,3,2);  set(gca, 'FontSize', 14);
%    bar(bins, histc(x, [bins(1:end-1) inf])/numel(x),'histc'); 
    bar(new_bins, guru_hist(x, new_bins)/numel(x), 1); 
    title('Faux data, binned to new bins', 'FontSize', 16); 
    axis tight;
    
    subplot(1,3,3);  set(gca, 'FontSize', 14);
    bar(new_bins, sub_d, 1); 
    hold on; 
    title('Faux data, smoothed over new bins', 'FontSize', 16); 
    axis tight;    
end;

