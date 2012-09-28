function [pals] = de_StatsFFTs(stats)

    %%%%%%%%%%%%%%%%%%
    % Stats tests
    %%%%%%%%%%%%%%%%%%

    % Now that we've smoothed each model instance's
    %   power spectrum according to the current Gaussian kernel,
    %   we need to do a statistical test at each frequency.
    %
    if (length(stats.model.power1D)~=2)
      pals = [];
      return;
    end;
    
    nSig    = size(stats.model.power1D{1},1);
    nModels = min( size(stats.model.power1D{1},2), size(stats.model.power1D{end},2) ); %match sample sizes
    
    % Get the 1D info
    nFreq      = size(stats.model.power1D{1},3);
    pals.tt1D  = zeros(nSig,nFreq,1); sals = cell(nSig,nFreq,1);

      % Calc stats separately for each frequency
      for si=1:nSig
          for fi=1:nFreq
              dta = [reshape(stats.model.power1D{1}  (si,1:nModels,fi), [nModels 1]), ...
                     reshape(stats.model.power1D{end}(si,1:nModels,fi), [nModels 1]) ];
                     
              dta = abs(dta - repmat( stats.orig.power1D{1}(si,1,fi), [nModels 2] ));
              
              [pals.an1D(si,fi)] =anova1( dta, {'rh','lh'}, 'off');
          end;
      end;
    
    pals.tt2D = zeros(stats.orig.fftsz);
    nFreq     = numel(pals.tt2D);
    pwrRH = stats.model.ffts{1}  .*conj(stats.model.ffts{1});
	pwrLH = stats.model.ffts{end}.*conj(stats.model.ffts{end});
    
    for yi = 1:stats.orig.fftsz(1)
        for xi=1:stats.orig.fftsz(2)
        
            nInst   = min(size(pwrRH,1), size(pwrLH,1));
            nImages = min(size(pwrRH,2), size(pwrLH,2));
            
            dta = [reshape(pwrRH(1:nInst,1:nImages,yi,xi), [nInst*nImages 1]) ...
                   reshape(pwrLH(1:nInst,1:nImages,yi,xi), [nInst*nImages 1])];
            
            [pals.an2D(yi,xi)] = anova1(dta,{'rh','lh'},'off');
        end;
    end;
        
    
