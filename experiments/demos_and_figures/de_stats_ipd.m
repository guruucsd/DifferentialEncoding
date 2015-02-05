function [fc_dist, nn_dist] = de_stats_ipd(img, pts, mupos)
%function [ipd] = de_stats_ipd(pts)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
% 
% Output:
% ti : # of training iterations
    if exist('img','var') && ~isempty(img)
        % Defined by non-zero entries in a 2D matrix
        [cy,cx] = find(img);
        if ~exist('mupos', 'var')
            % Assume the center of the image
            mupos = size(img) / 2;
        end;

    elseif exist('pts','var') && ~isempty(pts)
        % Defined by a distribution of points
        cy = pts(:, 2);
        cx = pts(:, 1);
        if ~exist('mupos', 'var')
            mupos = [0 0];
        end;
    end;
    
    fc_dist = zeros(size(cx));
    nn_dist = nan(length(cx));  % want dist from 
    
    %  For each connected unit
    for ci=1:length(cx)

        % Average distance from center
        fc_dist(ci) = sqrt( (cx(ci)-mupos(2)).^2 + (cy(ci)-mupos(1)).^2);

        % Manual search for nearest neighbor
        for di=ci+1:length(cx)
            % Interpatch distance
            nn_dist(ci,di) = sqrt( (cx(ci)-cx(di)).^2 + (cy(ci)-cy(di)).^2);
            nn_dist(di,ci) = nn_dist(ci,di); % must include this, for the min below to work.
        end;
    end;

    
    %fprintf('Average distance from center: %f\n', mean(fc_dist));
    %fprintf('Average minimum inter-patch distance: %f\n', mean(min(nn_dist)));
    
    % dist_fn = @(sig) mean(sqrt(sum( mvnrnd(zeros(1, ndims(sig)), sig, 1000000).^2, 2)))