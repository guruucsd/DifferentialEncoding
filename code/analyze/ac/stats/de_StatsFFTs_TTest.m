function [pals] = de_StatsFFTs(stats)

    %%%%%%%%%%%%%%%%%%
    % Stats tests
    %%%%%%%%%%%%%%%%%%

    % Now that we've smoothed each model instance's
    %   power spectrum according to the current Gaussian kernel,
    %   we need to do a statistical test at each frequency.
    %
    if (length(stats.model.power1D.mean)~=2)
      pals = [];
      return;
    end;

    nSig    = size(stats.model.power1D.mean{1},1);
    nModels = min( size(stats.model.power1D.mean{1},2), size(stats.model.power1D.mean{end},2) ); %match sample sizes

    %% 1D stats
    nFreq1D    = size(stats.model.power1D.mean{1},3);
    pals.tt1D  = zeros(nSig,nFreq1D,1); sals = cell(nSig,nFreq1D,1);

    % Calc stats separately for each frequency
    for si=1:nSig
        for fi=1:nFreq1D
            dta = [reshape(stats.model.power1D.mean{1}  (si,1:nModels,fi), [nModels 1]), ...
                   reshape(stats.model.power1D.mean{end}(si,1:nModels,fi), [nModels 1]) ];

            dta = abs(dta - repmat( stats.orig.power1D.mean{1}(si,1,fi), [nModels 2] ));

            [pals.an1D(si,fi)] =anova1( dta, {'rh','lh'}, 'off');
        end;
    end;

    % 2D stats are slow, so disable to speed up#until we really need it
    if (true)
      pals.tt2D = zeros(stats.orig.fftsz);
      pwrRH     = stats.model.ffts{1}  .*conj(stats.model.ffts{1});
      pwrLH     = stats.model.ffts{end}.*conj(stats.model.ffts{end});

      for yi = 1:stats.orig.fftsz(1)
          for xi=1:stats.orig.fftsz(2)

              nInst   = min(size(pwrRH,1), size(pwrLH,1));
              nImages = min(size(pwrRH,2), size(pwrLH,2));

              dta = [reshape(pwrRH(1:nInst,1:nImages,yi,xi), [nInst*nImages 1]) ...
                     reshape(pwrLH(1:nInst,1:nImages,yi,xi), [nInst*nImages 1])];

              [pals.an2D(yi,xi)] = anova1(dta,{'rh','lh'},'off');
          end;
      end;
    end;

