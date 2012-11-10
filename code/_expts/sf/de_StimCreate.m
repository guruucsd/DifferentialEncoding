function [train, test] = de_StimCreate(stimSet, taskType, opt)
%Input:
%  stimSet  : ignored
%  taskType : ignored
%  opt      : a vector of options; all listed will be applied
%             cycles: # of cycles in the image
%             phases: all phases to recode
%             thetas: all orientations to recode
%
%             total # images = [# cycles]*[# phases]*[# thetas]
%
%OUTPUT: train and test variables, with the following properties
%
%  train.X    : matrix containing 13500x[# images] pixel values for [# images] 135x100 images
%  train.XLAB : text labels for these images
%
%  test.*     : same as train object, but

  % These are ignored anyway
  if (~exist('stimSet','var') || isempty(stimSet)), stimSet = 'all'; end;
  if (~exist('taskType','var')), taskType = ''; end;

    % Massage/default options
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  [train.phases] = guru_getopt(opt, 'phases',  linspace(0,15*pi/16,16));
  [train.thetas] = guru_getopt(opt, 'thetas',  linspace(0,pi/2, 4));
  [train.cycles] = guru_getopt(opt, 'cycles',  [1 2 4 8 16]);
  [train.nInput] = guru_getopt(opt, 'nInput',  [135 100]);
  train.freqs    = train.cycles/train.nInput(1);

  % With this info, create our X and TT vectors
  [train.X, train.XLAB] = stim2D(stimSet, train.nInput, train.freqs, train.phases, train.thetas);

  % Train & test sets are the same, EXCEPT that the phases change.
  test = train;
  if length(train.phases)>1
    test.phases = train.phases + mean(diff(train.phases))/2;
  end;
  [test.X, test.XLAB] = stim2D(stimSet, test.nInput, test.freqs, test.phases, test.thetas);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,XLAB]= stim2D(stimSet, nInput, freqs, phases, thetas)

    X    = zeros(prod(nInput), length(freqs)*length(phases)*length(thetas));
    XLAB = cell(size(X,2),1);

    ii = 1;
    for fi=1:length(freqs)
        for pi=1:length(phases)
            for ti=1:length(thetas)
                X(:,ii)  = reshape( mfe_grating2d(freqs(fi), phases(pi), thetas(ti), 1, nInput(1), nInput(2)), [prod(nInput) 1]);
                XLAB{ii} = sprintf('f=%f\np=%f\nt=%f', freqs(fi), phases(pi), thetas(ti));
                ii = ii+1;
            end;
        end;
    end;


