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
  n_phases = guru_getopt(opt, 'nphases', 8);
  n_thetas = guru_getopt(opt, 'nthetas', 8);
  n_freqs = guru_getopt(opt, 'nfreqs', 8);

  [train.nInput] = guru_getopt(opt, 'nInput',  [135 100]);
  [train.phases] = guru_getopt(opt, 'phases',  linspace(0, (n_phases-1) * 2 * pi / n_phases, n_phases));
  [train.thetas] = guru_getopt(opt, 'thetas',  linspace(0, (n_thetas-1) * pi / n_thetas, n_thetas));
  [train.cycles] = guru_getopt(opt, 'cycles',  2.^(linspace(0, log2(max(train.nInput))-1, n_freqs)));
  train.freqs    = train.cycles / max(train.nInput);
  train.orients = train.thetas;

  % With this info, create our X and TT vectors
  [train.X, train.XLAB] = stim2D(stimSet, train.nInput, train.freqs, train.phases, train.thetas);
  [train] = applyOptions(opt, train);

 % Train & test sets are the same, EXCEPT that the phases change.
  test = train;
  if length(train.phases)>1
    test.phases = train.phases + mean(diff(train.phases))/2;
  end;
  [test.X, test.XLAB] = stim2D(stimSet, test.nInput, test.freqs, test.phases, test.thetas);
  [test] = applyOptions(opt, test);

  function [dset] = applyOptions(opts, dset)
    if guru_hasopt(opts,'square')
      dset.X(dset.X<=0) = -1;
      dset.X(dset.X>0)  = 1;
      guru_assert(dset.X==-1 | dset.X==1, 'make sure all values are -1 or 1');
      dset.type='square';
    else
      dset.type='sin';
    end;



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,XLAB]= stim2D(stimSet, nInput, freqs, phases, thetas)

    % Filter the gratings based on teh stimulus set
    switch stimSet
        case 'vertonly', thetas=0;
        case 'horzonly', thetas=pi/2;
        case {'','all'}, ;
        otherwise, error('unknown stimSet');
    end;

    X    = zeros(prod(nInput), length(freqs)*length(phases)*length(thetas));
    XLAB = cell(size(X,2),1);

    ii = 1;
    for fi=1:length(freqs)
        for ti=1:length(thetas)
            for phsi=1:length(phases)
                X(:,ii)  = reshape( mfe_grating2d(freqs(fi), phases(phsi), thetas(ti), 1, nInput(1), nInput(2)), [prod(nInput) 1]);
                XLAB{ii} = sprintf('f=%f\nt=%f\np=%f', freqs(fi), thetas(ti), phases(phsi));
                ii = ii+1;
            end;
        end;
    end;


