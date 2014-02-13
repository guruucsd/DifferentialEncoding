function stats = de_LoadSummaryStats(mSets, mss)

  if (~exist(de_GetOutFile(mSets, 'summary-stats', mSets.runs), 'file'))
      stats = [];

  else
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
          
          load( de_GetOutFile(mSets, 'summary-stats'), 'stats' );
      
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
  end;
  
  if (true || ~isfield(stats, 'cached')), stats.cached = false; end;
  if (true||~isfield(stats, 'raw')),    stats.raw = struct('ac', [], 'p', []); end;
  if (true||~isfield(stats, 'rej')),    stats.rej = struct('ac', [], 'p', []); end;
  
