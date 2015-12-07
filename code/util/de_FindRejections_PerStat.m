  function [rejectTypes] = de_FindRejections_PerStat(models, rejSets, stats)
  %function [rejectTypes] = de_FindRejectionsDE_Internal_PerStat(models,rejSets, stats)
  %
  % Rejects trials based on a given rejections algorithm
  %
  % Input:
  % models         : see de_model for details
  % LS            :
  % errAutoEnc    :
  % rmodes         : (optional) rejections mode
  %
  % Output:
  % rejects       : indices of runs that should be rejected
  % good          : indices of runs that should NOT be rejected

    %mSets  = models(1);
    runs   = length(models);
    rmodes = rejSets.type;
    rc     = rejSets.width;


    % The following rejection types are in order of most-to-least-elegant.
    %   So, if you run multiple, one follows another logically.
    rejectTypes = zeros(runs, min(1,length(rmodes)));

    if (numel(models) ~= numel(stats))
        warning('# models(%d) and size of stats(%d) not compatible.', numel(models), numel(stats));
    end;

    for r=1:length(rmodes)
      switch rmodes{r}
        case 'janet',            rejectTypes(:,r) = de_FindRejectionsDE_SampleStd(stats, rc(r));
        case 'janet-normd',      rejectTypes(:,r) = de_FindRejectionsDE_SampleStdNormd(stats, rc(r));
        case 'sample_std',       rejectTypes(:,r) = de_FindRejectionsDE_SampleStd(stats, rc(r));
        case 'sample_std-normd', rejectTypes(:,r) = de_FindRejectionsDE_SampleStdNormd(stats, rc(r));
        case 'gauss',            rejectTypes(:,r) = de_FindRejectionsDE_All('gauss', stats, rc(r));
        case 'exgauss',          rejectTypes(:,r) = de_FindRejectionsDE_All('exgauss', stats, rc(r));

        case 'max',              rejectTypes(:,r) = (stats>=rc);
        otherwise
          error('Unknown rejection mode: %s', rmodes{r});
      end; %switch
    end;

    pctRejected = nnz(sum(rejectTypes,2))/size(rejectTypes,1);
    if  pctRejected >= 0.25
        warning(sprintf('Large number of rejections: %.1f%%', 100*pctRejected));
    end;

    rejectTypes = sum(rejectTypes,2) + isnan(stats);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejectTypes = de_FindRejectionsDE_MaxError(models)
      %mSets = models(1);

      rejectTypes = zeros(size(models));

      for i=1:length(models)
        % Make sure AC error is less than threshhold
        if (models(i).ac.Error > 0 && models(i).ac.Error < models(i).ac.trainingError)
          rejectTypes(i) = rejectTypes(i) + 1;

        % Make sure p error is less than thresshold
        elseif (models(i).p.Error > 0 && models(i).p.Error < models(i).p.trainingError)
          rejectTypes(i) = rejectTypes(i) + 2;
        end;
      end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejectTypes = de_FindRejectionsDE_SampleStd(stats, rc)

      rejectTypes = zeros(size(stats,1), 1);
      tidx        = 1:size(stats,2);

      for i=tidx
        data = stats(:,i);

        m    = mean(data,1);
        s    = std(data,1);
        %fprintf('m=%5.4f, s=%5.4f, %5.3f\n', m, s, rc);

        rejectTypes = rejectTypes + (2^(i-1))*((data>(m+rc*s)) + (data<(m-rc*s)));
      end;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejectTypes = de_FindRejectionsDE_SampleStdNormd(stats, rc)

      rejectTypes = zeros(size(stats,1), 1);
      tidx        = 1:size(stats,2);


      for i=tidx
        data = stats(:,i);

        % Put data in bins,
        %   so that we can find extreme outliers
        [bins,a,b] = de_SmartHistc(data);


        % In some cases we have some conditions with no trials.
        if (isempty(find(a,1)))
          continue;
        elseif (length(unique(b))==1) % all in the same bin
          continue;
        end;

        % renormalize data to avoid EXTREME outliers skewing
        % the mean & std
        data2 = data(data<bins(find(a,1,'last')));

        m    = median(data2,1);
        s    = std(data2,1);

        % assume exgauss.  find delta to left, use as delta to right, and
        % cut anything too much more than that.
        rejectTypes = rejectTypes + (2^(i-1))*((data>(m+rc*s)) + (data<(m-rc*s)));
      end;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejects = de_FindRejectionsDE_All(pdfType, stats, rejWidth)
    %
    %

      runs    = length(trials);
      rejects = zeros(runs, 1);

      bins = de_SmartBins(stats);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      [a,b] = hist(stats,bins); %bin the output
      a = a/runs; % normalize to a probability distribution


      % Fit a gaussian to the binned
      try
        switch(pdfType)
          case 'exgauss'
            % Fit ex-gaussian
            params = [mean(stats,1) std(stats,1) mean(stats,1)];
            [~,~,~,s]= fminsearch('tvz_MLE', params, optimset('MaxIter', 10000,'Display','off'),'tvz_exgausspdf', a);

            error('NYI');


          case 'gauss'
            % Fit a gaussian to the binned errors
            gauss = fit(b',a','gauss1'); m_mu=gauss.b1; m_sig=gauss.c1;

            % Find rejects
            rejects = ( abs(stats-m_mu) > rejWidth*m_sig );
        end;

      catch % gauss model failed
%        if (ismember(1, dbg))
%          fprintf('Failed to model results with a %s.  Rejecting NONE: %s.\n', pdfType, lasterr);
%        end;
      end;

      % if we rejected too many, then we shouldn't reject any.
      if (0.2 <= (length(find(rejects))/runs))
%        if (ismember(1,dbg))
%          fprintf('%3d/%3d is too many; rejecting NONE.\n', length(find(rejects)), runs);
%        end;
        rejects = zeros(size(rejects));
      end;
