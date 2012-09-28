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

  if (~exist('stimSet','var') || isempty(stimSet)), stimSet = 'all'; end;
  if (~exist('taskType','var')), taskType = ''; end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  [train.phases] = guru_getopt(opt, 'phases',  [11.25:11.25:180]);
  [train.thetas] = guru_getopt(opt, 'thetas',  linspace(0,pi/2, 4));
  [train.cycles] = guru_getopt(opt, 'cycles',  [1 2 4 8 16]);
  [train.nInput] = guru_getopt(opt, 'nInput',  [135 100]);
  train.freqs    = train.cycles/train.nInput(1);

  %%

  % With this info, create our X and TT vectors
  [train.X, train.XLAB] = stim2D(stimSet, train.nInput, train.freqs, train.phases, train.thetas);

  % Train & test sets are the same
  test = train;
  test.phases = train.phases + mean(diff(train.phases))/2;
  [test.X, test.XLAB] = stim2D(stimSet, test.nInput, test.freqs, test.phases, test.thetas);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,XLAB]= stim2D(set, nInput, freqs, phases, thetas)

    X    = zeros(prod(nInput), length(freqs)*length(phases)*length(thetas));
    XLAB = cell(size(X,2),1);

    ii = 1;
    for fi=1:length(freqs)
        for pi=1:length(phases)
            for ti=1:length(thetas)
                X(:,ii)  = reshape( mfe_grating2d(freqs(fi), phases(pi), thetas(ti), 1, nInput(1), nInput(2)), [prod(nInput) 1]);
                XLAB{ii} = sprintf('f=%f,p=%f,t=%f', freqs(fi), phases(pi), thetas(ti));
                ii = ii+1;
            end;
        end;
    end;


