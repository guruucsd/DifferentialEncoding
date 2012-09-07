function [varargout] = de_DoRejections(models, varargin)%rmodes,rc)
%function [rejectTypes, models] = de_DoRejections(models, fittypes,)
%
% Rejects trials based on a given rejections algorithm
%
% Input:
% model         : see de_model for details
% LS            :
% errAutoEnc    :
% rmodes         : (optional) rejections mode
%
% Output:
% rejectTypes     : indices of runs that should be rejected
% models          :
  % Since each sigma is independent, we may have different #s of 'rons'
  %   per sigma.  So, we can't use a matrix of structs, we need to separate
  %   into a cell array.
  nSigmas = size(models,2);
  rons    = size(models,1);
  if (~iscell(models))
    models  = mat2cell(models, rons, ones(1,nSigmas));
  end;
 
  if (nargin==3)
    LS      = de_models2LS(models);
    rmodes  = varargin{1};
    rc      = varargin{2};
    if (~iscell(rmodes) && ischar(rmodes))
      rmodes = {rmodes};
    end;
    %if (~exist('rc','var'))
  end;
  

  % Get the rejectTypes if necessary.
  switch (nargin)
    case 2,
      rejectTypes = varargin{1};
      if (~iscell(rejectTypes))
        rejectTypes = {rejectTypes};
      end;
      
    case 3
      for k=1:nSigmas %sigmas

        % Determine which are bad (and why)
        rejectTypes{k} = de_DoRejections_Internal(models{k}, LS{k}, rmodes, rc);
        %rejectIdx{k}   = (rejectTypes{k} == 0);
      end;
  end;

  varargout={}; 
  
  % Return the rejection indices
  if (length(varargin)>1)
    varargout{end+1} = rejectTypes;
  end;
  
  % Return the good models
  if (length(varargin)==1||nargout>1)
    varargout{end+1} = cell(size(models));
    for k=1:length(varargout{end})
      goodies = find(sum(rejectTypes{k},2)==0);
      varargout{end}{k}  = models{k}(goodies);
      
      % Warn
      if (length(goodies) == 0)
        warning('Rejected all models.');
      end;
    end;
  end;
  
  % Return the bad models
  if (nargout>2 || (nargout==2 && length(varargin)==1))
    varargout{end+1} = cell(size(models));
    for k=1:length(varargout{end})
      varargout{end}{k}  = models{k}(find(rejectTypes{k}~=0));
    end;
  end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [rejectTypes] = de_DoRejections_Internal(models,LS,rmodes,rc)
  %function [rejectTypes] = de_DoRejections_Internal(models,LS,rmodes,rc)
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
    mSets = models(1);
    rons = size(LS,1);
    
    if (~exist('rmodes','var'))
      rmodes = [1 2 3];
    end;
    
    
    % The following rejection types are in order of most-to-least-elegant.
    %   So, if you run multiple, one follows another logically.
    rejectTypes = zeros(rons, length(rmodes));
    
    for r=1:length(rmodes)
    
      tidx_jset    = [mSets.data.LpSm   mSets.data.LmSp];
%      tidx_fullset = [mSets.data.LpSpID mSets.data.LpSpNID ...
%                      mSets.data.LpSm   mSets.data.LmSp ...
%                      mSets.data.LmSmID mSets.data.LmSmNID];
      tidx_fullset = [mSets.data.LpSp mSets.data.LpSm ...
                      mSets.data.LmSp mSets.data.LmSm];
      
      switch rmodes{r}
        case 'maxerr'
          rejectTypes(:,r) = de_DoRejections_MaxError(models);

        case 'janet'
          rejectTypes(:,r) = de_DoRejections_SampleStd(LS, rc, tidx_jset);
          
        case 'janet-normd'
          rejectTypes(:,r) = de_DoRejections_SampleStdNormd(LS, rc, tidx_jset);
          
        case 'sample_std'
          rejectTypes(:,r) = de_DoRejections_SampleStd(LS, rc, tidx_fullset);
          
        case 'sample_std-normd'
          rejectTypes(:,r) = de_DoRejections_SampleStdNormd(LS, rc, tidx_fullset);
          
        case 'ac-gauss'
          rejectTypes(:,r) = de_DoRejections_All('gauss', reshape(errAutoEnc,[prod(size(errAutoEnc)),1]), ...
                                            de_SmartBins(LS), mSets.rej.width);

        case 'individ-gauss'   % Reject by gaussian fitting ON EACH 
          rejectTypes(:,r) = de_DoRejections_ByTrialType('gauss', LS, mSets.rej.width);

        case 'individ-exgauss'
          rejectTypes(:,r) = de_DoRejections_ByTrialType('exgauss', LS, mSets.rej.width);

        case 'ls-gauss'
          rejectTypes(:,r) = de_DoRejections_All('gauss', reshape(LS,[prod(size(LS)) 1]), ...
                                            de_SmartBins(LS), mSets.rej.width);
        case 'ls-exgauss'
          rejectTypes(:,r) = de_DoRejections_All('exgauss', reshape(LS,[prod(size(LS)) 1]), ...
                                            de_SmartBins(LS), mSets.rej.width);
        case 'total-gauss'
          rejectTypes(:,r) = de_DoRejections_All('gauss', sum(LS,2), ...
                                            de_SmartBins(LS), mSets.rej.width);
          
                                            
        otherwise
          error('Unknown rejection mode: %s', rmodes{r});
      end; %switch
    end;
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejectTypes = de_DoRejections_MaxError(models)
      mSets = models(1);

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
    function rejectTypes = de_DoRejections_SampleStd(LS, rc, tidx)
      
      rejectTypes = zeros(size(LS,1), 1);
      
      for i=tidx
        data = LS(:,i);

        m    = mean(data,1);
        s    = std(data,1);
        %fprintf('m=%5.4f, s=%5.4f, %5.3f\n', m, s, rc);
      
        rejectTypes = rejectTypes + (2^(i-1))*((data>(m+rc*s)) + (data<(m-rc*s)));
      end;
      
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejectTypes = de_DoRejections_SampleStdNormd(LS, rc, tidx)

%      bins        = de_SmartBins(LS);
      rejectTypes = zeros(size(LS,1), 1);
      
      for i=tidx
        data = LS(:,i);
        bins = de_SmartBins(data);
        [a,b] = histc(data,bins);

        % In some cases we have some conditions with no trials.
        if (isempty(find(a)))
          continue;
        elseif (length(unique(b))==1) % all in the same bin
          continue;
        end;

        % renormalize data to avoid EXTREME outliers skewing
        % the mean & std
        data(find(data>bins(max(find(a))))) = bins(max(find(a)));

        m    = mean(data,1);
        s    = std(data,1);
      
        rejectTypes = rejectTypes + (2^(i-1))*((data>(m+rc*s)) + (data<(m-rc*s)));
      end;
      
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejectTypes = de_DoRejections_ByTrialType(pdfType, LS, rc)
      
%      bins    = de_SmartBins(LS);
      rejectTypes = zeros(size(LS,1), 1);
      
      for i=1:size(LS,2)
 
        bins    = de_SmartBins(LS(:,i));
        
        new_rejectTypes = de_DoRejections_All(pdfType, LS(:,i), bins, rc);
        
        rejectTypes = rejectTypes + (2^(i-1))*(new_rejectTypes);
      end;
      
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rejects = de_DoRejections_All(pdfType, trials, bins, rejWidth)
    %
    %
    
      rons        = length(trials);
      rejectTypes = zeros(rons, 1);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      [a,b] = hist(trials,bins); %bin the output
      a = a/rons; % normalize to a probability distribution
      
      
      % Fit a gaussian to the binned
      try
        switch(pdfType)
          case 'exgauss'
            % Fit ex-gaussian
            params = [mean(trials,1) std(trials,1) mean(trials,1)];
            [p,q,r,s]= fminsearch('tvz_MLE', params, optimset('MaxIter', 10000,'Display','off'),'tvz_exgausspdf', a);

            error('NYI');

            
          case 'gauss'
            % Fit a gaussian to the binned errors
            gauss = fit(b',a','gauss1'); m_mu=gauss.b1; m_sig=gauss.c1;
        
            % Find rejects
            rejects = ( abs(trials-m_mu) > rejWidth*m_sig );
        end;

      catch % gauss model failed
%        if (ismember(1, dbg))
%          fprintf('Failed to model results with a %s.  Rejecting NONE: %s.\n', pdfType, lasterr);
%        end;
      end;
      
      % if we rejected too many, then we shouldn't reject any.
      if (0.2 <= (length(find(rejects))/rons))
%        if (ismember(1,dbg))
%          fprintf('%3d/%3d is too many; rejecting NONE.\n', length(find(rejects)), rons);
%        end;
        rejects = zeros(size(rejects));
      end;
