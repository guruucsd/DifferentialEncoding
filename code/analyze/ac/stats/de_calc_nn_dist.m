function mean_nn_dist = de_calc_nn_dist(cxn_matrix)
% Given a
%

[cy,cx] = find(cxn_matrix);
nn_dist = nan(length(cx));
for ci=1:length(cx)%  For each connected unit
  for di=(ci+1):length(cx)% Manual search for nearest neighbor

    % Interpatch distance
    nn_dist(ci,di) = sqrt( (cx(ci)-cx(di)).^2 + (cy(ci)-cy(di)).^2);
    nn_dist(di,ci) = nn_dist(ci,di); % must include this, for the min below to work.
  end;
end;

mean_nn_dist = mean(min(nn_dist));
  