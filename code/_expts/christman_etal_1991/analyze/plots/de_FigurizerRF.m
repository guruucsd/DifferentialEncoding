function figs = de_FigurizerRF(mSets, mss, stats)  
%

  % Plot default
  if (guru_contains('default', mSets.plots))
    default_plots = {'rf-dots'};
    mSets.plots = setdiff(unique({mSets.plots{:} default_plots{:}}), {'default'});
  end;
  
  
  % Dummy fig
  figs = de_NewFig('dummy');
  
  figs = [figs de_DoPlot('rf-dots',     'de_PlotRFDots',                        mSets, mSets, stats.rej) ];
