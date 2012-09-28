function out = de_SavePlot(modelSettings, figs)
%
%
  if (isstruct(figs)), figs = {figs}; end;
  
  out = modelSettings.out;
  
  % Loop over figure names to make sure they're all unique.
  figNames = {figs.name};
  [b,i,j] = unique(figNames);
  
  for f=1:length(figs)
    nSameName = length(find(j==j(f)));
    if (nSameName > 1)
      figs(f).name = sprintf('%s-%d', figs(f).name, 1+length(find(j(1:f-1)==j(f))));
    end;
  end;
  
  % Loop over each output type
  for i=1:length(out.plots)
    ext = [ '.' out.plots{i} ];

    % Loop over each plot
    for j=1:length(figs)
      out.files{end+1} = de_GetOutFile(modelSettings, 'plot', figs(j).name, ext, modelSettings.runs);
      
      if (ismember(1,modelSettings.debug))
        fprintf('Saving plot %-15s to %s.\n', ['"' figs(j).name '"'], out.files{end});
      end;
      
      figure(figs(j).handle);
      sz = get(figs(j).handle, 'PaperPosition');
      set(figs(j).handle, 'PaperPosition', [sz(1:2) sz(3:4)/1.25]);
      print(out.files{end}, ['-d' ext(2:end)]);
      
      %close(figs(j).handle);
    end;
  end;

