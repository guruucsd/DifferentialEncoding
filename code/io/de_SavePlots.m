function out = de_SavePlots(mSets, figs)
%
%

  out = mSets.out;

  % Loop over figure names to make sure they're all unique.
  figNames = {figs.name};
  [~, ~, idx] = unique(figNames);

  for fi=1:length(figs)
    nSameName = length(find(idx==idx(fi)));
    if sum(idx==idx(fi)) == 1, continue; end;
    figs(fi).name = sprintf('%s-%d', figs(fi).name, 1 + sum(idx(1:fi-1)==idx(fi)));
  end;

  % Loop over each output type
  for pi=1:length(out.plots)
    ext = [ '.' out.plots{pi} ];

    % Loop over each plot
    for fi=1:length(figs)
      out.files{end+1} = de_GetOutFile(mSets, 'plot', figs(fi).name, ext, mSets.runs);

      % Don't re-create existing figures
      if (figs(fi).cached), continue; end;

      if (ismember(1, mSets.debug))
        fprintf('Saving plot %-15s to %s.\n', ['"' figs(fi).name '"'], out.files{end});
      end;

      %i/o
      if (~exist(guru_fileparts(out.files{end}, 'pathstr'), 'dir'))
        guru_mkdir(guru_fileparts(out.files{end}, 'pathstr'));
      end;

    figure(figs(fi).handle);
      cur_pos = get(figs(fi).handle, 'position');
      aspect_ratio = cur_pos(3)/cur_pos(4);
      set(figs(fi).handle, 'paperunits', 'inches');
      set(figs(fi).handle, 'paperposition', [0 0 12 12/aspect_ratio]);
      if strcmp(ext, '.fig')
        saveas(figs(fi).handle, out.files{end}, ext(2:end));
      else
        %export_fig(figs(fi).handle, [out.files{end} '-export-fig' ext], '-transparent');
        print(figs(fi).handle, out.files{end}, ['-d' ext(2:end)]);
      end;
      set(figs(fi).handle, 'units', 'pixels');

      % Make a version of the plot for publication
      if (mSets.out.pub)
        ft = ext(2:end);
        if (~strcmp(ft, 'fig'))
          hatch_fn = [out.files{end}(1:end-4) '-pub' out.files{end}(end-3:end)];
          if (ismember(1,mSets.debug))
            fprintf('Saving plot %-15s to %s.\n', ['"' figs(fi).name '"'], hatch_fn);
          end;

          im = imread(out.files{end}, ft);
          [im_hatch,colorlist] = mfe_applyhatch_pluscolor(im,'kx\-.');
          imwrite(im_hatch,hatch_fn, ft);
        end;
      end;
    end; %each plot
  end; %each output type
