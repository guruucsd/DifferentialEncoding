function stats = de_LoadStats(mSets, mss)
% Stats encompass all models, so can't be stored by autoencoder type,
%   but rather under the project results directory.

    if (~exist(de_GetOutFile(mSets, 'stats', mSets.runs), 'file'))
        stats = [];

    else
      try
        % See if our stats cache has been invalidated (or not)
        all_ac = true; all_p = true;
        for i=1:length(mss)
            ac = [mss{i}.ac]; all_ac = all_ac && all([ac.cached]);
            if (isfield(mss{i}, 'p')),
                p  = [mss{i}.p];  all_p  = all_p  && all([p.cached]);
            end;
        end;

        % We should load the cached stats
        if (~all_ac && ~all_p)
            stats = [];

        else
            fprintf('Loading cached stats...\n');

            load( de_GetOutFile(mSets, 'stats'), 'stats' );

            % Invalidate any stats that are marked
            if (~all_ac),
                stats.rej.ac = [];
                stats.raw.ac = [];
            end;

            if (~all_p),
                stats.rej.p = [];
                stats.raw.p = [];
            end;

            stats.cached = (all_ac && all_p);
         end;
       catch err
         warning(sprintf('Error while loading stats; re-running from scratch. %s\n', err.message));
         stats = [];
       end;
    end;

    if (true || ~isfield(stats, 'cached')), stats.cached = false; end;
    if (true ||~isfield(stats, 'raw')),    stats.raw = struct('ac', [], 'p', []); end;
    if (true ||~isfield(stats, 'rej')),    stats.rej = struct('ac', [], 'p', []); end;

