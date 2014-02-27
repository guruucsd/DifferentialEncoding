function [mean_nn_dist,min_nn_dist,unique_nn_dist] = de_calc_nn_dist(cx,cy)
% Given a
%

if numel(cx)~=length(cx) && ~exist('cy','var')
    cxn_matrix = cx;
    [cy,cx] = find(cxn_matrix);
end;

nn_dist = nan(length(cx));
for ci=1:length(cx)%  For each connected unit
  for di=(ci+1):length(cx)% Manual search for nearest neighbor

    % Interpatch distance
    nn_dist(ci,di) = sqrt( (cx(ci)-cx(di)).^2 + (cy(ci)-cy(di)).^2);
    nn_dist(di,ci) = nn_dist(ci,di); % must include this, for the min below to work.
  end;
end;

unique_nn_dist = nn_dist(triu(nn_dist,1)~=0);
min_nn_dist = min(nn_dist);
mean_nn_dist = mean(min_nn_dist);
