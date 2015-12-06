function figures = de_PlotFFTs(mSets, ffts, ftp)
%
%
  figures = de_NewFig('dummy');

  if (~exist('ftp','var'))
      ftp = {'fft-1D-log' ...
             'fft-2D-log-diff-orig' ...
             'fft-2D-log-diff' ...
             'fft-1D-log-diff-ratio-smoothed' ...
             'fft-1D-log-diff-smoothed-stats'};
  end;

  % For convenience
  unsmoothed_idx    = find(ffts.smoothing_sigmas==0.0);
  avgPowerOrig_1D   = squeeze(     ffts.orig1D.power      (unsmoothed_idx,:,:));
  avgPowerModel1_1D = squeeze(mean(ffts.model1D.power{1}  (unsmoothed_idx,:,:),2))';
  avgPowerModel2_1D = squeeze(mean(ffts.model1D.power{end}(unsmoothed_idx,:,:),2))';

  avgPowerOrig_2D   = (reshape(     mean(ffts.orig2D      .*conj(ffts.orig2D),       1),     ffts.fftsz));
  avgPowerModel1_2D = (reshape(mean(mean(ffts.model2D{1}  .*conj(ffts.model2D{1}),   2), 1), ffts.fftsz));
  avgPowerModel2_2D = (reshape(mean(mean(ffts.model2D{end}.*conj(ffts.model2D{end}), 2), 1), ffts.fftsz));

  % Common plotting parts
  lgnd = {sprintf('LVF/RH (\\sigma=%3.1f)', mSets.sigma(1)), ...
          sprintf('RVF/LH (\\sigma=%3.1f)', mSets.sigma(end))};
  XLAB = 'spatial frequency (cycles)';

  for fi=1:length(ftp)

      figures(end+1) = de_NewFig(ftp{fi});
      hold on;

      %%%%%%%%%%%%%%%%%%%
      % Power (models vs orig)
      if (strcmp(ftp{fi}, 'fft-1D'))
          plot(ffts.freqs_1D, [avgPowerModel1_1D; avgPowerModel2_1D; avgPowerOrig_1D])

          set(gca,'xlim',[0 max(ffts.freqs_1D)]);
          legend(lgnd{:}, 'Orig');
          xlabel(guru_text2label(XLAB)); ylabel('power');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Power (models vs each other only)
      if (strcmp(ftp{fi}, 'fft-1D-noorig'))
          plot(ffts.freqs_1D, [avgPowerModel1_1D; avgPowerModel2_1D])

          set(gca,'xlim',[0 max(ffts.freqs_1D)]);
          legend(lgnd{:}); xlabel(guru_text2label(XLAB)); ylabel('power');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Power (difference between models)
      if (strcmp(ftp{fi}, 'fft-1D-diff-orig'))
          plot(ffts.freqs_1D, ([avgPowerOrig_1D - avgPowerModel1_1D; avgPowerOrig_1D - avgPowerModel2_1D]))

          legend('1-diff','2-diff');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Log-power (1D; models vs orig)
      if (strcmp(ftp{fi}, 'fft-1D-log-all3'))
          plot(ffts.freqs_1D, log10([avgPowerModel1_1D; avgPowerModel2_1D; avgPowerOrig_1D]))

          yl = get(gca,'ylim');
          set(gca,'xlim', [min(ffts.freqs_1D) max(ffts.freqs_1D)], 'ylim',[yl(1) yl(2)]);
          legend(lgnd{:}, 'Orig'); xlabel(guru_text2label(XLAB)); ylabel('log_{10}(power)');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Log-power (1D; models vs each other)
      if (strcmp(ftp{fi}, 'fft-1D-log'))
          plot(ffts.freqs_1D,log10(avgPowerModel1_1D),'b','LineWidth',1.5);
          plot(ffts.freqs_1D,log10(avgPowerModel2_1D),'r','LineWidth',1.25);

          yl = get(gca,'ylim');
          set(gca,'xlim', [0 max(ffts.freqs_1D)], 'ylim',[yl(1) yl(2)]);
          legend(lgnd{:}); xlabel(guru_text2label(XLAB)); ylabel('log_{10}(power)');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Greyscale Log-spectrum (models vs original)
      if (strcmp(ftp{fi}, 'fft-2D'))
          subplot(1,3,3); colormap jet;     % LH
          title('LH');
          imagesc(fftshift(log10(avgPowerModel2_2D)));
          set(gca, 'xtick',[],'ytick',[]);

          subplot(1,3,2); colormap jet;     % Orig
          title('LH');
          imagesc(fftshift(log10(avgPowerOrig_2D)));
          set(gca, 'xtick',[],'ytick',[]);

          subplot(1,3,1); colormap jet;
          title('RH');
          imagesc(fftshift(log10(avgPowerModel1_2D))); % RH
          set(gca, 'xtick',[],'ytick',[]);
      end;


      %%%%%%%%%%%%%%%%%%%
      % Colored Log-spectrum (models difference from orig)
      if (strcmp(ftp{fi}, 'fft-2D-log-diff-orig'))
          pd1  = avgPowerModel1_2D-avgPowerOrig_2D;
          pd2  = avgPowerModel2_2D-avgPowerOrig_2D;

          pd1(abs(pd1)<1) = 1;
          pd2(abs(pd2)<1) = 1;
          pd1  = sign(pd1).*log10(abs(pd1));
          pd2  = sign(pd2).*log10(abs(pd2));


          subplot(1,2,1); colormap jet;
          title('LH - orig');
          imagesc(fftshift(pd2));
          set(gca, 'xtick',[],'ytick',[]);
          colorbar;

          subplot(1,2,2); colormap jet;
          title('RH - orig');
          imagesc(fftshift(pd1));
          set(gca, 'xtick',[],'ytick',[]);
          colorbar;

          clear('pd1','pd2');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Colored Log-spectrum (models difference from orig)
      if (strcmp(ftp{fi}, 'fft-2D-log-diff-ratio'))
          pd1  = avgPowerModel1_2D-avgPowerOrig_2D;
          pd2  = avgPowerModel2_2D-avgPowerOrig_2D;

%          pd1(abs(pd1)<1) = 1;
%          pd2(abs(pd2)<1) = 1;
%          pd1  = sign(pd1).*log10(abs(pd1));
%          pd2  = sign(pd2).*log10(abs(pd2));

          hold on;
          rat = fftshift(pd1)./fftshift(pd2);

          title('Ratio of differences to original');
          imagesc( log10(abs(rat)) );
          caxis( [-1 1] ); %make sure green is always ZERO

          axis('tight');
          set(gca, 'xtick',[],'ytick',[]);
          colorbar;

          clear('pd1','pd2');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Diff as normalized 2D
      if (strcmp(ftp{fi}, 'fft-2D-log-diff'))

          % We want + to be "better RH", which means negative value (smaller difference from orig)
          pd=-(abs(avgPowerOrig_2D-avgPowerModel1_2D)-abs(avgPowerOrig_2D-avgPowerModel2_2D));
          pd(abs(pd)<1) = 1;
          pd = sign(pd).*log10(abs(pd));

          colormap jet;
          imagesc(fftshift( pd ));
          axis('tight');
          set(gca, 'xtick',[],'ytick',[]);

          caxis( [-abs(max(caxis)) abs(max(caxis))]); %make sure green is always ZERO
          colorbar;

          clear('pd');
      end;


      %%%%%%%%%%%%%%%%%%%%
      % Do the curve and stats again, but this time with smoothing
      %%%%%%%%%%%%%%%%%%%%

      if (any(ismember({'fft-1D-log-diff-smoothed' ...
                        'fft-1D-log-diff-smoothed-stats' ...
                        'fft-1D-statsig-freq-imgs-smooth-lh' ...
                        'fft-1D-statsig-freq-imgs-smooth-lh' ...
                        }, ftp{fi})))

          % Close the dummy figure created in the above loop
          close(figures(end).handle);
          figures = figures(1:end-1);

          % Each calculation and figure will be done for a set of
          %   gaussian smoothing kernels, as these 1D spatial frequencies
          %   don't have a lot of data points each, and tend to be
          %   pretty noisy.
          %
          for si=1:length(ffts.smoothing_sigmas)
              sig=ffts.smoothing_sigmas(si);%0.2;


              % Calculate the mean diff,
              %   up and down 1 sd as well
              %
              pMean2 = [squeeze(mean(ffts.model1D.power{1}(si,:,:),2))';    squeeze(mean(ffts.model1D.power{end}(si,:,:),2))']; %average over models
              pStd2  =  squeeze(std (ffts.model1D.power{1}(si,:,:),0,2))' + squeeze(std (ffts.model1D.power{end}(si,:,:),0,2))'; %std

              pm2d     = pMean2(1,:)-pMean2(2,:);   % original diff
              pm2d_up1 = pm2d+pStd2;
              pm2d_dn1 = pm2d-pStd2;

              pm2d    (abs(pm2d)<1)=1;
              pm2d_up1(abs(pm2d_up1)<1)=1;
              pm2d_dn1(abs(pm2d_dn1)<1)=1;

              pm2d     = sign(pm2d)    .*log10(abs(pm2d));
              pm2d_up1 = sign(pm2d_up1).*log10(abs(pm2d_up1));
              pm2d_dn1 = sign(pm2d_dn1).*log10(abs(pm2d_dn1));


              %%%%%%%%%%%%%%%%%%%
              % Log-power (difference between models)
              if (strcmp(ftp{fi}, 'fft-1D-log-diff-smoothed'))

                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;

                  % can put orig here as well
                  org = avgPowerModel1_1D - avgPowerModel2_1D; %average over model instances for LH&RH
                  %pStd  = std (ffts.model1D.power{1},[],1) + std (ffts.model1D.power{end},0,1); %std of the power
                  org(abs(org)<1) = 1;
                  org  = sign(org).*log10(abs(org));

                  h = []; %to pass to legend

                  plot(ffts.freqs_1D, zeros(size(ffts.freqs_1D)), 'k-', 'LineWidth', 1.5);
                  h(end+1) = plot(ffts.freqs_1D, org, 'r--'); hold on;          % original
                  h(end+1) = plot(ffts.freqs_1D, pm2d, 'b-', 'LineWidth', 2.0);  % convolved version

                  legend(h, {'orig', 'smoothed'}, 'Location', 'NorthEast');
                  title(sprintf('RH - LH (\\sigma=%3.2f)', sig));
                  xlabel('spatial frequency (cycles/image)');
                  ylabel('log_{10}(power)');

                  yl = [min(org) max(org)]; %orig has more extreme values than convolved
                  yl = [yl(1)-diff(yl)/10 yl(2)+diff(yl)/10];
                  set(gca,'xlim', ffts.freqs_1D([1 end]), 'ylim',yl);
              end;


              %%%%%%%%%%%%%%%%%%%
              % Log-power (difference between models)
              if (strcmp(ftp{fi}, 'fft-1D-log-diff-ratio-smoothed'))
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;

                  % can put orig here as well

                  h = []; %to pass to legend

                  plot(ffts.freqs_1D, zeros(size(ffts.freqs_1D)), 'k-', 'LineWidth', 1.5);
                  h(end+1) = plot(ffts.freqs_1D, abs(pMean2(1,:)./pMean2(2,:)), 'b-', 'LineWidth', 2.0);  % convolved version

                  legend(h, {'orig'}, 'Location', 'NorthEast');
                  title(sprintf('RH - LH (\\sigma=%3.2f)', sig));
                  xlabel('spatial frequency (cycles/image)');
                  ylabel('log_{10}(power)');

    %              yl = [min(org) max(org)]; %orig has more extreme values than convolved
    %              yl = [yl(1)-diff(yl)/10 yl(2)+diff(yl)/10];
    %              set(gca,'xlim', ffts.freqs_1D([1 end]), 'ylim',yl);
              end;



              %%%%%%%%%%%%%%%%%%%
              % Plot 1D diff, with stats highlighted
              if (strcmp(ftp{fi}, 'fft-1D-log-diff-smoothed-stats'))
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;

                  % Now that we've done the statistical tests,
                  %   select only the frequencies that show a "significant"
                  %   difference.
                  good_idx = ffts.model1D.pals<=0.05;
                  bad_idx  = ffts.model1D.pals>0.05;

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
                      fr = ffts.freqs_1D(drawidx);
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

                  plot(ffts.freqs_1D, zeros(size(ffts.freqs_1D)), 'k', 'LineWidth', 2.0);
                  h(end+1) = plot(ffts.freqs_1D, pm2d, 'b', 'LineWidth', 4.0);
                  h(end+1) = plot(ffts.freqs_1D, pm2d_up1, 'r--', 'LineWidth', 2.0);
                             plot(ffts.freqs_1D, pm2d_dn1, 'r--', 'LineWidth', 2.0);

                  legend(h, {'mean', 'std'}, 'Location', 'NorthEast');
                  title(sprintf('RH - LH (\\sigma=%3.2f)', sig));
                  xlabel('spatial frequency (cycles/image)');
                  ylabel('log_{10}(power)');

                  yl = [min(pm2d_dn1) max(pm2d_up1)];
                  set(gca,'xlim', ffts.freqs_1D([1 end]), 'ylim',yl);
              end;


              %%%%%%%%%%%%%%%%%%%
              % Plot images of LH-stat-sig-different freqeuncies
              %   and same foR RH
              if (strcmp(ftp{fi}, 'fft-1D-statsig-freq-imgs-smooth-rh'))
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;

                  rhFreqs = good_idx==1 & pMean2Diff > 0;
                  rhImg = zeros(size(ffts.orig));

                  sz2D = [size(ffts.orig, 2) size(ffts.orig, 3)];
                  selectedImages  = unique(round(linspace(1,nImg,20)));  % max 20 images
                  nSelectedImages = length(selectedImages);
                  [nRows,nCols]   = guru_optSubplots(nSelectedImages);


                  for ii=1:nSelectedImages
                    i = selectedImages(ii);
                    rhFFT = squeeze(ffts.orig(i, :, :)) .* ifftshift(guru_freq1to2(ffts.freqs_1D(rhFreqs), sz2D));
                    rhiFFT = ifft2(rhFFT);
                    rhImg(i, :, :) = real(rhiFFT);

                    subplot(nRows, nCols, ii);
                    colormap('gray');
                    if (any(rhFreqs))
                        clim = [min(min(min(rhImg(i,:,:)))) max(max(max(rhImg(i,:,:))))];
                        if (diff(clim)==0), clim = [clim(1)-1 clim(1)+1]; end;
                        imagesc( squeeze(rhImg(i,:,:)), clim);
                    end;
                    set(gca, 'xtick',[],'ytick',[]);

                    set(gca, 'xtick',[],'ytick',[]);
                  end;
              end;




              if (strcmp(ftp{fi}, 'fft-1D-statsig-freq-imgs-smooth-lh'))
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;

                  lhFreqs = good_idx==1 & pMean2Diff < 0;
                  lhImg = zeros(size(ffts.orig));

                  sz2D = [size(ffts.orig, 2) size(ffts.orig, 3)];
                  selectedImages  = unique(round(linspace(1,nImg,20)));  % max 20 images
                  nSelectedImages = length(selectedImages);
                  [nRows,nCols]   = guru_optSubplots(nSelectedImages);

                  for ii=1:nSelectedImages
                    i = selectedImages(ii);
                    lhFFT = squeeze(ffts.orig(i, :, :)) .* ifftshift(guru_freq1to2(ffts.freqs_1D(lhFreqs), sz2D));
                    lhiFFT = ifft2(lhFFT);
                    lhImg(i, :, :) = real(lhiFFT);


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

    end; % looping
