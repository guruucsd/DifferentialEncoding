function de_StimCreateSF(dim, stimSet, taskType, opt, force)
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

  if (~exist('dim',     'var')), dim      = 2;      end;
  if (~exist('stimSet', 'var')), stimSet  = 'low';  end;
  if (~exist('taskType','var')), taskType = 'recog';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  if (~exist('force','var'))     force    = 0;      end;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % With this info, create our X and TT vectors
  switch(dim)
    case 2, 
      [train.X, nInput, train.XLAB] = stim2D(stimSet, 'train');
      [test.X,  nInput, test.XLAB]  = stim2D(stimSet, 'test');
    otherwise, error('Unknown dimensionality: %d', dim);
  end;

  % Now index and apply options, including input weightings.
  [train.X, nInput, train.XLAB] = de_applyOptions(opt, train.X, nInput, train.XLAB);
  [test.X,  nInput, test.XLAB]  = de_applyOptions(opt, test.X,  nInput, test.XLAB);

  % Nail down targets for each task
  [train.T, train.TLAB]         = de_createTargets(taskType, train.X);
  [test.T,  test.TLAB]          = de_createTargets(taskType,  test.X);

  % Output everything (including images)  
  outFile        = de_getDataFile(dim, ['sf_' stimSet], taskType, opt);
  if (~exist(guru_fileparts(outFile,'pathstr'), 'dir'))
    mkdir(guru_fileparts(outFile,'pathstr'));
  end;

  save(outFile, 'train', 'test', 'nInput', 'dim', 'stimSet', 'taskType', 'opt');  
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X_new, nInput_new, XLAB_new] = de_applyOptions(opt, X, nInput, XLAB)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs

  XLAB_new = XLAB;
      
    if (isempty(opt))
      X_new = X;
      nInput_new = nInput;
      
    elseif (length(opt) > 1)
      error('too many options.');
    
    else
      % each option must update ST; everything else
      %   comes from reindexing.
      opt = opt{1};
        
      switch (opt)
        case 'small', scale = 0.25;
        case 'med',   scale = 0.5;
        otherwise, error('Unknown option: %s', opt);
      end;
      
      nInput_new = size(imresize( reshape(X(:,1), nInput), scale ));
      X_new  = zeros(prod(nInput_new), size(X,2));
      for i=1:size(X,2)
        X_new(:,i) = reshape(imresize( reshape(X(:,i), nInput), scale ), [prod(nInput_new) 1]);
      end;
    end;

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T, TLAB]         = de_createTargets(taskType, X)
  %
  % Take the input vector and taskType, and create a set of labels
  %

  switch (taskType)
    case 'recog'
  end;
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,nInput,XLAB]= stim2D(set, tot)
    nInput = [31 13];

    switch (set)
      case 'low', freq = 0.1;
      case 'med', freq = 0.5;
      case 'high', freq = 1.5;
      otherwise, error('Unknown frequency: %s', set);
    end;
    
    phase = 0:(pi/16):(2*pi);
    theta = phase;
    
    switch (tot)
%      case 'train';
      case 'test',  phase = phase + pi/32; theta = theta+pi/32;
    end;
    
    nImages = length(phase)*length(theta);
    X=zeros(prod(nInput), nImages);
    XLAB = cell(nImages,1);
    
    imgnum = 0;
    for i=1:length(phase)
      for j=1:length(theta)
        imgnum = imgnum + 1;
        X(:,imgnum) = reshape(mfe_grating2d(freq,phase(i), theta(j), 1, nInput(1), nInput(2)), [prod(nInput) 1]);
        XLAB{imgnum} = sprintf('freq=%3.1f, phase=%3.1f, theta=%3.1f', freq, phase(i), theta(j));
      end;
    end;

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [subjects,emotions,dataset] = lbl2SubjDS(TLBL)
  %
  
    subjects = cell(size(TLBL)); 
    emotions = cell(size(TLBL));
    dataset  = cell(size(TLBL));
    
    for i=1:length(TLBL)
      parts   = mfe_split('_', TLBL{i});    
      
      subjects{i} = parts{1};
      
      switch (parts{2})
        % datset 1
        case {'m1','m2'},   dataset{i} = '1'; emotions{i} = 'sad';
        case {'ht1','ht2'}, dataset{i} = '1'; emotions{i} = 'happy (with teeth)';
        case {'s1','s2'},   dataset{i} = '1'; emotions{i} = 'surprise';
        case {'d1','d2'},   dataset{i} = '1'; emotions{i} = 'disgust';
        
        % dataset 2
        case {'a1','a2'},   dataset{i} = '2'; emotions{i} = 'angry';
        case {'n1','n2', ...
              'n3','n4', ...
              'n5','n6'},   dataset{i} = '2'; emotions{i} = 'neutral';
        case {'h1','h2'},   dataset{i} = '2'; emotions{i} = 'happy';
        case {'f1','f2'},   dataset{i} = '2'; emotions{i} = 'fear';
        
        otherwise, error('Unknown emotion: %s', parts{2});
      end;
      
      % Hacks
      if (strcmp(subjects{i},'040') && strcmp(parts{2}, 'n5'))
        dataset{i} = '1';
      end;
    end;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_visualizeData(outFile)
  %
  %

    load(outFile);
    nRows = 10;
    nCols = 12;
    
    for objName = {'train' 'test'}
      objName = objName{1};
      obj = eval(objName);
      
      figTitle = sprintf('%dD %s set; stimSet=%s, taskType=%s, opt=%s', ...
                         dim, objName, stimSet, taskType, [opt{:}]);

      figure;
      set(findobj(gcf,'Type','text'),'FontSize',6) ;
    
      for i=1:size(obj.X,2)
        subplot(nRows,nCols,i); 
      
        switch(dim)
          % 2d images can be plotted
          case 2
            imagesc(reshape(obj.X(:,i), nInput)); 
            
          otherwise
            error('No visualization set for %dD', dim);
        end;
        
        %
        set(gca, 'xtick',[],'ytick',[]);
        hold on;
        xlabel(obj.XLAB);
      end;
    
      %
      hold on;
      mfe_suptitle(figTitle);
      
      %
      print(strrep(outFile, '.mat', sprintf('-%s.%s', objName, 'png')), '-dpng');
      close(gcf);
    end;
    
