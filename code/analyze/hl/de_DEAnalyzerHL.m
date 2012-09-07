function [stats, figs]  = de_DEAnalyzerHL(mSets, mss)
%function [stats, figs]  = de_DEAnalyzerHL(mSets, mss)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% models   : resulting models after training
%
% Outputs:
% stats      : 
% figs       : 

  % Show model summary
  if (ismember(1,mSets.debug))
    fprintf(de_modelSummary(mSets));    % Show AC & P settings
  end;
  mss = num2cell(mss, 1);

  if (exist(de_getOutFile(mSets, 'stats')))
    load( de_getOutFile(mSets, 'stats'), 'stats' );
  end;
  
  [stats.raw]   = de_DEStaticizer(mSets, mss, {'default'});
  [stats.raw.r] = de_DoRejectionsHL(mss, mSets.rej.types, mSets.rej.width);

  % Log some results
  if (ismember(1,mSets.debug))
    for i=1:length(mSets.sigma)      % Log rejections data
      fprintf('Rejections: %d\n', length(find(sum(stats.raw.r{i},2)~=0)));
    end;
  end;
  
  [stats.rej] = de_DEStaticizer(mSets, de_DoRejectionsHL(mss, stats.raw.r));
  [figs]      = de_DEFigurizer(mSets, mss, stats);
    
  [stats] = de_DEStaticizerHL(mSets, mss, stats);
  [figs]  = [figs de_DEFigurizerHL(mSets, mss, stats) ];

  
