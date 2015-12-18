function [train, test] = de_StimCreate(stimSet, taskType, opt)
%Input:
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

  if (~exist('stimSet','var') || isempty(stimSet)), stimSet = 'all_freq'; end;
  if (~exist('taskType','var')), taskType = 'recog'; end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  if guru_hasopt(opt, 'nInput'), train.nInput = guru_getopt(opt, 'nInput');
  elseif guru_hasopt(opt, 'small'), train.nInput = [34 25];
  elseif guru_hasopt(opt, 'medium'), train.nInput = [68 50];
  else train.nInput = [135 100];
  end;


  [train.nphases] = guru_getopt(opt, 'nphases',  8);%[11.25:11.25:180]);
  [train.nthetas] = guru_getopt(opt, 'nthetas',  8);
  [train.phases] = guru_getopt(opt, 'phases',  linspace(0, (train.nphases - 1) * 2 * pi / train.nphases, train.nphases));
  [train.thetas] = guru_getopt(opt, 'thetas',  linspace(0, (train.nthetas - 1) * pi / train.nthetas, train.nthetas));
  train.cycles    = guru_getopt(opt, 'cycles', [1 2 4 8 16]);
  train.freqs     = train.cycles/train.nInput(1);
  if (length(train.cycles)~=5), error('not enough elements in cycles; expect 5, got %d', length(train.cycles)); end;

  %%

  % With this info, create our X and TT vectors
  [train.X, train.XLAB] = stim2D(stimSet, train.nInput, train.freqs, train.phases, train.thetas);
  if (~isempty(taskType))
      [train.T, train.TLAB] = de_createTargets(taskType, train.XLAB);
  end;

  % Train & test differ by phase only.
  test = train;
  test.phases = train.phases + mean(diff(train.phases))/2;
  [test.X, test.XLAB] = stim2D(stimSet, test.nInput, test.freqs, test.phases, test.thetas);

  if (~isempty(taskType))
      [test.T, test.TLAB] = de_createTargets(taskType, test.XLAB);
  end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T, TLAB]         = de_createTargets(taskType, XLAB)
  %
  % Take the input vector and taskType, and create a set of labels
  %

    T       = nan(size(XLAB));
    TLAB    = cell(size(T));

    T(guru_instr(XLAB,'S1')) = 0;
    T(guru_instr(XLAB,'S2')) = 1;

    TLAB(guru_instr(XLAB,'S1')) = deal(repmat({'S1'}, [1 sum(guru_instr(XLAB,'S1'))])) ;
    TLAB(guru_instr(XLAB,'S2')) = deal(repmat({'S2'}, [1 sum(guru_instr(XLAB,'S2'))])) ;
    TLAB(isnan(sum(T,1))) = {'NaN'};


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,XLAB]= stim2D(set, nInput, freqs, phases, thetas)
    if (mod(length(freqs),2)~=1)
      error('Christman stim require an ODD number of frequencies (and preferably exactly 5)');
    end;

    freqs      = sort(freqs);
    low_freqs  = freqs(1:(length(freqs)-1)/2);
    high_freqs = freqs(((length(freqs)+1)/2 + 1):end);
    mid_freq   = freqs((length(freqs)+1)/2);
   
    switch (set)
      case {'low_freq'}
          s1_freqs = low_freqs';
          % s2_freqs = [low_freqs mid_freq]';

      case {'high_freq'}
          s1_freqs = high_freqs';
          % s2_freqs = [mid_freq high_freqs]';

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

    % Calculate stimuli
    s1     = zeros(prod(nInput), nPhases*nThetas);
    s1lbl  = cell(nPhases*nThetas, 1);
    ii = 1;

    % Create stims
    for phsi=1:nPhases
        for ti=1:nThetas
            % Make the two gratings, then combine them.
            % One is always at pi/3, the other is at the requested phase.
            s1l   = mfe_grating2d(s1_freqs(1), pi/3,      thetas(ti), 0.5, nInput(1), nInput(2));
            s1h   = mfe_grating2d(s1_freqs(2), phases(phsi), thetas(ti), 0.5, nInput(1), nInput(2));
            stmp  = mean(minmax) + (diff(minmax)/2)*(s1l(:)+s1h(:));
            mn = min(stmp(:));
            mx = max(stmp(:));
            df = mx-mn;
            s1(:, ii) = minmax(1) + ((stmp(:) - mn)/df)*minmax(2);     % Make sure values range from 0 to 1
            s1lbl{ii} = sprintf('S1,\nphase=%5.2f\ntheta=%5.2f', phases(phsi), thetas(ti));
            ii = ii + 1;
        end;
    end;

    s2     = zeros(size(s1));
    s2lbl  = cell(nPhases*nThetas,1);
    ii = 1;
    s2p = 1:nPhases; %%%randperm(nPhases); %shuffle the phases, as compared to above
    for phsi=1:nPhases
        for ti=1:nThetas
            % Make the middle grating, and mix it (1/3) with the
            % corresponding stimulus from above (2/3)
            stmp = mean(minmax)+(diff(minmax)/2)*mfe_grating2d(mid_freq, phases(s2p(phsi)), thetas(ti), 1, nInput(1), nInput(2));
            stmp = (0.67) * s1(:,ii) + (0.33) * stmp(:);
            mn = min(stmp(:));
            mx = max(stmp(:));
            df = mx-mn;
            s2(:, ii) = minmax(1) + ((stmp(:) - mn)/df)*minmax(2);
            s2lbl{ii} = sprintf('S2,\nphase=%5.2f\ntheta=%5.2f', phases(s2p(phsi)), thetas(ti));
            ii = ii + 1;
        end;
    end;


    % Make sure values range from 0 to 1
    guru_assert(~any(s1(:)<minmax(1)) && ~any(s2(:)<minmax(1)), ...
                'stim normalization failure');
    guru_assert(~any(s1(:)>minmax(2)) && ~any(s2(:)>minmax(2)), ...
                'stim normalization failure');


    % Shove into X matrix
    X    = zeros(size(s1,1), size(s1,2)+size(s2,2));
    XLAB = cell (1, size(X,2));

    X(:, 1:size(s1,2)) = s1;
    XLAB(1:size(s1,2)) = s1lbl;
    X(:, size(s1,2)+1:end)  = s2;
    XLAB(size(s1,2)+1:end)  = s2lbl;

    switch (set)
      case {'low_freq'},
          XLAB = strrep(XLAB, 'S1','S1L');
          XLAB = strrep(XLAB, 'S2','S2L');
      case {'high_freq'}
          XLAB = strrep(XLAB, 'S1','S1H');
          XLAB = strrep(XLAB, 'S2','S2H');
    end;
