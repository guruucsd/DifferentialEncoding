function stats = de_DoStat(statKey, stats, statProp, stc, statFn, varargin)
%
% Inputs:
%   statKey -
%   stats   - current stats object
%   statProp - statprop that we'll assign to
%   stc      - list of all stats to run
%   statFn   - function to compute stats
%   varargin - arguments to statFn


  % Skipping this stat
  if (~isempty(statKey) && ~guru_contains({statKey, 'all'}, stc) ...
      || (guru_contains(['-' statKey], stc))) %explicit skip
    stats.(statProp) = [];

  % Need to run the stat
  elseif (~isfield(stats, statProp) || isempty(stats.(statProp)))

    % Do the stats
    fprintf('Running %-30s ...', statFn);

    % Get just the numbers
    if (nargout(statFn)==1)
      stats.(statProp) = feval( statFn, varargin{:} );

    % Get the numbers and a statistical test
    else
      [stats.(statProp).('vals'), ...
       stats.(statProp).('pval')] ...
                       = feval( statFn, varargin{:} );
    end;
    fprintf(' done.\n');

  end;

