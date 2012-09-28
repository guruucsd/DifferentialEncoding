function figures = de_PlotFFTs(mSets, ffts, ftp)
%
%
%  global selectedImages_

  figures = de_NewFig('dummy');
  if (~exist('ftp','var'))
      if (length(mSets.sigma)==1)
          ftp = {};
          return;
      else
          ftp = {'fft-1D-log' ...                   % original 1d curves
                 'fft-1D-err-diff' ...
                 'fft-2D-log-diff-orig' ...         % 2D, each difference from original images
                 'fft-2D-log-diff' ...              % 2D, difference from each other
                 'fft-1D-log-diff-pct-smoothed' ...
                 'fft-1D-log-diff-smoothed-stats' ...
                 'fft-1D-statsig-freq-imgs-smooth-rh' ...
                 'fft-1D-statsig-freq-imgs-smooth-lh' ...
                 'fft-2D-statsig-recon' ...
                 'fft-2D-log-diff-statsig' };
      end;
  end;

  % Reconstitute to merge old with new!
	ffts = struct('smoothing_sigmas', ffts.orig.smoothing_sigmas, ...
				  'freqs_1D',         ffts.orig.freqs_1D, ...
				  'fftSz',            ffts.orig.fftsz, ...
				  'padfactor',        ffts.orig.padfactor, ...
				  'orig1D',           struct('power', ffts.orig.power1D{1}), ...
				  'model1D',          struct('power', {ffts.model.power1D}), ...
				  'orig2D',           ffts.orig.ffts, ...
				  'model2D',          {ffts.model.ffts}, ...
				  'pals',             ffts.pals ...
				 );

  RH_IDX = 1; LH_IDX = length(ffts.model2D);

  % For convenience
  unsmoothed_idx    = find(ffts.smoothing_sigmas==0.0);
  avgPowerOrig_1D   = reshape(     ffts.orig1D.power          (unsmoothed_idx,:,:),    size(ffts.freqs_1D));
  avgPowerModelRH_1D = reshape(mean(ffts.model1D.power{RH_IDX}(unsmoothed_idx,:,:),2), size(ffts.freqs_1D));
  avgPowerModelLH_1D = reshape(mean(ffts.model1D.power{LH_IDX}(unsmoothed_idx,:,:),2), size(ffts.freqs_1D));

  avgPowerOrig_2D   = (reshape(     mean(ffts.orig2D          .*conj(ffts.orig2D),       2),     ffts.fftSz));
  avgPowerModelRH_2D = (reshape(mean(mean(ffts.model2D{RH_IDX}.*conj(ffts.model2D{RH_IDX}),   2), 1), ffts.fftSz));
  avgPowerModelLH_2D = (reshape(mean(mean(ffts.model2D{LH_IDX}.*conj(ffts.model2D{LH_IDX}), 2), 1), ffts.fftSz));


  % Common plotting parts
  lgnd = {sprintf('LVF/RH (\\sigma=%3.1f)', mSets.sigma(RH_IDX)), ...
          sprintf('RVF/LH (\\sigma=%3.1f)', mSets.sigma(LH_IDX))};

  for fi=1:length(ftp)
  
      figures(end+1) = de_NewFig(ftp{fi});
      hold on; 
  
      %%%%%%%%%%%%%%%%%%%
      % Power (models vs orig)
      if (strcmp(ftp{fi}, 'fft-1D'))
          plot(ffts.freqs_1D, [avgPowerModelRH_1D; avgPowerModelLH_1D; avgPowerOrig_1D])
    
          set(gca,'xlim',[0 max(ffts.freqs_1D)]);
          legend(lgnd{:}, 'Orig');
          xlabel('spatial frequency (cycles)'); ylabel('power');
          title('1D frequency spectrum');
      end;
      %%%%%%%%%%%%%%%%%%%
      % Log-power (1D; models vs orig) 
      if (strcmp(ftp{fi}, 'fft-1D-log'))
          semilogy(ffts.freqs_1D, log10(1+[avgPowerModelRH_1D; avgPowerModelLH_1D; avgPowerOrig_1D]))
          
          set(gca,'xlim', ffts.freqs_1D([1 end]));
          legend(lgnd{:}, 'Orig'); xlabel('spatial frequency (cycles)'); ylabel('Power (log_{10} scale)');
          title('1D frequency spectrum (log(power+1))');
      end;
          
      
      %%%%%%%%%%%%%%%%%%%
      % Power (models vs each other only)
      if (strcmp(ftp{fi}, 'fft-1D-noorig'))
          plot(ffts.freqs_1D, [avgPowerModelRH_1D; avgPowerModelLH_1D])
          
          set(gca,'xlim',[0 max(ffts.freqs_1D)]);
          legend(lgnd{:}); xlabel('spatial frequency (cycles)'); ylabel('Power');
          title('1D frequency spectrum');
      end;
      %%%%%%%%%%%%%%%%%%%
      % Log-power (1D; models vs each other)
      if (strcmp(ftp{fi}, 'fft-1D-noorig-log'))
          semilogy(ffts.freqs_1D, 1+[avgPowerModelRH_1D; avgPowerModelLH_1D; avgPowerOrig_1D])
    
          set(gca,'xlim', ffts.freqs_1D([1 end]));
          legend(lgnd{:}); 
          xlabel('spatial frequency (cycles)'); ylabel('Power+1 (log_{10} scale)');
      end;
      
      
      %%%%%%%%%%%%%%%%%%%
      % Power (difference between models)
      if (strcmp(ftp{fi}, 'fft-1D-err'))
          plot(ffts.freqs_1D, abs([avgPowerOrig_1D - avgPowerModelRH_1D; ...
                                   avgPowerOrig_1D - avgPowerModelLH_1D]), 'LineWidth', 2.0)

          legend(lgnd{:}); xlabel('spatial frequency (cycles)'); ylabel('Power');
          title('Error')
      end;
      %%%%%%%%%%%%%%%%%%%
      % Log-power (difference between models)
      if (strcmp(ftp{fi}, 'fft-1D-err-log'))
          semilogy(ffts.freqs_1D, 1+abs([avgPowerOrig_1D - avgPowerModelRH_1D; ...
                                         avgPowerOrig_1D - avgPowerModelLH_1D]), 'LineWidth', 2.0)
          
          legend(lgnd{:}); xlabel('spatial frequency (cycles)'); ylabel('Power+1 (log_{10} scale)');
          title('Error')
      end;
      

      %%%%%%%%%%%%%%%%%%%
      % Power (difference between models)
      if (strcmp(ftp{fi}, 'fft-1D-err-diff'))
          plot(ffts.freqs_1D, abs(avgPowerOrig_1D - avgPowerModelRH_1D) ...
                             -abs(avgPowerOrig_1D - avgPowerModelLH_1D))
          plot(ffts.freqs_1D([1 end]), [0 0], 'k');

          xlabel('spatial frequency (cycles)'); ylabel('Power; + == better LH perf!');
          title('Error_{RH} - Error_{LH}');
      end;
      
    
      
      
      %%%%%%%%%%%%%%%%%%%
      % Log-spectrum (models vs original)
      if (strcmp(ftp{fi}, 'fft-2D'))
      
          subplot(1,3,1); colormap jet;
          title(sprintf('LH (\\sigma=%3.2f)', mSets.sigma(end)));
          imagesc(fftshift(log10(1+avgPowerModelLH_2D))); % RH
          set(gca, 'xtick',[],'ytick',[]);

          subplot(1,3,2); colormap jet;     % Orig
          title('Original [log_{10} (power+1)]');
          imagesc(fftshift(log10(1+avgPowerOrig_2D)));  
          set(gca, 'xtick',[],'ytick',[]);

          subplot(1,3,3); colormap jet;     % RH
          title(sprintf('RH (\\sigma=%3.2f)', mSets.sigma(1)));
          imagesc(fftshift(log10(1+avgPowerModelRH_2D)));
          set(gca, 'xtick',[],'ytick',[]);

      end;
    
    
      %%%%%%%%%%%%%%%%%%%
      % Colored Log-spectrum (models difference from orig)
      if (strcmp(ftp{fi}, 'fft-2D-log-diff-orig'))
          pd1  = avgPowerModelRH_2D-avgPowerOrig_2D; 
          pd2  = avgPowerModelLH_2D-avgPowerOrig_2D; 
    
          %pd1(abs(pd1)<1) = 1; % any difference that's small, just call it zero,
          %pd2(abs(pd2)<1) = 1; %   so we don't have to deal with sign flipping
          pd1  = sign(pd1).*log10(1+abs(pd1));
          pd2  = sign(pd2).*log10(1+abs(pd2));
    
          mv = max(abs([pd1(:);pd2(:)]));
          cl = [-mv mv];
          subplot(1,2,1); colormap jet; hold on;
          title(sprintf('LH (\\sigma=%3.2f) - orig', mSets.sigma(end)));
          imagesc(fftshift(pd2), cl); axis image;
          set(gca, 'xtick',[],'ytick',[]);
          colorbar;
          xlabel('color == log_{10}(power+1)');
          
          subplot(1,2,2); colormap jet; hold on;
          title( sprintf('RH (\\sigma=%3.2f) - orig', mSets.sigma(1)));
          imagesc(fftshift(pd1), cl); axis image;
          set(gca, 'xtick',[],'ytick',[]);
          colorbar;
          
          clear('pd1','pd2');
      end;


      %%%%%%%%%%%%%%%%%%%
      % Colored Log-spectrum (models difference from orig)
      if (strcmp(ftp{fi}, 'fft-2D-log-diff-ratio'))
          pd1  = abs(avgPowerModelRH_2D-avgPowerOrig_2D); 
          pd2  = abs(avgPowerModelLH_2D-avgPowerOrig_2D); 
    
error('NYI; ratio doesn''t make sense unless anything < 1 becomes flipped and negative, so RH and LH ratio can be on the same scale.');
          rat = pd1 ./ pd2;

          hold on;
          title(sprintf('Ratio of log-power differences (pow(\\sigma=%3.2f) - pow(\\sigma=%3.2f)) to original', mSets.sigma(RH_IDX), mSets.sigma(LH_IDX)));
          imagesc( fftshift(rat), [-1 1]); %make sure green is always ZERO
          axis('tight');
          set(gca, 'xtick',[],'ytick',[]);
          colorbar;
          
          clear('pd1','pd2');
      end;
    
    
      %%%%%%%%%%%%%%%%%%%
      % Diff as normalized 2D
      if (strcmp(ftp{fi}, 'fft-2D-log-diff'))
       
          % We want + to be "better RH", which means negative value (smaller difference from orig)
          pd=abs(avgPowerOrig_2D-avgPowerModelLH_2D)-abs(avgPowerOrig_2D-avgPowerModelRH_2D);

%          pd(abs(pd)<1) = 1; % any difference that's small, just call it zero,
%                             %   so we don't have to deal with sign flipping 
          pd = sign(pd).*log10(1+abs(pd));
          clim = [-max(0.1, max(abs(pd(:)))), max(0.1, max(abs(pd(:))))];

          colormap jet;
          imagesc(fftshift( pd ), clim); colorbar;
 
          axis('tight');
          set(gca, 'xtick',[],'ytick',[]);

    
          title(sprintf('Log-(power+1) differences (pow(\\sigma=%3.2f) - pow(\\sigma=%3.2f))', mSets.sigma(RH_IDX), mSets.sigma(LH_IDX)));
          clear('pd');
      end;
      
      %%%%%%%%%%%%%%%%%%%
      % Diff as normalized 2D
      if (strcmp(ftp{fi}, 'fft-2D-log-diff-statsig') && length(mSets.sigma)==2)
       
          % We want + to be "better RH", which means negative value (smaller difference from orig)
          pd=abs(avgPowerOrig_2D-avgPowerModelLH_2D)-abs(avgPowerOrig_2D-avgPowerModelRH_2D);
          %pd(abs(pd)<1) = 1; % any difference that's small, just call it zero,
          %                   %   so we don't have to deal with sign flipping 
          pd = sign(pd).*log10(1+abs(pd));
          pd = pd .* (ffts.pals.an2D<=0.05); % limit to only statistically different frequencies

          clim = [-max(0.1, max(abs(pd(:)))), max(0.1, max(abs(pd(:))))];
          
          colormap jet;
          imagesc(fftshift( pd ), clim); colorbar;
          axis('tight');
          set(gca, 'xtick',[],'ytick',[]);
          title(sprintf('Log-(power+1) differences (pow(\\sigma=%3.2f) - pow(\\sigma=%3.2f))', mSets.sigma(RH_IDX), mSets.sigma(LH_IDX)));

          clear('pd');
      end;
    
    
      %%%%%%%%%%%%%%%%%%%
      % Invert based on original power
      if (strcmp(ftp{fi}, 'fft-2D-statsig-recon') && length(mSets.sigma)==2)
          pd=abs(avgPowerOrig_2D-avgPowerModelLH_2D)-abs(avgPowerOrig_2D-avgPowerModelRH_2D);
          
          % Use fft power from first original image
          pwrRH = squeeze(ffts.orig2D(1,1,:,:)).*(pd>0).*(ffts.pals.an2D<=0.05);
          pwrLH = squeeze(ffts.orig2D(1,1,:,:)).*(pd<0).*(ffts.pals.an2D<=0.05);
          
          imgRH = ifft2(pwrRH); imgRH=imgRH(1:mSets.nInput(1), 1:mSets.nInput(2));
          imgLH = ifft2(pwrLH); imgLH=imgLH(1:mSets.nInput(1), 1:mSets.nInput(2));

          % Now take an image, and show.
          
          subplot(1,2,1); colormap gray;
          title(sprintf('LH (\\sigma=%3.2f) p<0.05 recon', mSets.sigma(end)));
          imagesc(imgLH);
          set(gca, 'xtick',[],'ytick',[]);
          
          subplot(1,2,2); colormap gray;
          title( sprintf('RH (\\sigma=%3.2f) p<0.05 recon', mSets.sigma(1)));
          imagesc(imgRH);
          set(gca, 'xtick',[],'ytick',[]);
          
          clear('pd1','pd2');
      end;

          
      %%%%%%%%%%%%%%%%%%%%
      % Do the curve and stats again, but this time with smoothing
      %%%%%%%%%%%%%%%%%%%%
      
      if (any(ismember({'fft-1D-log-diff-smoothed' ...
                        'fft-1D-log-diff-pct-smoothed' ...
                        'fft-1D-ratio-smoothed' ...
                        'fft-1D-log-diff-smoothed-stats' ...
                        'fft-1D-log-diff-old-smoothed-stats' ...
                        'fft-1D-statsig-freq-imgs-smooth-lh' ...
                        'fft-1D-statsig-freq-imgs-smooth-rh' ...
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
              pMean2 = [reshape(mean(ffts.model1D.power{1}(si,:,:),2), size(ffts.freqs_1D)); ...
                        reshape(mean(ffts.model1D.power{end}(si,:,:),2), size(ffts.freqs_1D))]; %average over models
              pStd2  =  reshape(std (ffts.model1D.power{1}(si,:,:),0,2), size(ffts.freqs_1D)) ...
                      + reshape(std (ffts.model1D.power{end}(si,:,:),0,2), size(ffts.freqs_1D)); %std 
              
              % Follow the logic:
              %   This is ERROR, so SMALLER IS BETTER.
              % To have RH = up, LH down, subtract RH error from LH error.
              %   + error means MORE LH ERROR = better RH fidelity,
              %   - error means MORE RH ERROR = better LH fidelity
              d_o        = [ pMean2(1,:) - reshape(ffts.orig1D.power(si,:,:), size(ffts.freqs_1D));   % RH
                             pMean2(2,:) - reshape(ffts.orig1D.power(si,:,:), size(ffts.freqs_1D)) ]; % LH
              pm2d_o     =   abs(d_o(2,:)) - abs(d_o(1,:));   % LH_err-RH_err => pos means LESS ERROR/better job by RH! 
              pm2d_up1_o = pm2d_o+pStd2;
              pm2d_dn1_o = pm2d_o-pStd2;
    
              pm2d = pm2d_o; pm2d_up1 = pm2d_up1_o; pm2d_dn1 = pm2d_dn1_o;
              
              %pm2d    (abs(pm2d_o)<1)=1;     % any difference that's small, just call it zero,
              %pm2d_up1(abs(pm2d_up1_o)<1)=1; %   so we don't have to deal with sign flipping
              %pm2d_dn1(abs(pm2d_dn1_o)<1)=1;
              
              pm2d     = sign(pm2d)    .*log10(1+abs(pm2d));
              pm2d_up1 = sign(pm2d_up1).*log10(1+abs(pm2d_up1));
              pm2d_dn1 = sign(pm2d_dn1).*log10(1+abs(pm2d_dn1));
                
              %%%%%%%%%%%%%%%%%%%
              % Log-power (difference between models)
              %   showing original curve and smoothed curve
              %
              % Mostly for debugging...
              if (strcmp(ftp{fi}, 'fft-1D-log-diff-smoothed'))
              
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;
 
                  % can put orig here as well
                  org = avgPowerModelRH_1D - avgPowerModelLH_1D; %average over model instances for LH&RH
                  %org(abs(org)<1) = 1;
                  org  = sign(org).*log10(1+abs(org));
                  
                  h = []; %to pass to legend
    
                  plot(ffts.freqs_1D, zeros(size(ffts.freqs_1D)), 'k-', 'LineWidth', 1.5);
                  h(end+1) = plot(ffts.freqs_1D, org, 'r--'); hold on;          % original
                  h(end+1) = plot(ffts.freqs_1D, pm2d, 'b-', 'LineWidth', 2.0);  % convolved version
                  
                  legend(h, {'orig', 'smoothed'}, 'Location', 'NorthEast');
                  title(sprintf('RH (\\sigma=%3.2f) - LH (\\sigma=%3.2f) (smooth_{\\sigma}=%3.2f)', mSets.sigma(1), mSets.sigma(end), sig));
                  xlabel('spatial frequency (cycles/image)');
                  ylabel('log_{10}(power+1)');
    
                  yl = [min(org) max(org)]; %orig has more extreme values than convolved
                  yl = [yl(1)-diff(yl)/10 yl(2)+diff(yl)/10];
                  set(gca,'xlim', ffts.freqs_1D([1 end]), 'ylim',yl);
              end;
              
                
              %%%%%%%%%%%%%%%%%%%
              % Log-power (difference between models)
              %   showing smoothed curve as a percentage
              %   of the original power
              %
              % Mostly for debugging...
              if (strcmp(ftp{fi}, 'fft-1D-log-diff-pct-smoothed'))
              
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;
 
                  % can put orig here as well
                  pm2d_pct = pm2d_o ./ avgPowerOrig_1D;
                  pm2d_up1_pct = pm2d_up1_o ./ avgPowerOrig_1D;
                  pm2d_dn1_pct = pm2d_dn1_o ./ avgPowerOrig_1D;

                  h = []; %to pass to legend
    
                  plot(ffts.freqs_1D, zeros(size(ffts.freqs_1D)), 'k', 'LineWidth', 2.0);
                  h(end+1) = plot(ffts.freqs_1D, pm2d_pct, 'b', 'LineWidth', 4.0);
                  h(end+1) = plot(ffts.freqs_1D, pm2d_up1_pct, 'r--', 'LineWidth', 2.0);
                             plot(ffts.freqs_1D, pm2d_dn1_pct, 'r--', 'LineWidth', 2.0);
                  
                  legend(h, {'mean', 'std'}, 'Location', 'NorthEast');
                  title(sprintf('RH (\\sigma=%3.2f) - LH (\\sigma=%3.2f) (smooth_{\\sigma}=%3.2f)', mSets.sigma(1), mSets.sigma(end), sig));
                  xlabel('spatial frequency (cycles/image)');
                  ylabel('% greater log(power+1) encoded');
                    
                  yl = [-1 1];%min(pm2d_dn1_pct) max(pm2d_up1_pct)];
                  set(gca,'xlim', ffts.freqs_1D([1 end]), 'ylim',yl);
              end;
            
            
              
                  
              %%%%%%%%%%%%%%%%%%%
              % Plot 1D diff, with stats highlighted
              if (strcmp(ftp{fi}, 'fft-1D-log-diff-smoothed-stats') && length(mSets.sigma)==2)
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;
                               
                  % Now that we've done the statistical tests,
                  %   select only the frequencies that show a "significant"
                  %   difference.
                  good_idx = ffts.pals.an1D(si,:)<=0.05;
                  bad_idx  = ffts.pals.an1D(si,:)>0.05;

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
                  title(sprintf('RH (\\sigma=%3.2f) - LH (\\sigma=%3.2f) (smooth_{\\sigma}=%3.2f)', mSets.sigma(1), mSets.sigma(end), sig));
                  xlabel('spatial frequency (cycles/image)');
                  ylabel('Difference of log_{10}(power+1) encoded');
                    
                  yl = [min(pm2d_dn1) max(pm2d_up1)];
                  if (~any(yl)), yl=eps*[-1 1]; end;
                  set(gca,'xlim', ffts.freqs_1D([1 end]), 'ylim',yl);
              end;
            
                  
              %%%%%%%%%%%%%%%%%%%
              % Plot 1D diff, with stats highlighted
              if (strcmp(ftp{fi}, 'fft-1D-ratio-smoothed'))
                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;
error('NYI; ratio doesn''t make sense unless anything < 1 becomes flipped and negative, so RH and LH ratio can be on the same scale.');
                  r    = abs(d_o(1,:)./d_o(2,:));
                  %r    = abs(d_o(2,:)) - abs(d_o(1,:)); %LH_err-RH_err; + means better RH
                  %rstd = reshape(std (ffts.model1D.power{1}(si,:,:)./ffts.model1D.power{end}(si,:,:),0,2), size(ffts.freqs_1D)); %std 
                  h = []; %to pass to legend

                  plot(ffts.freqs_1D, ones(size(ffts.freqs_1D)), 'k', 'LineWidth', 2.0);
                  h(end+1) = plot(ffts.freqs_1D, r, 'b', 'LineWidth', 4.0);
                  %h(end+1) = plot(ffts.freqs_1D, r+rstd, 'r--', 'LineWidth', 2.0);
                  %           plot(ffts.freqs_1D, r-rstd, 'r--', 'LineWidth', 2.0);
                  
                  legend(h, {'mean'}, 'Location', 'NorthEast');
                  title(sprintf('RH (\\sigma=%3.2f) - LH (\\sigma=%3.2f) (smooth_{\\sigma}=%3.2f)', mSets.sigma(1), mSets.sigma(end), sig));
                  xlabel('spatial frequency (cycles/image)');
                  ylabel('Ratio of log_{10}(power+1) encoded');
                   
                  yl = max( [min(abs(r)) max(abs(r))] ); yl = [-yl yl];
                  %yl = [0 2];%max(abs(1-[min(r) max(r)])); yl = [1-yl 1+yl];
                  if (diff(yl)==0), yl=[1-eps 1+eps]; end;
                  set(gca,'xlim', ffts.freqs_1D([1 end]), 'ylim',yl);
              end;
            
            
              %%%%%%%%%%%%%%%%%%%
              % Plot images of RH-stat-sig-different freqeuncies 
              %   and same foR RH
              if (strcmp(ftp{fi}, 'fft-1D-statsig-freq-imgs-smooth-rh') && length(mSets.sigma)==2)
                  good_idx = ffts.pals.an1D(si,:)<=0.05;

                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;

                  r    = abs(d_o(2,:)) - abs(d_o(1,:)); %LH_err-RH_err => + means better RH

                  rhFreqs = good_idx==1 & r > 0;
                  nImg  = size(ffts.orig2D, 2);
                  
                  selectedImages  = unique(round(linspace(1,nImg,20)));  % max 20 images
                  nSelectedImages = length(selectedImages);
                  [nRows,nCols]   = guru_optSubplots(nSelectedImages);


                  for ii=1:nSelectedImages
                    rhFFT =   squeeze(ffts.orig2D(:, selectedImages(ii), :, :)) ...
                           .* ifftshift(guru_freq1to2(ffts.freqs_1D(rhFreqs)*(ffts.padfactor+1), ffts.fftSz));
                    rhiFFT = ifft2(rhFFT);
                    rhImg = real(rhiFFT(1:mSets.nInput(1), 1:mSets.nInput(2)));
                    
                    subplot(nRows, nCols, ii);
                    colormap('gray');
                    if (any(rhFreqs))
                        clim = [min(rhImg(:)) max(rhImg(:))];
                        if (diff(clim)==0), clim = [clim(1)-1 clim(1)+1]; end;
                        imagesc( rhImg, clim);
                    end;
                    set(gca, 'xtick',[],'ytick',[]);                    
                    
                    set(gca, 'xtick',[],'ytick',[]);
                  end;
              end;


              if (strcmp(ftp{fi}, 'fft-1D-statsig-freq-imgs-smooth-lh') && length(mSets.sigma)==2)
                  good_idx = ffts.pals.an1D(si,:)<=0.05;

                  figures(end+1) = de_NewFig( sprintf('%s-%3.2f', ftp{fi}, sig) );
                  hold on;

                  r    = abs(d_o(2,:)) - abs(d_o(1,:)); %LH_err-RH_err => - means better LH
                  lhFreqs = (good_idx==1) & (r < 0);
                  nImg  = size(ffts.orig2D, 2);
                  
                  selectedImages  = unique(round(linspace(1,nImg,20)));  % max 20 images
                  nSelectedImages = length(selectedImages);
                  [nRows,nCols]   = guru_optSubplots(nSelectedImages);
                
                  for ii=1:nSelectedImages
                    lhFFT =   squeeze(ffts.orig2D(:, selectedImages(ii), :, :)) ...
                           .* ifftshift(guru_freq1to2(ffts.freqs_1D(lhFreqs)*(ffts.padfactor+1), ffts.fftSz));
                    lhiFFT = ifft2(lhFFT);
                    lhImg = real(lhiFFT(1:mSets.nInput(1), 1:mSets.nInput(2)));
                    

                    subplot(nRows, nCols, ii);
                    colormap('gray');
                    if (any(lhFreqs))
                        clim = [min(lhImg(:)) max(lhImg(:))];
                        if (diff(clim)==0), clim = [clim(1)-1 clim(1)+1]; end;
                        imagesc( lhImg, clim );
                    end;                    

                    set(gca, 'xtick',[],'ytick',[]);
                  end;
              end;
              
          end; %loop over sigmas
      end;   % if member

    end; % looping
