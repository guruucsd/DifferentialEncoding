function [figs] = de_PlotSTA(models, sta)
%s
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
%
% Output:
% h             : array of handles to plots

  % Plot 1: show trend of encoding error, according to type (Reza's plots)
  %   This plot will show outliers as spikes.
  % Create old-style info



  hus           = de_SelectHUs(models(1)); nHUs = length(hus);
  [nRows,nCols] = guru_optSubplots(nHUs);

  figs           = de_NewFig('sta-inst');
  figs(end+1)    = de_NewFig('sta-avg');
  for hui=1:nHUs

      figure(figs(1).handle);
      subplot(nRows,nCols,hui);
      img = reshape(sta(1, :, hus(hui)), models(1).nInput);
      imagesc(img, max(img(:))*[-1 1], [-1, 1]);
      set(gca, 'xtick',[],'ytick',[]);

      figure(figs(2).handle);
      subplot(nRows,nCols,hui);
      img = reshape(mean(sta(:, :, hus(hui))), models(1).nInput);
      imagesc(img, max(img(:))*[-1 1], [-1, 1]);
      set(gca, 'xtick',[],'ytick',[]);
  end;
