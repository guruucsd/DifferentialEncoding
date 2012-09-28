function newfigs = de_DoPlot(plotKey, plotFn, mSets, varargin)
%
%

  if (~isempty(plotKey) && ~guru_contains({plotKey, 'all'}, mSets.plots))
    newfigs = [];
    
  else
  
    % Do the plots
    fprintf('Running %-30s ...', plotFn);
    newfigs = feval( plotFn, varargin{:} );
    fprintf(' done.\n');
    
    for i=1:length(newfigs)
      
      set(newfigs(i).handle, 'Units','Inches');
      set(newfigs(i).handle, 'PaperPositionMode','auto');
      
      % Resize each plot
      if (~isfield(newfigs(i), 'size'))
        [newfigs.size] = deal([]);
      end;
      if (isempty(newfigs(i).size))
        pos = get(newfigs(i).handle, 'Position');
        newfigs(i).size = [pos(3) pos(4)];
      end;
      
      set(newfigs(i).handle, 'Position', [0 0 newfigs(i).size(1) newfigs(i).size(2)]);
    end;
  end;

  