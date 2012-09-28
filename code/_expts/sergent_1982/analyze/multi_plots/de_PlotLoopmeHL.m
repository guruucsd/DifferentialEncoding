function [figs] = de_PlotLoopmeHL(allstats)

  figs.handle = figure;
  figs.name   = 'loopme-hl';
  
  alldata = zeros(conds, length(sigmas));

  for d1i=1:size(allstats,1)
    for d2i=1:size(allstats,2)
    
      % save off each number
      alldata(:,:,d1i,d2i) = (stats.rej.basics.bars(conds,:));
    end;
  end;
  
  plotfile = fullfile(de_GetBaseDir(), 'results', guru_callerAt(1));

  % Do the plot  
  for i=1:size(alldata,1)
    tmp = squeeze(alldata(i,:,:,:));
    d = squeeze( (tmp(1,:,:)-tmp(2,:,:))./mean(tmp,1) );

    subplot(3,2,i);
    imagesc(d, [-0.5 0.5]);
    colorbar;
    axis('xy');
    %title(TLBL{conds(i)});
    set(gca, 'xtick', [1:length(d2args{1})],  'xticklabel', guru_csprintf('%d', num2cell(d2args{1})))
    set(gca, 'ytick', [1:length(d1args{1})],  'yticklabel', guru_csprintf('%d', num2cell(d1args{1})))
    xlabel(d2{1});
    ylabel(d1{1});
  end;

  print(gcf, plotfile, '-dpng');
  