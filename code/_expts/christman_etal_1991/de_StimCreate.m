function outFile = de_StimCreate(expt, stimSet, taskType, opt)
%Input:
%  dim      : an integer of the dimensionality of the input
%               2        => 2D
%
%  stimSet  : a string specifying which INPUT sets to train autoencoder on
%               low
%               med
%               high
%               mixed
%
%  taskType : a string specifying which OUTPUT task to train on
%               recog: face recognition task
%
%  opt      : a vector of options; all listed will be applied
%
%OUTPUT: a data file with the following variables:
%
%  train.X    : matrix containing 16 vectors, each a unique hierarchical stimulus.
%  train.T    : target vectors for perceptron (labels, based on task)
%
%  test.*     : same as train object, but 

  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  
  [freqs]  = guru_getopt(opt, 'freqs',   [0.05 0.1 0.2]);
  [phases] = guru_getopt(opt, 'phases',  [0:22.5:157.5]);
  [thetas] = guru_getopt(opt, 'thetas',  linspace(0,pi/2, 1));
  [nInput] = guru_getopt(opt, 'nInput',  [31 13]);
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % With this info, create our X and TT vectors
  [train.X, train.XLAB] = stim2D(stimSet, nInput, freqs, phases, thetas);
  [train.X, train.XLAB] = de_applyOptions(opt, train.X, train.XLAB);
  [train.T, train.TLAB] = de_createTargets(taskType, train.X, train.XLAB, phases);

  % Train & test sets are the same
  test = train;


  % Output everything (including images)  
  outFile        = de_GetDataFile(expt, stimSet, taskType, opt);
  if (~exist(guru_fileparts(outFile,'pathstr'), 'dir'))
    mkdir(guru_fileparts(outFile,'pathstr'));
  end;

  save(outFile, 'train', 'test', 'stimSet', 'taskType', 'opt', ...
                'freqs', 'nInput', 'phases', 'thetas');  
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X_new, XLAB_new] = de_applyOptions(opts, X, XLAB)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs

  XLAB_new = XLAB;
  X_new = X;
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T, TLAB]         = de_createTargets(taskType, X, XLAB, phases)
  %
  % Take the input vector and taskType, and create a set of labels
  %

    nPhases = length(phases);
    T       = nan(size(XLAB));
    TLAB    = cell(size(T));

    % Identify by frequency
  switch (taskType)

    case {'low-recog'}
        T(guru_instr(XLAB,'S1L')) = 0;
        T(guru_instr(XLAB,'S2L')) = 1;
    
    case {'high-recog'}
        T(guru_instr(XLAB,'S1H')) = 0;
        T(guru_instr(XLAB,'S2H')) = 1;
    
    case {'recog'}
        T(guru_instr(XLAB,'S1')) = 0;
        T(guru_instr(XLAB,'S2')) = 1;

      otherwise, error('Task set %s NYI', set);
  end;

    TLAB(guru_instr(XLAB,'S1')) = deal(repmat({'S1'}, [1 sum(guru_instr(XLAB,'S1'))])) ;
    TLAB(guru_instr(XLAB,'S2')) = deal(repmat({'S2'}, [1 sum(guru_instr(XLAB,'S2'))])) ;
    TLAB(isnan(sum(T,1))) = {'NaN'};
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,XLAB]= stim2D(set, nInput, freqs, phases, thetas)
    if (mod(length(freqs),2)~=1)
      error('Christman stim require an ODD number of frequencies (and preferably exactly 5)');
    else
      freqs      = sort(freqs);
      low_freqs  = freqs(1:(length(freqs)-1)/2);
      high_freqs = freqs(((length(freqs)+1)/2 + 1):end);
      mid_freq   = freqs((length(freqs)+1)/2);
    end;

    switch (set)
      case {'low_freq'}
          s1_freqs = low_freqs';
          s2_freqs = [low_freqs mid_freq]';
          
      case {'high_freq'}
          s1_freqs = high_freqs';
          s2_freqs = [mid_freq high_freqs]';
        
      case {'all_freq'}
          [XL,XLLAB] = stim2D('low_freq',  nInput, freqs, phases, thetas);
          [XH,XHLAB]  =stim2D('high_freq', nInput, freqs, phases, thetas);

          X    = [XL XH];
          XLAB = [XLLAB XHLAB];
          return;
          
      otherwise, error('Stim set %s NYI', set);
    end;
        
    %% Christman stims
    nPhases   = length(phases);
    nThetas   = length(thetas);
    minmax    = [0 1];
    img_width = min(nInput);

    % Calculate stimuli
    x    = linspace(-pi, pi, max(nInput));

    s1     = zeros(prod(nInput), nPhases*nThetas);
    curIdx = 1;
    for i=1:nPhases
        for j=1:nThetas
            s1l   = mfe_grating2d(s1_freqs(1), pi/3,      thetas(j), 0.5, nInput(1), nInput(2));
            s1h   = mfe_grating2d(s1_freqs(2), phases(i), thetas(j), 0.5, nInput(1), nInput(2));
            stmp  = mean(minmax) + (diff(minmax)/2)*(s1l(:)+s1h(:));
            mn = min(stmp(:));    mx = max(stmp(:));    df = mx-mn;    
            s1(:,curIdx) = minmax(1) + ((stmp(:) - mn)/df)*minmax(2);     % Make sure values range from 0 to 1
            curIdx = curIdx + 1;
        end;
    end;    
    
    s2   = zeros(size(s1));
    curIdx = 1;
    for i=1:nPhases
        for j=1:nThetas
            stmp = mean(minmax)+(diff(minmax)/2)*mfe_grating2d(mid_freq, phases(i), thetas(j), 1, nInput(1), nInput(2));
            stmp = (0.67)*s1(:,j) + (0.33)*stmp(:);
            mn = min(stmp(:));    mx = max(stmp(:));    df = mx-mn;
            s2(:,curIdx) = minmax(1) + ((stmp(:) - mn)/df)*minmax(2);
            curIdx = curIdx + 1;
        end;
    end;
    
    
    % Make sure values range from 0 to 1
%    mn = min([s1 s2(:)']);
%    mx = max([s1 s2(:)']);
%    df = mx-mn;
    
%    s1 = minmax(1) + ((s1 - mn)/df)*minmax(2);
%    s2 = minmax(1) + ((s2 - mn)/df)*minmax(2);
    if (any(s1(:)<minmax(1)) || any(s2(:)<minmax(1))), error('stim normalization failure'); end;
    if (any(s1(:)>minmax(2)) || any(s2(:)>minmax(2))), error('stim normalization failure'); end;
    
    
    % Shove into X matrix    
    X    = zeros(size(s1,1), size(s1,2)+size(s2,2));
    XLAB = cell (1, size(X,2));

    X(:, 1:size(s1,2)) = s1;
    XLAB(1:size(s1,2)) = deal(repmat({'S1'},[1 size(s1,2)]));
    
    X(:, size(s1,2)+1:end)  = s2;
    XLAB(size(s1,2)+1:end)  = deal(repmat({sprintf('S2,\nphase=%5.2f', phases(i))}, [1 size(s2,2)]));

  switch (set)
      case {'low_freq'}, 
          XLAB = strrep(XLAB, 'S1','S1L');
          XLAB = strrep(XLAB, 'S2','S2L');
      case {'high_freq'}
          XLAB = strrep(XLAB, 'S1','S1H');
          XLAB = strrep(XLAB, 'S2','S2H');
  end;
      
