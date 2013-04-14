function [new_d, new_bins] = rebin_distn(distn, bins, new_bins, showfig, nsamples)
%function [new_d, new_bins] = rebin_distn(distn, bins, new_bins, showfig)
%
% distn
% bins
% new_bins
% showfig
%

if length(distn) ~= length(bins)
    error('Incompatible inputs; distn and bins must be same size');
end;

%special case: zero-padding.  doable if all the old bins are contained in
%the new bin groups, they're continuous, and the spacing is the same
if all(ismember(bins, new_bins)) ...
        && length(get_groups(ismember(bins, new_bins)))==1 ...
        && abs(mean(diff(new_bins)) - mean(diff(bins))) < eps
    new_d = zeros(size(new_bins));
    new_d(ismember(new_bins, bins)) = distn;
    return;
end;

if ~exist('showfig','var'), showfig = false; end;
if ~exist('nsamples','var'), nsamples = round(max(length(bins),length(new_bins)).^1.5*16); end;
if ~exist('new_bins','var'), new_bins = linspace(bins(1), bins(end), nsamples); end;
if nsamples > 1E7, error('will be computing %e samples...', nsamples); end;

[xi,x] = sample_discrete(distn, [1 nsamples], bins, showfig); 
new_d = histc(x,[new_bins(1:end-1) inf])/numel(x);

% upsampling; better smooth, then downsample!
if diff(bins(1:2))>diff(bins(3:4))
  [new_d_sm, new_bins_sm] = smooth_distn(new_d, new_bins, [], [], showfig);
  [new_d, new_bins] = rebin_distn(new_d_sm, new_bins_sm, new_bins, showfig, nsamples);
  return; % no plot
end;


if showfig
    figure;
    xl = [min([bins(:); new_bins(:)]) max([bins(:); new_bins(:)])];
    %yl = [min([distn(:); new_d(:)]) max([distn(:); new_d(:)])];
    subplot(1,3,1); bar(bins, distn./sum(distn(:)), 1);     set(gca, 'xlim', xl); hold on; title('original');%, 'ylim', yl); %axis tight; 
    subplot(1,3,2); bar(new_bins, new_d, 'histc'); set(gca, 'xlim', xl); hold on; title('distribution in new bins');%, 'ylim', yl); %axis tight;
    subplot(1,3,3); bar(bins, histc(x, [bins(1:end-1) inf])/numel(x), 'histc'); set(gca, 'xlim', xl); title('new distribution rebinned to old bins');
end;
