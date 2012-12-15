function out = de_SavePlots(modelSettings, figs)
%
%

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
        fprintf('Saving plot %-15s to %s.\n', ['"' figs(j).name '"'], guru_replace(out.files{end}, de_GetBaseDir(), ''));
      end;
      
%      figure(figs(j).handle);
%      sz = get(figs(j).handle, 'PaperPosition');
%      set(figs(j).handle, 'PaperPosition', [sz(1:2) sz(3:4)/1.25]);
      
      %i/o
      if (~exist(guru_fileparts(out.files{end}, 'pathstr'), 'dir'))
        mkdir(guru_fileparts(out.files{end}, 'pathstr')); 
      end;
      if (strcmp('fig',ext(2:end)))
        saveas(figs(j).handle, out.files{end});
      else
        print(figs(j).handle, out.files{end}, ['-d' ext(2:end)]);
      end;
      
      % Make a version of the plot for publication
      if (true || false)
        ft = ext(2:end);
        if (~strcmp(ft, 'fig'))
          hatch_fn = [out.files{end}(1:end-4) '-pub' out.files{end}(end-3:end)];
          if (ismember(1,modelSettings.debug))
            fprintf('Saving plot %-15s to %s.\n', ['"' figs(j).name '"'], guru_replace(hatch_fn, de_GetBaseDir(), ''));
          end;

          im = imread(out.files{end}, ft);
          [im_hatch,colorlist] = mfe_applyhatch_pluscolor(im,'kx\-.');
          imwrite(im_hatch,hatch_fn, ft);
        end;
      end;
      %close(figs(j).handle);
    end;
  end;

