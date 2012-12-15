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

  if (~exist('dim',     'var')), dim      = 2;      end;
  if (~exist('stimSet', 'var')), stimSet  = 'low';  end;
  if (~exist('taskType','var')), taskType = 'recog';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  if (~exist('force','var'))     force    = 0;      end;
  dim = 2;
  
  [freqs]   = guru_getopt(opt, 'freqs',   [0.05 0.1 0.2]);
  [nInput]  = guru_getopt(opt, 'nInput',  [31 13]);
  [nPhases] = guru_getopt(opt, 'nPhases', 20);
  [nThetas] = guru_getopt(opt, 'nThetas', 1);
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % With this info, create our X and TT vectors
  [train.X, train.XLAB, phases, thetas] = stim2D(stimSet, 'train', freqs, nInput, nPhases, nThetas);
  [test.X,  test.XLAB,  phases, thetas] = stim2D(stimSet, 'test', freqs, nInput, nPhases, nThetas);

  % Now index and apply options, including input weightings.
  [train.X, train.nInput, train.XLAB] = de_applyOptions(opt, train.X, nInput, train.XLAB);
  [test.X,  test.nInput,  test.XLAB]  = de_applyOptions(opt, test.X,  nInput, test.XLAB);

  % Nail down targets for each task
  [train.T, train.TLAB]         = de_createTargets(taskType, train.X, train.XLAB, freqs);
  [test.T,  test.TLAB]          = de_createTargets(taskType, test.X,  test.XLAB,  freqs);

  % Output everything (including images)  
  outFile        = de_GetDataFile(expt, stimSet, taskType, opt);
  if (~exist(guru_fileparts(outFile,'pathstr'), 'dir'))
    mkdir(guru_fileparts(outFile,'pathstr'));
  end;

  save(outFile, 'train', 'test', 'stimSet', 'taskType', 'opt', ...
                'dim', 'freqs', 'nInput', 'phases', 'thetas');  
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X_new, nInput_new, XLAB_new] = de_applyOptions(opts, X, nInput, XLAB)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs

  XLAB_new = XLAB;
  X_new = X;
  nInput_new = nInput;
      
    for j=1:length(opts)
      if (~ischar(opts{j})), continue; end;

      % each option must update ST; everything else
      %   comes from reindexing.
      opt = opts{j};

      switch (opt)
        case 'small', scale = 0.25;
        case 'med',   scale = 0.5;
        otherwise, continue; %error('Unknown option: %s', opt);
      end;

      nInput_new = size(imresize( reshape(X(:,1), nInput), scale ));
      X_new  = zeros(prod(nInput_new), size(X,2));
      for i=1:size(X,2)
        X_new(:,i) = reshape(imresize( reshape(X(:,i), nInput), scale ), [prod(nInput_new) 1]);
      end;
    end;
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T, TLAB]         = de_createTargets(taskType, X, XLAB, freqs)
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
            
%            switch (i)
%                case 1, TLAB(idx) = deal(repmat({'low'}, size(idx)));
%                case 2, TLAB(idx) = deal(repmat({'med'}, size(idx)));
%                case 3, TLAB(idx) = deal(repmat({'high'}, size(idx)));
%            end;
            TLAB(idx) = deal(repmat({sprintf('freq=%3.2f',freqs(i))}, size(idx)));
        end;        
      
      % Identify by frequency
      case {'recog_freq'}
        guru_assert(length(freqs)==2);
        
        T      = zeros(1, length(XLAB));
        TLAB   = cell (1, length(XLAB));
        
        
        for i=1:length(XLAB)
            parts = mfe_split(', ', XLAB{i});
            
            TLAB{i} = parts{2};
            if (~exist('f1','var')), f1=TLAB{i}; end;
            
            T(i) = strcmp(TLAB{i}, f1);
        end;        
          
        guru_assert(length(find(T)) == length(T)/2);
        
        
        
      % Kitterle task 2: identify by type [sin vs square] wave
      %   note: sin wave = "1"; square wave = 0 (or -1)
      case {'recog_type'}
        guru_assert(length(freqs)==2);
        
        T      = zeros(1, length(XLAB));
        TLAB   = cell (1, length(XLAB));
        
        for i=1:length(XLAB)
            parts = mfe_split(', ', XLAB{i});
            
            TLAB{i} = parts{1};
            T(i) = strcmp(TLAB{i}, 'sin');
        end;        
          
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
    thetas = linspace(0,pi/2, nThetas); %angle of grating; pi/2=vertical
    
    % Determine phases
    phases  = linspace(0,2*pi,2*nPhases+1);
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
                
                XLAB{imgnum} = sprintf('freq=%3.2f, phase=%3.1f, theta=%3.1f', freqs(i), phases(j), thetas(k));


              end;
            end;
          end;
          
          % Make sure dynamic range is between 0 and 1
          X = (X - min(min(X))) / (max(max(X))-min(min(X)));
          
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
                XLAB{imgnum} = sprintf('sin, freq=%3.2f, phase=%3.1f, theta=%3.1f', freqs(i), phases(j), thetas(k));
       
                % square wave for this frequency
                imgnum = imgnum + 1;
                X(:,imgnum) = reshape(mfe_grating2d(freqs(i),phases(j), thetas(k), 1, nInput(1), nInput(2)), [prod(nInput) 1]);
                X(:,imgnum) = double(X(:,imgnum)>=0.0);
                XLAB{imgnum} = sprintf('square, freq=%3.2f, phase=%3.1f, theta=%3.1f', freqs(i), phases(j), thetas(k));
       
              end;
            end;
          end;
          
          % Make sure dynamic range is between 0 and 1
          X = (X - min(min(X))) / (max(max(X))-min(min(X)));
          
    otherwise, error('Stim set %s NYI', set);
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
    
