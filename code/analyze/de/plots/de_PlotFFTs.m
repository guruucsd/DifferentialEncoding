function figures = de_PlotFFTs(mSets, ffts)
%
%
  figures(1) = de_newFig('');
  figures = figures([]);
  



  % Map from 2D to 1D

  avgPowerOrig2D            = (reshape(mean(ffts.orig.*conj(ffts.orig), 1), mSets.nInput))';
  [freqs_1D,avgPowerOrig]   = guru_fft2to1(fftshift(avgPowerOrig2D));
  avgPowerOrig = avgPowerOrig';
  
  f   = cell( length(ffts.model), 1 );
  
  for i=1:length(ffts.model)
    nModels = size(ffts.model{i}, 1);
    
    tmp{i} = squeeze(mean(ffts.model{i}.*conj(ffts.model{i}),2)); %average over all images
    f{i}   = zeros(nModels, length(freqs_1D));
    
    for j=1:nModels %# models
        [~,f{i}(j,:)] = guru_fft2to1( fftshift(squeeze(tmp{i}(j,:,:))) );
    end;
  end;
  
  % Calculate averages over all models
  avgPowerModel1 = mean(f{1}, 1)'; %col vectors
  avgPowerModel2 = mean(f{end}, 1)';
  avgPower       = [avgPowerModel1 avgPowerModel2 avgPowerOrig];

  
  % Common parts
  lgnd = {sprintf('LVF/RH (\\sigma=%3.1f)', mSets.sigma(1)), ...
          sprintf('RVF/LH (\\sigma=%3.1f)', mSets.sigma(2)), ...
          'Orig'};
  xlbl = 'spatial frequency (cycles)';

  % 1D, with original
  figures(end+1) = de_newFig('fft-1D-worig');
  plot(freqs_1D, avgPower)
  set(gca,'xlim',freqs_1D([1 end]));
  legend(lgnd{:});
  xlabel(xlbl); ylabel('power');
  
  % 1D, no original
  figures(end+1) = de_newFig('fft-1D-noorig');
  plot(freqs_1D, avgPower(:,1:2))
  set(gca,'xlim',freqs_1D([1 end]));
  legend(lgnd{1:2}); 
  xlabel(xlbl); ylabel('power');

  
  % 1D, on log scale, with original
  figures(end+1) = de_newFig('fft-1D-log-worig');
  plot(freqs_1D, log(avgPower))
  yl = get(gca,'ylim');
  set(gca,'xlim', freqs_1D([1 end]), 'ylim',[0 yl(2)]);
  legend(lgnd{:}); 
  xlabel(xlbl); ylabel('log(power)');

  

  % 1D, on log scale, no original
  figures(end+1) = de_newFig('fft-1D-log');
  plot(freqs_1D,log(avgPowerModel1),'b','LineWidth',1.5);
  hold on; 
  plot(freqs_1D,log(avgPowerModel2),'r','LineWidth',1.25);
  yl = get(gca,'ylim');
  set(gca,'xlim', freqs_1D([1 end]), 'ylim',[0 yl(2)]);
  legend(lgnd{1:2}); 
  xlabel(xlbl); ylabel('log(power)');

  %1D, diff
  figures(end+1) = de_newFig('fft-1D-log-diff');
  powerDiff = log(avgPowerModel1) - log(avgPowerModel2);
  plot(freqs_1D, powerDiff, 'LineWidth',1.5);
  hold on; 
  plot(freqs_1D, zeros(size(freqs_1D)), '-k', 'LineWidth', 2.0 ); %x=0
  yl = [min(powerDiff) max(powerDiff)];
  yl = [yl(1)-diff(yl)/10 yl(2)+diff(yl)/10];
  set(gca,'xlim', freqs_1D([1 end]), 'ylim',yl);
  legend(lgnd{1:2}); 
  xlabel(xlbl); ylabel('log(power)');
  % Green dot representing cross-over
  %if (isempty(setdiff(mSets.nInput,[31 13])))
  %  plot([6.36], [0], 'g*', 'LineWidth', 10.0);
  %end;
  
  %1D on log scale, difference from Original
  figures(end+1) = de_newFig('fft-1D-log-diff-orig');
  plot(freqs_1D, ([avgPowerOrig - avgPowerModel1 avgPowerOrig - avgPowerModel2]))
  legend('1-diff','2-diff');


  % As 2D
  figures(end+1) = de_newFig('fft-2D');
  avgModel1(1,1) = 1;
  avgModel2(1,1) = 1;
  avgPowerOrig(1,1) = 1;

  subplot(1,3,3); colormap gray;     % LH
  colormap('jet');
  imagesc(fftshift(log(avgModel2)));
  set(gca, 'xtick',[],'ytick',[]);
  subplot(1,3,2); colormap gray;     % Orig
  imagesc(fftshift(log(avgPowerOrig)));  
  set(gca, 'xtick',[],'ytick',[]);
  subplot(1,3,1); colormap gray;
  imagesc(fftshift(log(avgModel1))); % RH
  set(gca, 'xtick',[],'ytick',[]);


  % As 2D
  figures(end+1) = de_newFig('fft-2D-log-diff-orig');
  subplot(1,2,1); colormap default;
  colormap('jet');
  imagesc(log(avgModel1)-log(avgPowerOrig));
  set(gca, 'xtick',[],'ytick',[]);
  subplot(1,2,2); colormap default;
  imagesc(log(avgModel2)-log(avgPowerOrig));
  set(gca, 'xtick',[],'ytick',[]);


  % Diff
  % As 2D
  figures(end+1) = de_newFig('fft-2D-log-diff');
  colormap('jet');
  imagesc(fftshift(log(avgModel1)-log(avgModel2)));
  set(gca, 'xtick',[],'ytick',[]);
  colorbar;
  
  
  % Diff / stats
  % As 1D
  figures(end+1) = de_newFig('fft-1D-log-diff-stats');
  hold on;

  % test at each frequency
  nFreq = size( f{1},2);
  nModels = min( size(f{1},1), size(f{end},1) );
  
  ht  = zeros(nFreq,1); htl = zeros(nFreq,1);
  pt  = zeros(nFreq,1); ptl = zeros(nFreq,1);
  %ha  = []; hal = []; %zeros(size(f,3),1);
  pa  = zeros(nFreq,1); pal = zeros(nFreq,1);

  % Calc stats separately for each frequency
  for i=1:nFreq
    [ht(i), pt(i)] =ttest(    f{1}(1:nModels,i) -    f{end}(1:nModels,i));
    [htl(i),ptl(i)]=ttest(log(f{1}(1:nModels,i))-log(f{end}(1:nModels,i)));
    
    [pa(i), ~,sa(i)] =anova1(    [f{1}(1:nModels,i) f{end}(1:nModels,i)], {'rh','lh'}, 'off');
    [pal(i),~,sal(i)]=anova1(log([f{1}(1:nModels,i) f{end}(1:nModels,i)]), {'rh','lh'}, 'off');
  end;

  good_idx = pal<0.05;
  bad_idx  = pal>0.05;
  pMean = [mean(log(f{1}),1); mean(log(f{end}),1)]; %average over models
  pStd  = std(log(f{1}),0,1) + std(log(f{end}),0,1); %std of the log(diff)
      
  last_zero = 0;
  for i=1:length(good_idx)
    if i<length(good_idx) && ...
       good_idx(i)==1, continue; end;
          
    % we're at a zero.  
    
    % if previous idx=1, then we need to draw polygon
    if (i>1 && good_idx(i-1)==1)
      if (last_zero==0), idx = [1:i];
      else,              idx = [last_zero:i];
      end;
	  bs = pMean(1,idx)-pMean(2,idx);
      st = pStd(idx);
      fr = freqs_1D(idx);

      % This is right-shifted; we need to center if possible.
      if (last_zero>0)
        fr = [mean(fr(1:2)) fr(2:end)];
        st = [mean(st(1:2)) st(2:end)];
        bs = [mean(bs(1:2)) bs(2:end)];
      end;
      if (i<length(good_idx))
        fr = [fr(1:end-1) mean(fr(end-1:end))];
        st = [st(1:end-1) mean(st(end-1:end))];
        bs = [bs(1:end-1) mean(bs(end-1:end))];
      else
        fr = fr(1:end-1);
        st = st(1:end-1);
        bs = bs(1:end-1);
      end;

      fill( [fr fr(end:-1:1)], ...
                  [bs bs(end:-1:1)] + [st(1:end) -st(end:-1:1)], ...
                  'y' );
    end;
          
    last_zero = i;
  end;
    
  plot(freqs_1D, zeros(size(freqs_1D)), 'k', 'LineWidth', 2.0);
  h = [];
  h(end+1) = plot(freqs_1D, pMean(1,:)-pMean(2,:), 'b', 'LineWidth', 2.0);
  h(end+1) = plot(freqs_1D, pMean(1,:)-pMean(2,:) + pStd, 'r--');
  plot(freqs_1D, pMean(1,:)-pMean(2,:) - pStd, 'r--')
  legend(h, {'mean', 'std'}, 'Location', 'NorthEast');
  title('RH - LH');
  xlabel('spatial frequency (cycles/image)');
  ylabel('log(power)');
    
  yl = [min(powerDiff) max(powerDiff)];
  yl = [yl(1)-diff(yl)/10 yl(2)+diff(yl)/10];
  set(gca,'xlim', freqs_1D([1 end]), 'ylim',yl);
 
  %%%%%%%%%%%%%%%%%%%%
  % Do the curve and stats again, but this time with smoothing
  %%%%%%%%%%%%%%%%%%%%
  %keyboard
  
  sigs = [0 0.05 0.1 0.2 0.5 1 3];
  for j=1:length(sigs)

  % Do the smoothing
  sig=sigs(j);%0.2;
  pMeanSmoothed = zeros(size(pMean));
  org = pMean(1,:)-pMean(2,:);
  cvd = zeros(size(freqs_1D));
  for i=1:length(freqs_1D)
    if (sig==0)
      g = zeros(size(freqs_1D));
      g(i) = 1;
    else
      g = normpdf(freqs_1D, freqs_1D(i), sig); % find gaussian at all points, centered around current freq
    end;
    g = g/sum(g); % normalize weights to sum to 1
    cvd(i) = sum(org.*g);
  end;
 
   
  % Smooth the diff
  figures(end+1) = de_newFig(sprintf('fft-1D-log-diff-smoothed%3.2f',sig));
   hold on;
  h = [];
  plot(freqs_1D, zeros(size(freqs_1D)), 'k-', 'LineWidth', 1.5);
  h(end+1) = plot(freqs_1D, org, 'r--'); hold on;
  h(end+1) = plot(freqs_1D, cvd, 'b-', 'LineWidth', 2.0);
  legend(h, {'orig', 'smoothed'}, 'Location', 'NorthEast');
  title(sprintf('RH - LH (\\sigma=%3.2f)', sig));
  xlabel('spatial frequency (cycles/image)');
  ylabel('log(power)');
  yl = [min(powerDiff) max(powerDiff)];
  yl = [yl(1)-diff(yl)/10 yl(2)+diff(yl)/10];
  set(gca,'xlim', freqs_1D([1 end]), 'ylim',yl);
  %print(gcf, guru_getTmpFilename('test','png'), '-dpng'); %close all;



  % Smooth the originals

  sig=sigs(j);%0.2;
  fSm = cell( length(ffts.model), 1 );
  
  for i=1:length(ffts.model)
    nModels = size(ffts.model{i}, 1);
    
    fSm{i} = zeros(nModels, length(freqs_1D));
    
    for j=1:nModels %# models
      for k=1:length(freqs_1D)
        if (sig==0)
          g = zeros(size(freqs_1D));
          g(k) = 1;
        else
          g = normpdf(freqs_1D, freqs_1D(k), sig); % find gaussian at all points, centered around current freq
        end;
        g = g/sum(g); % normalize weights to sum to 1
        fSm{i}(j, k)  = sum(log(f{i}(j,:)).*g);
      end;
    end;
  end;
 
  
  % Diff / stats
  % As 1D
  figures(end+1) = de_newFig(sprintf('fft-1D-log-diff-smoothed%3.2f-stats',sig));
  hold on;

  % test at each frequency
  nFreq = size( fSm{1},2);
  nModels = min( size(fSm{1},1), size(fSm{end},1) );
  
  ht  = zeros(nFreq,1); htl = zeros(nFreq,1);
  pt  = zeros(nFreq,1); ptl = zeros(nFreq,1);
  %ha  = []; hal = []; %zeros(size(f,3),1);
  pa  = zeros(nFreq,1); pal = zeros(nFreq,1);

  % Calc stats separately for each frequency
  for i=1:nFreq
    [htls(i), ptls(i)] =ttest(    fSm{1}(1:nModels,i) -    fSm{end}(1:nModels,i));
    [pals(i), ~,sals(i)] =anova1(    [fSm{1}(1:nModels,i) fSm{end}(1:nModels,i)], {'rh','lh'}, 'off');
  end;

  good_idx = pals<0.05;
  bad_idx  = pals>0.05;
  pMean2 = [mean((fSm{1}),1); mean((fSm{end}),1)]; %average over models
  pStd2  = std((fSm{1}),0,1) + std((fSm{end}),0,1); %std of the log(diff)
  pMean2Diff = pMean2(1,:)-pMean2(2,:);
  
  last_zero = 0;
  for i=1:length(good_idx)
    if i<length(good_idx) && ...
       good_idx(i)==1, continue; end;
          
    % we're at a zero.  
         
    % if previous idx=1, then we need to draw polygon
    if (i>1 && good_idx(i-1)==1)
      if (last_zero==0), idx = [1:i];
      else,              idx = [last_zero:i];
      end;
	  bs = pMean2(1,idx)-pMean2(2,idx);
      st = pStd2(idx);
      fr = freqs_1D(idx);
      
      % This is right-shifted; we need to center if possible.
      if (last_zero>0)
        fr = [mean(fr(1:2)) fr(2:end)];
        st = [mean(st(1:2)) st(2:end)];
        bs = [mean(bs(1:2)) bs(2:end)];
      end;
      if (i<length(good_idx))
        fr = [fr(1:end-1) mean(fr(end-1:end))];
        st = [st(1:end-1) mean(st(end-1:end))];
        bs = [bs(1:end-1) mean(bs(end-1:end))];
      else
        fr = fr(1:end-1);
        st = st(1:end-1);
        bs = bs(1:end-1);
      end;

      fill( [fr fr(end:-1:1)], ...
                  [bs bs(end:-1:1)] + [st(1:end) -st(end:-1:1)], ...
                  'y' );
    end;
          
    last_zero = i;
  end;
    
  plot(freqs_1D, zeros(size(freqs_1D)), 'k', 'LineWidth', 2.0);
  h = [];
  h(end+1) = plot(freqs_1D, pMean2Diff, 'b', 'LineWidth', 2.0);
  h(end+1) = plot(freqs_1D, pMean2Diff + pStd2, 'r--');
  plot(freqs_1D, pMean2Diff - pStd2, 'r--')

  legend(h, {'mean', 'std'}, 'Location', 'NorthEast');
  title(sprintf('RH - LH (\\sigma=%3.2f)', sig));
  xlabel('spatial frequency (cycles/image)');
  ylabel('log(power)');
    
  yl = [min(pMean2(1,:)-pMean2(2,:) - pStd2) max(pMean2(1,:)-pMean2(2,:) + pStd2)];
  set(gca,'xlim', freqs_1D([1 end]), 'ylim',yl);

  %print(gcf, guru_getTmpFilename('test','png'), '-dpng'); %close all;




  % Plot images of LH-stat-sig-different freqeuncies 
  %   and same foR RH
  figures(end+1) = de_newFig(sprintf('fft-1D-statsig-freq-imgs-smooth%3.2f-rh',sig));
  figures(end+1) = de_newFig(sprintf('fft-1D-statsig-freq-imgs-smooth%3.2f-lh',sig));

  rhFreqs = good_idx==1 & pMean2Diff > 0;
  lhFreqs = good_idx==1 & pMean2Diff < 0;

  nImg = size(ffts.orig, 1);
  sz2D = [size(ffts.orig, 2) size(ffts.orig, 3)];
  
  rhImg = zeros(size(ffts.orig));
  lhImg = zeros(size(ffts.orig));
  for i=1:nImg
    rhFFT = squeeze(ffts.orig(i, :, :)) .* ifftshift(guru_freq1to2(freqs_1D(rhFreqs), sz2D));
    rhiFFT = ifft2(rhFFT);
    rhImg(i, :, :) = real(rhiFFT);
    
    lhFFT = squeeze(ffts.orig(i, :, :)) .* ifftshift(guru_freq1to2(freqs_1D(lhFreqs), sz2D));
    lhiFFT = ifft2(lhFFT);
    lhImg(i, :, :) = real(lhiFFT);

    figure(figures(end-1).handle);
    subplot(4,4,i);
    colormap('gray');
    imagesc( squeeze(rhImg(i,:,:)), [min(mSets.data.train.X(:)) max(mSets.data.train.X(:))] );
    set(gca, 'xtick',[],'ytick',[]);

    figure(figures(end).handle);
    subplot(4,4,i);
    colormap('gray');
    imagesc( squeeze(lhImg(i,:,:)), [min(mSets.data.train.X(:)) max(mSets.data.train.X(:))] );
    set(gca, 'xtick',[],'ytick',[]);
  end;
   
  end;   % loop over sigmas
