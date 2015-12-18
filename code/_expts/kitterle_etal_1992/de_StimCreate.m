function [train,test] = de_StimCreate(stimSet, taskType, opt)
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

  if (~exist('stimSet', 'var') || isempty(stimSet)), stimSet  = 'low';  end;
  if (~exist('taskType','var')), taskType = 'recog';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  if (~exist('force','var'))     force    = 0;      end;

  if guru_hasopt(opt, 'nInput'), train.nInput = guru_getopt(opt, 'nInput');
  elseif guru_hasopt(opt, 'small'), train.nInput = [34 25];
  elseif guru_hasopt(opt, 'medium'), train.nInput = [68 50];
  else train.nInput = [135 100];
  end;

  [train.nPhases] = guru_getopt(opt, 'nPhases', 8);
  [train.nThetas] = guru_getopt(opt, 'nThetas', 8);
  [train.cycles]  = guru_getopt(opt, 'cycles', [3 5]);
  [train.freqs]   = train.cycles/train.nInput(1);

  test = train;

  %%

  % With this info, create our X and TT vectors
  [train.X, train.XLAB, train.phases, train.thetas] = stim2D(stimSet, 'train', train.freqs, train.nInput, train.nPhases, train.nThetas);
  [test.X,  test.XLAB,  test.phases,  test.thetas]  = stim2D(stimSet, 'test',  test.freqs,  test.nInput,  test.nPhases,  test.nThetas);

  % Now index and apply options, including input weightings.
  [train.X, train.XLAB] = de_applyOptions(opt, train.X, train.XLAB);
  [test.X,  test.XLAB]  = de_applyOptions(opt, test.X,  test.XLAB);

  % Nail down targets for each task
  if (~isempty(taskType))
      [train.T, train.TLAB]         = de_createTargets(taskType, train.X, train.XLAB, train.freqs);
      [test.T,  test.TLAB]          = de_createTargets(taskType, test.X,  test.XLAB,  train.freqs);
  end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X_new, XLAB_new] = de_applyOptions(opts, X, XLAB)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs

  XLAB_new = XLAB;
  X_new = X;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T, TLAB] = de_createTargets(taskType, X, XLAB, freqs)
  %
  % Take the input vector and taskType, and create a set of labels
  %


  switch (taskType)

    % Identify by frequency
    case {'recog'}
        nFreqs = length(freqs);
        T      = zeros(nFreqs,size(X,2));
        TLAB   = cell(1,size(X,2));

        for i=1:nFreqs
            range = [i-1 i]*size(T,2)/nFreqs;
            idx   = range(1)+1:range(2); %X indices of this frequency

            T(i, idx) = 1;
            TLAB(idx) = deal(repmat({sprintf('freq=%3.2f',freqs(i))}, size(idx)));
        end;

      % Identify by frequency
      case {'recog_freq'}
        guru_assert(length(freqs)==2);

        T = cellfun(@(xl) ~isempty(findstr('f1', xl)), XLAB(:))';
        TLAB = arrayfun(@(t) guru_iff(t, 'f1', 'f2'), T, ...
                        'UniformOutput', false);

        guru_assert(length(find(T)) == length(T)/2);

      % Kitterle task 2: identify by type [sin vs square] wave
      %   note: sin wave = "1"; square wave = 0 (or -1)
      case {'recog_type'}
        guru_assert(length(freqs)==2);

        T = cellfun(@(xl) ~isempty(findstr('square', xl)), XLAB(:))';
        TLAB = arrayfun(@(t) guru_iff(t, 'square', 'sin'), T, ...
                        'UniformOutput', false);

        guru_assert(length(find(T)) == length(T)/2);

      case {'kitterle'} % do both
          [T1, TLAB1]         = de_createTargets('recog_freq', X, XLAB, freqs);
          [T2, TLAB2]         = de_createTargets('recog_type', X, XLAB, freqs);

          T = [T1;T2];
          TLAB = [TLAB1;TLAB2];
  end;

  % pick only two phases of each stimulus type to classify


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,XLAB,phases,thetas]= stim2D(set, tot, freqs, nInput, nPhases, nThetas)

    % Determine thetas
    thetas = linspace(-pi/4, 3*pi/4, nThetas + 1); %angle of grating; pi/2=vertical
    thetas = thetas(1:end-1);  % lazy way to eliminate overlap of -pi/2 and pi/2

    % Determine phases
    phases  = linspace(0, 2*pi, 2*nPhases+1);
    phases  = phases(1:end-1); %40 evenly spaced gratings from 0 to 2pi
    switch (tot)
      case 'train', phases = phases(1:2:end);
      case 'test',  phases = phases(2:2:end);  %only 2 freq, other half of phases
    end;

    switch (set)
      case {'sf_sin', 'sf_squ'}
          nImages = length(phases)*length(freqs);
          X=zeros(prod(nInput), nImages);
          XLAB = cell(nImages,1);


          imgnum = 0;
          for i=1:length(freqs)
            for j=1:length(phases)
              for k=1:length(thetas)
                imgnum = imgnum + 1;

                X(:,imgnum) = reshape(mfe_grating2d(freqs(i),phases(j), thetas(k), 1, nInput(1), nInput(2)), [prod(nInput) 1]);

                % Make a sin wave a square wave
                if (strcmp(set, 'sf_squ'))
                  X(:,imgnum) = double(X(:,imgnum) >= 0.0);
                end;

                XLAB{imgnum} = sprintf('freq=%3.2f (f%d),phase=%3.1f, theta=%3.1f', freqs(i), i, phases(j), thetas(k));


              end;
            end;
          end;

          % Make sure dynamic range is between 0 and 1
          X = (X - min(X(:))) / (max(X(:)) - min(X(:)));

      case 'sf_mixed'
          nImages = length(phases)*length(freqs);
          X=zeros(prod(nInput), nImages);
          XLAB = cell(nImages,1);


          imgnum = 0;
          for i=1:length(freqs)
            for j=1:length(phases)
              for k=1:length(thetas)

                % sin wave for this frequency
                imgnum = imgnum + 1;
                X(:,imgnum) = reshape(mfe_grating2d(freqs(i),phases(j), thetas(k), 1, nInput(1), nInput(2)), [prod(nInput) 1]);
                XLAB{imgnum} = sprintf('sin, freq=%3.2f (f%d),\nphase=%3.1f, theta=%3.1f', freqs(i), i, phases(j), thetas(k));

                % square wave for this frequency
                imgnum = imgnum + 1;
                X(:,imgnum) = X(:,imgnum-1);  % copy the sin wave.
                X(:,imgnum) = sign(X(:, imgnum));
                XLAB{imgnum} = sprintf('square, freq=%3.2f (f%d),\nphase=%3.1f, theta=%3.1f', freqs(i), i, phases(j), thetas(k));

              end;
            end;
          end;

          % Make sure dynamic range is between 0 and 1
          X = (X - min(X(:))) / (max(X(:)) - min(X(:)));

    otherwise, error('Stim set %s NYI', set);
  end;

