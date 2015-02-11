function out = de_SavePlots(mSets, figs)
%
%

  out = mSets.out;

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
      out.files{end+1} = de_GetOutFile(mSets, 'plot', figs(j).name, ext, mSets.runs);

      % Don't re-create existing figures
      if (figs(j).cached), continue; end;

      if (ismember(1,mSets.debug))
        fprintf('Saving plot %-15s to %s.\n', ['"' figs(j).name '"'], out.files{end});%guru_replace(out.files{end}, de_GetBaseDir(), ''));
      end;

      %i/o
      if (~exist(guru_fileparts(out.files{end}, 'pathstr'), 'dir'))
        mkdir(guru_fileparts(out.files{end}, 'pathstr'));
      end;

      saveas(figs(j).handle, out.files{end}, ext(2:end));
      %export_fig(figs(j).handle, out.files{end}, '-transparent');

      % Make a version of the plot for publication
      if (mSets.out.pub)
        ft = ext(2:end);
        if (~strcmp(ft, 'fig'))
          hatch_fn = [out.files{end}(1:end-4) '-pub' out.files{end}(end-3:end)];
          if (ismember(1,mSets.debug))
            fprintf('Saving plot %-15s to %s.\n', ['"' figs(j).name '"'], hatch_fn);%guru_replace(hatch_fn, de_GetBaseDir(), ''));
          end;

          im = imread(out.files{end}, ft);
          [im_hatch,colorlist] = mfe_applyhatch_pluscolor(im,'kx\-.');
          imwrite(im_hatch,hatch_fn, ft);
        end;
      end;
      %close(figs(j).handle);
    end; %each plot
  end; %each output type

  % Now save the plot metadata, for re-loading cached plots
