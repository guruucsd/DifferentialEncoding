function figures = de_PlotFFTs_InLogPowerSpace(mSets, ffts, ftp)
%
%

  error('This code is NO LONGER USED; see de_PlotFFTs_InPowerSpace');
  
  
  figures = de_NewFig('dummy');

  if (~exist('ftp','var'))
      ftp = [4 6 8 9 12];
  end;


  % Map from 2D to 1D

  % Calculate (and collate) all 1D frequencies,
  %   and the POWER at that frequency, for each model,
  %   AND the original images
  
  power1D   = cell( 3,1 );
  error('This needs to be migrated; it is now calculated in the fft stats');

  r Orig at index #1
  [freqs_1D,power1D{1}] = guru_fft2to1(fftshift( reshape(mean(ffts.orig.*conj(ffts.orig),1), [mSets.nInput]) ));

  % Other models at index 2:end
  for i=[1 length(ffts.model)]
    nModels = size(ffts.model{i}, 1);
    nInput  = [size(ffts.model{i}, 3) size(ffts.model{i},4)];
    
    tmp{i} = reshape(mean(ffts.model{i}.*conj(ffts.model{i}),2), [nModels nInput]); %average over all images
    power1D{1+i}   = zeros(nModels, length(freqs_1D));
    
    for j=1:nModels %# models
        [~,power1D{1+i}(j,:)] = guru_fft2to1( fftshift(squeeze(tmp{i}(j,:,:))) );
    end;
  end;

  % For convenience
  avgPowerOrig_1D   = power1D{1};
  avgPowerModel1_1D = mean(power1D{2},1);
  avgPowerModel2_1D = mean(power1D{end},1);

  avgPowerModel1_2D = (reshape(mean(mean(ffts.model{1}, 1)), mSets.nInput));
  avgPowerModel2_2D = (reshape(mean(mean(ffts.model{end}, 1)), mSets.nInput));
  avgPowerOrig_2D   = (reshape(mean(ffts.orig, 1), mSets.nInput));

  % Common plotting parts
  lgnd = {sprintf('LVF/RH (\\sigma=%3.1f)', mSets.sigma(1)), ...
          sprintf('RVF/LH (\\sigma=%3.1f)', mSets.sigma(end))};
  xlbl = 'spatial frequency (cycles)';

  
  %%%%%%%%%%%%%%%%%%%
  % Power (models vs orig)
  if (ismember(1, ftp))
      figures(end+1) = de_NewFig('fft-1D');
      
      plot(freqs_1D, [avgPowerModel1_1D; avgPowerModel2_1D; avgPowerOrig_1D])

      set(gca,'xlim',[0 max(freqs_1D)]);
      legend(lgnd{:}, 'Orig');
      xlabel(xlbl); ylabel('power');
  end;
  
  
  %%%%%%%%%%%%%%%%%%%
  % Power (models vs each other only)
  if (ismember(2, ftp))
      figures(end+1) = de_NewFig('fft-1D-noorig');
      
      plot(freqs_1D, [avgPowerModel1_1D; avgPowerModel2_1D])
      
      set(gca,'xlim',[0 max(freqs_1D)]);
      legend(lgnd{:}); xlabel(xlbl); ylabel('power');
  end;
  
  
  %%%%%%%%%%%%%%%%%%%
  % Power (difference between models)
  if (ismember(3, ftp))
      figures(end+1) = de_NewFig('fft-1D-diff-orig');

      plot(freqs_1D, ([avgPowerOrig_1D - avgPowerModel1_1D; avgPowerOrig_1D - avgPowerModel2_1D]))

      legend('1-diff','2-diff');
  end;
  
  
  %%%%%%%%%%%%%%%%%%%
  % Log-power (1D; models vs orig) 
  if (ismember(4, ftp))
      figures(end+1) = de_NewFig('fft-1D-log-all3');
      
      plot(freqs_1D, log10([avgPowerModel1_1D; avgPowerModel2_1D; avgPowerOrig_1D]))
      
      yl = get(gca,'ylim');
      set(gca,'xlim', [min(freqs_1D) max(freqs_1D)], 'ylim',[yl(1) yl(2)]);
      legend(lgnd{:}, 'Orig'); xlabel(xlbl); ylabel('log_{10}(power)');
  end;


  %%%%%%%%%%%%%%%%%%%
  % Log-power (1D; models vs each other)
  if (ismember(5, ftp))
      figures(end+1) = de_NewFig('fft-1D-log');
      hold on; 

      plot(freqs_1D,log10(avgPowerModel1_1D),'b','LineWidth',1.5);
      plot(freqs_1D,log10(avgPowerModel2_1D),'r','LineWidth',1.25);

      yl = get(gca,'ylim');
      set(gca,'xlim', [0 max(freqs_1D)], 'ylim',[yl(1) yl(2)]);
      legend(lgnd{:}); xlabel(xlbl); ylabel('log_{10}(power)');
  end;
  
  
  %%%%%%%%%%%%%%%%%%%
  % Greyscale Log-spectrum (models vs original)
  if (ismember(7, ftp))
      figures(end+1) = de_NewFig('fft-2D');
      
      subplot(1,3,3); colormap gray;     % LH
      imagesc(fftshift(log10(avgPowerModel2_2D)));
      set(gca, 'xtick',[],'ytick',[]);
      subplot(1,3,2); colormap gray;     % Orig
      imagesc(fftshift(log10(avgPowerOrig_2D)));  
      set(gca, 'xtick',[],'ytick',[]);
      subplot(1,3,1); colormap gray;
      imagesc(fftshift(log10(avgPowerModel1_2D))); % RH
      set(gca, 'xtick',[],'ytick',[]);
  end;


  %%%%%%%%%%%%%%%%%%%
  % Colored Log-spectrum (models difference from orig)
  if (ismember(8, ftp))
      pd1  = avgPowerModel1_2D-avgPowerOrig_2D; 
      pd2  = avgPowerModel2_2D-avgPowerOrig_2D; 

      pd1(abs(pd1)<1) = 1;
      pd2(abs(pd2)<1) = 1;
      pd1  = sign(pd1).*log10(abs(pd1));
      pd2  = sign(pd2).*log10(abs(pd2));

      figures(end+1) = de_NewFig('fft-2D-log-diff-orig');
      subplot(1,2,1); colormap jet;
      
      imagesc(fftshift(pd1));
      set(gca, 'xtick',[],'ytick',[]);
      colorbar;
      
      subplot(1,2,2); colormap default;
      imagesc(fftshift(pd2));
      set(gca, 'xtick',[],'ytick',[]);
      colorbar;
      
      clear('pd1','pd2');
  end;

  %%%%%%%%%%%%%%%%%%%
  % Diff as normalized 2D
  if (ismember(9, ftp))
      figures(end+1) = de_NewFig('fft-2D-log-diff');
      colormap jet;
      
      pd=-(abs(avgPowerOrig_2D-avgPowerModel1_2D)-abs(avgPowerOrig_2D-avgPowerModel2_2D));
      pd(abs(pd)<1) = 1;
      pd = sign(pd).*log10(abs(pd));
      
      imagesc(fftshift( pd ));
      set(gca, 'xtick',[],'ytick',[]);
      caxis( [-abs(max(caxis)) abs(max(caxis))]); %make sure green is always ZERO
      colorbar;

      clear('pd');
  end;

  
  %%%%%%%%%%%%%%%%%%%%
  % Do the curve and stats again, but this time with smoothing
  %%%%%%%%%%%%%%%%%%%%
  
  if (any(ismember([6 12 13], ftp)))


      % Each calculation and figure will be done for a set of
      %   gaussian smoothing kernels, as these 1D spatial frequencies
      %   don't have a lot of data points each, and tend to be
      %   pretty noisy.
      %
      sigs = [0 0.5 1 2];
      for si=1:length(sigs)
          sig=sigs(si);%0.2;
        

          % In order to properly do stats, we need to combine
          %   two things: 
          %     1. calculating (and collecting) 1D frequencies,  
          %     2. smoothing them (but not the average... ALL of them
          %
          % NOTE NOTE NOTE NOTE NOTE:
          %   smoothing should happen in LOG space,
          %   since values at higher frequencies SWAMP
          %   the values at lower frequencies, making
          %   smoothing virtually meaningless 
          %   when NOT in log space.
          %
          % So, LOG, THEN smooth.
          power1D_Sm = cell( 2, 1 );

          for i=[1 length(ffts.model)]
            nModels = size(ffts.model{i}, 1);
            power1D_Sm{i}  = zeros(nModels, length(freqs_1D));
            
            for j=1:nModels %# models
              for k=1:length(freqs_1D)
                if (sig==0)
                  g = zeros(size(freqs_1D));
                  g(k) = 1;
                else
                  g = normpdf(freqs_1D, freqs_1D(k), sig); % find gaussian at all points, centered around current freq
                end;
                g = g/sum(g); % normalize weights to sum to 1
                
                tmp = power1D{1+i}(j,:); % transform to log space
                tmp(abs(tmp)<1)=1;
                tmp = sign(tmp).*log10(abs(tmp));
                
                power1D_Sm{i}(j, k)  = sum(tmp.*g); %convolve
              end;
            end;
          end;
          pMean2 = [mean(power1D_Sm{1},1);    mean(power1D_Sm{end},1)]; %average over models
          pStd2  =  std (power1D_Sm{1},0,1) + std (power1D_Sm{end},0,1); %std 


          % Calculate the mean diff, 
          %   up and down 1 sd as well
          %
          pm2d     = pMean2(1,:)-pMean2(2,:);   % original diff
          pm2d_up1 = pm2d+pStd2;
          pm2d_dn1 = pm2d-pStd2;

%          pm2d    (abs(pm2d)<1)=1;
%          pm2d_up1(abs(pm2d_up1)<1)=1;
%          pm2d_dn1(abs(pm2d_dn1)<1)=1;
          
%          pm2d     = sign(pm2d)    .*log10(abs(pm2d));
%          pm2d_up1 = sign(pm2d_up1).*log10(abs(pm2d_up1));
%          pm2d_dn1 = sign(pm2d_dn1).*log10(abs(pm2d_dn1));
            
        
          %%%%%%%%%%%%%%%%%%%
          % Log-power (difference between models)
          if (ismember(6, ftp))
              % can put orig here as well

              %org = mean(power1D{2},1) - mean(power1D{end},1); %average over model instances for LH&RH
              %org(abs(org)<1) = 1;
              %org  = sign(org).*log10(abs(org));

              tmp1 = power1D{2};   tmp2 = power1D{end};
              tmp1(abs(tmp1)<1)=1; tmp2(abs(tmp2)<1) = 1;
              tmp1 = sign(tmp1).*log10(abs(tmp1)); tmp2 = sign(tmp2).*log10(abs(tmp2));
              org = mean(tmp1,1) - mean(tmp2,1);

              h = []; %to pass to legend
              figures(end+1) = de_NewFig(sprintf('fft-1D-log-diff-smoothed-[%3.2f]',sig));
              hold on; 

              plot(freqs_1D, zeros(size(freqs_1D)), 'k-', 'LineWidth', 1.5);
              h(end+1) = plot(freqs_1D, org, 'r--'); hold on;          % original
              h(end+1) = plot(freqs_1D, pm2d, 'b-', 'LineWidth', 2.0);  % convolved version
              
              legend(h, {'orig', 'smoothed'}, 'Location', 'NorthEast');
              title(sprintf('RH - LH (\\sigma=%3.2f)', sig));
              xlabel('spatial frequency (cycles/image)');
              ylabel('log_{10}(power)');

              yl = [min(org) max(org)]; %orig has more extreme values than convolved
              yl = [yl(1)-diff(yl)/10 yl(2)+diff(yl)/10];
              set(gca,'xlim', freqs_1D([1 end]), 'ylim',yl);
          end;
        
          
          %%%%%%%%%%%%%%%%%%%
          % Diff / stats
          % As 1D
          if (any(ismember([12 13], ftp)))
    
              % Now that we've smoothed each model instance's
              %   power spectrum according to the current Gaussian kernel,
              %   we need to do a statistical test at each frequency.
              %
              nFreq = size( power1D_Sm{1},2);
              nModels = min( size(power1D_Sm{1},1), size(power1D_Sm{end},1) );
              
              ht  = zeros(nFreq,1); htl = zeros(nFreq,1);
              pt  = zeros(nFreq,1); ptl = zeros(nFreq,1);
              %ha  = []; hal = []; %zeros(size(f,3),1);
              pa  = zeros(nFreq,1); pal = zeros(nFreq,1);
            
              % Calc stats separately for each frequency
              for i=1:nFreq
                [htls(i), ptls(i)]   =ttest (    power1D_Sm{1}(1:nModels,i) -    power1D_Sm{end}(1:nModels,i));
                [pals(i), ~,sals(i)] =anova1(    [power1D_Sm{1}(1:nModels,i) power1D_Sm{end}(1:nModels,i)], {'rh','lh'}, 'off');
              end;
            
              % Now that we've done the statistical tests,
              %   select only the frequencies that show a "significant"
              %   difference.
              good_idx = pals<=0.05;
              bad_idx  = pals>0.05;
          end;
          
          
              
          %%%%%%%%%%%%%%%%%%%
          % Plot 1D diff, with stats highlighted
          if (ismember(12, ftp))
              
              % Finally ready to start drawing!
              figures(end+1) = de_NewFig(sprintf('fft-1D-log-diff-smoothed-%3.2f-stats',sig));
              hold on;
                           
              % In order to visualize the stats, we want to highlight
              %   bands of statistically significant frequencies
              %   all within the same polygon.
              %
              % This code figures out the x-range of each of those polygons,
              %   and then the (x,y) coordinates of each point that makes
              %   up that polygon
              %
              last_zero = 0;
              for i=1:length(good_idx)
                if i<length(good_idx) && ...
                   good_idx(i)==1, continue; end;
                      
                % we're at a zero.  
                     
                % if previous idx=1, then we need to draw polygon
                if (i>1 && good_idx(i-1)==1)
                  if (last_zero==0), drawidx = [1:i];
                  else,              drawidx = [last_zero:i];
                  end;
                  fr = freqs_1D(drawidx);
                  up = pm2d_up1(drawidx);
                  dn = pm2d_dn1(drawidx);
                  
                  % This is right-shifted; we need to center if possible.
                  if (last_zero>0)
                    fr = [mean(fr(1:2)) fr(2:end)];
                    up = [mean(up(1:2)) up(2:end)];
                    dn = [mean(dn(1:2)) dn(2:end)];
                  end;
                  if (i<length(good_idx))
                    fr = [fr(1:end-1) mean(fr(end-1:end))];
                    up = [up(1:end-1) mean(up(end-1:end))];
                    dn = [dn(1:end-1) mean(dn(end-1:end))];
                  else
                    fr = fr(1:end-1);
                    up = up(1:end-1);
                    dn = dn(1:end-1);
                  end;
            
                  fill( [fr fr(end:-1:1)], [up dn(end:-1:1)], 'y' );
                end;
                      
                last_zero = i;
              end;
            
              h = []; %to pass to legend
              
              plot(freqs_1D, zeros(size(freqs_1D)), 'k', 'LineWidth', 2.0);
              h(end+1) = plot(freqs_1D, pm2d, 'b', 'LineWidth', 2.0);
              h(end+1) = plot(freqs_1D, pm2d_up1, 'r--');
                         plot(freqs_1D, pm2d_dn1, 'r--');
            
              legend(h, {'mean', 'std'}, 'Location', 'NorthEast');
              title(sprintf('RH - LH (\\sigma=%3.2f)', sig));
              xlabel('spatial frequency (cycles/image)');
              ylabel('log_{10}(power)');
                
              yl = [min(pm2d_dn1) max(pm2d_up1)];
              set(gca,'xlim', freqs_1D([1 end]), 'ylim',yl);
          end;
        
        
          %%%%%%%%%%%%%%%%%%%
          % Plot images of LH-stat-sig-different freqeuncies 
          %   and same foR RH
          if (ismember(13,ftp))
              figures(end+1) = de_NewFig(sprintf('fft-1D-statsig-freq-imgs-smooth-%3.2f-rh',sig));
              figures(end+1) = de_NewFig(sprintf('fft-1D-statsig-freq-imgs-smooth-%3.2f-lh',sig));
            
              rhFreqs = good_idx==1 & pMean2Diff > 0;
              lhFreqs = good_idx==1 & pMean2Diff < 0;
            
              nImg = size(ffts.orig, 1);
              sz2D = [size(ffts.orig, 2) size(ffts.orig, 3)];
              
              rhImg = zeros(size(ffts.orig));
              lhImg = zeros(size(ffts.orig));
              
              selectedImages  = unique(round(linspace(1,nImg,20)));  % max 20 images
              nSelectedImages = length(selectedImages);
              [nRows,nCols]   = guru_optSubplots(nSelectedImages);
            
              for ii=1:nSelectedImages
                i = selectedImages(ii);
                rhFFT = squeeze(ffts.orig(i, :, :)) .* ifftshift(guru_freq1to2(freqs_1D(rhFreqs), sz2D));
                rhiFFT = ifft2(rhFFT);
                rhImg(i, :, :) = real(rhiFFT);
                
                lhFFT = squeeze(ffts.orig(i, :, :)) .* ifftshift(guru_freq1to2(freqs_1D(lhFreqs), sz2D));
                lhiFFT = ifft2(lhFFT);
                lhImg(i, :, :) = real(lhiFFT);
            
                figure(figures(end-1).handle);
                subplot(nRows, nCols, ii);
                colormap('gray');
                if (any(rhFreqs))
                    clim = [min(min(min(rhImg(i,:,:)))) max(max(max(rhImg(i,:,:))))];
                    if (diff(clim)==0), clim = [clim(1)-1 clim(1)+1]; end;
                    imagesc( squeeze(rhImg(i,:,:)), clim);
                end;
                set(gca, 'xtick',[],'ytick',[]);
            
                figure(figures(end).handle);
                subplot(nRows, nCols, ii);
                colormap('gray');
                if (any(lhFreqs))
                    clim = [min(min(min(lhImg(i,:,:)))) max(max(max(lhImg(i,:,:))))];
                    if (diff(clim)==0), clim = [clim(1)-1 clim(1)+1]; end;
                    imagesc( squeeze(lhImg(i,:,:)), clim );
                end;
                set(gca, 'xtick',[],'ytick',[]);
              end;
          end;   
      end; %loop over sigmas
  end;   % if member
