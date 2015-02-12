function [mean_neighbor_dist, min_neighbor_dist, unique_neighbor_dist] = de_calc_neighbor_dist(varargin)
% Given a 2D connection matrix, or two vectors containing x and y values of connections,
%   returns the mean, min, and unique distances between connection nearest neighbors.
%

if nargin == 1
    cxn_matrix = varargin{1};
    [cy,cx] = find(cxn_matrix);
elseif nargin == 2
    cx = varargin{1};
    cy = varargin{2};
end;

neighbor_dist = nan(length(cx));
for ci=1:length(cx)%  For each connected unit
  for di=(ci+1):length(cx)% Manual search for nearest neighbor

    % Interpatch distance
    neighbor_dist(ci,di) = sqrt( (cx(ci)-cx(di)).^2 + (cy(ci)-cy(di)).^2);
    neighbor_dist(di,ci) = neighbor_dist(ci,di); % must include this, for the min below to work.
  end;
end;

unique_neighbor_dist = neighbor_dist(triu(neighbor_dist,1)~=0);
min_neighbor_dist = min(neighbor_dist);
mean_neighbor_dist = mean(min_neighbor_dist);
