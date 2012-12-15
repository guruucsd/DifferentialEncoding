function [outFile] = de_StimCreate(expt, stimSet, taskType, opt)
%
%Input:
%  stimSet  : a string specifying which INPUT sets to train autoencoder on
%              de       => (default) equal weighting to LpSm LmSp LpSp LmSm
%              dff      => equal weighting to LpSm LmSp only
%              sergent  => equal weighting to "positive" and "negative",
%                         where "negative" == [LmSm] and "positive" is
%                         everything else
%  taskType : a string specifying which OUTPUT task to train on
%              dff      => 4 localist outputs, specifying whether one of two
%                          particular targets is at the local or global
%                          level (must be run with dff stimSet)
%              gary     => similar to dff task, but uses a non-localist output
%                          to express all 6 conditions in the sergent stimSet.
%              mtl      => 6 outputs, distributed as follows:
%                          (2) a target is present at the local/global level
%                          (2) a distracter is present at the local/global level
%                          (2) the sergent task below
%              sergent  => (default) single output: is there a target?
%  opt      : a vector of options; all listed will be applied
%               reza-ized => switch one distracter with one target (to replicate published DE)
%               swapped  => switch all targets with all distracters
%                           (note: a better test is to switch one target
%                            with one distracter)
%
%OUTPUT: a data file with the following variables:
%
%  LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID: indices representing the 8 different trial types
%
%  TALL:  index containing above 8 indices
%  TLBL : labels for all trial types, as indexed above
%  
%  STIM : cell array containing each stimulus (usually 4: 2 targets, 2 distracters
%
%  train.X    : matrix containing 16 vectors, each a unique hierarchical stimulus.
%  train.TT   : 16 indices, one for each hierarchical stimulus, taken from TALL
%  train.ST   : vector of 16 strings, describing each unique hierarchical stimulus.  
%               Tells the two stimuli and relationship that make up the hierarchical stimulus
%  train.TIDX : ?
%
%  train.Y    : target vectors for autoencoder (same as X)
%  train.T    : target vectors for perceptron (labels, based on task)
%
%  test.*     : same as train object, but 

  if (~exist('stimSet', 'var')), stimSet  = 'de'; end;
  if (~exist('taskType','var')), taskType = 'sergent';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  nInput = guru_getopt(opt, 'nInput', [31 13]);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Assign an index to each stimulus type
  global LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID;
  LpSpID  = 1;
  LpSpNID = 2;
  LpSm    = 3;
  LmSp    = 4;
  LmSmID  = 5;
  LmSmNID = 6;
  LpSp    = 7; %these are not actual conditions, but can be used for summary
  LmSm    = 8; % this too

  TALL = [LpSm LmSp LpSpID LpSpNID LmSmID LmSmNID LpSp LmSm];

  % Labels for reporting / plotting
  TLBL{LpSm}    = 'L+S-';
  TLBL{LmSp}    = 'L-S+';
  TLBL{LpSp}    = 'L+S+';
  TLBL{LmSm}    = 'L-S-';

  TLBL{LpSpID}  = sprintf('L+S+ ID');
  TLBL{LpSpNID} = sprintf('L+S+ N.ID');
  TLBL{LmSmID}  = sprintf('L-S- ID');
  TLBL{LmSmNID} = sprintf('L-S- N.ID');

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % With this info, create our X and TT vectors
  [train.X, STIM, train.ST] = stim2D(nInput);
  % Normalize X: 0 mean, from -0.5 to 0.5
  %train.X = train.X - mean(mean(train.X));
  %if (abs(max(max(train.X))) > abs(min(min(train.X))))
  %  train.X = train.X*(0.5/max(max(train.X)));
  %else
  %  train.X = train.X*(-0.5/min(min(train.X)));
  %end;
  
  
  % Now index and apply options, including input weightings.
  [train.TIDX, train.TT]                    = de_indexStim(TALL, train.ST);
  [train.ST, STIM, train.TIDX, train.TT]    = de_applyOptions(opt, train.ST, STIM, TALL, train.TIDX, train.TT);
  [train.X, train.ST, train.TIDX, train.TT] = de_createTrainingSets(stimSet, train.X, train.ST, TALL, train.TIDX, train.TT);

  % Nail down targets for each task
  [train.T]         = de_createTargets(taskType, train.X, train.ST, train.TT);
  
  train.nInput = nInput;
  
  train.XLAB = cell(size(train.X,2),1); 
  train.TLAB = cell(size(train.XLAB)); 
  for i=1:length(train.XLAB)
    lgStim = (train.ST{i}(2)-'0') + (train.ST{i}(1)=='D')*2;
    smStim = (train.ST{i}(4)-'0') + (train.ST{i}(3)=='D')*2;
 
    train.XLAB{i} = sprintf('%s|%s', STIM{lgStim}, STIM{smStim});
    train.TLAB{i} = TLBL{train.TT(i)};
  end;
  
  % Now say that test data is the same as training data.
  test = train;
  
  % Output everything (including images)  
  outFile        = de_GetDataFile(expt, stimSet, taskType, opt);
  if (~exist(guru_fileparts(outFile,'pathstr'), 'dir'))
    mkdir(guru_fileparts(outFile,'pathstr'), 'dir');
  end;
  save(outFile);

  %de_visualizeData(outFile);

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [TIDX, TT] = de_indexStim(TALL, ST)
  %
  %
  %
    global LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID
    
    TT = zeros(size(ST));
    TT(find(strcmp(ST, 'T1T1'))) = LpSpID;
    TT(find(strcmp(ST, 'T2T2'))) = LpSpID;
    TT(find(strcmp(ST, 'T1T2'))) = LpSpNID;
    TT(find(strcmp(ST, 'T2T1'))) = LpSpNID;
    TT(find(strcmp(ST, 'D1D1'))) = LmSmID;
    TT(find(strcmp(ST, 'D2D2'))) = LmSmID;
    TT(find(strcmp(ST, 'D1D2'))) = LmSmNID;
    TT(find(strcmp(ST, 'D2D1'))) = LmSmNID;
    TT(find(strcmp(ST, 'T1D1'))) = LpSm;
    TT(find(strcmp(ST, 'T1D2'))) = LpSm;
    TT(find(strcmp(ST, 'T2D1'))) = LpSm;
    TT(find(strcmp(ST, 'T2D2'))) = LpSm;
    TT(find(strcmp(ST, 'D1T1'))) = LmSp;
    TT(find(strcmp(ST, 'D1T2'))) = LmSp;
    TT(find(strcmp(ST, 'D2T1'))) = LmSp;
    TT(find(strcmp(ST, 'D2T2'))) = LmSp;
    
    % 
    for i=TALL
      TIDX{i} = find(TT==i); 
    end;
    % Manually paste on 'summary' types
    TIDX{LpSp} = [TIDX{LpSpID} TIDX{LpSpNID}];
    TIDX{LmSm} = [TIDX{LmSmID} TIDX{LmSmNID}];

    
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X, ST, TIDX, TT] = de_createTrainingSets(stimSet, X, ST, TALL, TIDX, TT)
  %
  %  Take the original set of one unique stimuli, and duplicate / eliminate
  %  some to make a true training set.  Then massage all other dependent
  %  variables to make them match.

    global LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID
    
    % Triplicate ID/NID for - cases
    %16: 4 LpSm, 4 LmSp, 2 LpSpID, 2 LpSpNID, 2 LmSmID, 2 LmSmNID
    %Ser 8       8       8         8         16        16
    
    switch (stimSet)
      case 'dff'
        reindex = [TIDX{LpSm} TIDX{LmSp}];
        
      case 'de' %no-op (taken care of at stim2D level)
        reindex = 1:size(X,2);

      case 'sergent'
        reindex = [TIDX{LpSm}    TIDX{LpSm} ...
                   TIDX{LmSp}    TIDX{LmSp} ...
                   TIDX{LpSpID}  TIDX{LpSpID}  TIDX{LpSpID}  TIDX{LpSpID} ...
                   TIDX{LpSpNID} TIDX{LpSpNID} TIDX{LpSpNID} TIDX{LpSpNID} ...
                   TIDX{LmSmID}  TIDX{LmSmID}  TIDX{LmSmID}  TIDX{LmSmID} ...
                   TIDX{LmSmID}  TIDX{LmSmID}  TIDX{LmSmID}  TIDX{LmSmID} ...
                   TIDX{LmSmNID} TIDX{LmSmNID} TIDX{LmSmNID} TIDX{LmSmNID} ...
                   TIDX{LmSmNID} TIDX{LmSmNID} TIDX{LmSmNID} TIDX{LmSmNID}];

      otherwise
        error('Unknown stimSet type: %s', stimSet);
    end;

    %reindex if necessary
    X = X(:,reindex);
    ST = ST(reindex);
    [TIDX, TT] = de_indexStim(TALL, ST); 
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [ST, STIM, TIDX, TT] = de_applyOptions(opt, ST, STIM, TALL, TIDX, TT)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs

    global LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID

    % each option must update ST; everything else
    %   comes from reindexing.
    i=1;
    while (i<=length(opt))
      switch (opt{i})
      
        % switch all distracters with all targets
        case {'swapped','shuffled'}
          STIM = STIM([4 3 2 1]);
          ST   = strrep(ST, 'T1','[TMP-T1]'); % temp
          ST   = strrep(ST, 'D1','[TMP-D1]'); % 

          ST   = strrep(ST, 'T2','D1'); % T2=>D1
          ST   = strrep(ST, 'D2','T1'); % D2=>T1

          ST   = strrep(ST, '[TMP-T1]', 'D2'); % T1=>D2
          ST   = strrep(ST, '[TMP-D1]', 'T2'); % D1=>T2
        
        % Switch T1 with D2 and vice-verse      
        case {'reza-ized', 'D1#T2'}
          STIM = STIM([1 3 2 4]); %switch T2 with D1
          
          % Do the string switch of T2 with D1
          ST   = strrep(ST, 'T2','[TMP]'); %
          ST   = strrep(ST, 'D1', 'T2'); % set D1 to T2
          ST   = strrep(ST, '[TMP]', 'D1');% set T2 to D1
        
        case 'D2#T2'
          STIM = STIM([1 4 3 2]); %switch T2 with D2
          
          % Do the string switch of T2 with D2
          ST   = strrep(ST, 'T2','[TMP]'); %
          ST   = strrep(ST, 'D2', 'T2'); % set D2 to T2
          ST   = strrep(ST, '[TMP]', 'D2');% set T2 to D2
        
        case 'D1#T1'
          STIM = STIM([3 2 1 4]); %switch T1 with D1
          
          % Do the string switch of T1 with D1
          ST   = strrep(ST, 'T1','[TMP]'); %
          ST   = strrep(ST, 'D1', 'T1'); % set D1 to T1
          ST   = strrep(ST, '[TMP]', 'D1');% set T1 to D1
        
        case 'D2#T1'
          STIM = STIM([4 2 3 1]); %switch D2 with T1
          
          % Do the string switch of D2 with T1
          ST   = strrep(ST, 'D2','[TMP]'); %
          ST   = strrep(ST, 'T1', 'D2'); % set T1 to D2
          ST   = strrep(ST, '[TMP]', 'T1');% set D2 to T1
        
        
        case 'nInput' %skip; taken care of when creating targets
            i=i+1; %skip arg
        otherwise
          error('Unknown option: %s', opt{i});
      end;

      [TIDX, TT] = de_indexStim(TALL, ST);
      
      i=i+1;
    end;

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T]         = de_createTargets(taskType, X, ST, TT)
  %
  % Take the input vector and taskType, and create a set of labels
  %
  
    global LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID
  
    % Start out with a blank set of expected results,
    % then add a row for each 'task'
    T=zeros(0,length(TT));
    switch (taskType)
      % 1000 for T1 "local",  0100 T2 "local", 
      % 0010 for T1 "global", 0001 T2 "global"
      case 'dff'
        T(end+1,:)=double(guru_findstr(ST, 'T1')==1); %bit one   for T1 "global"
        T(end+1,:)=double(guru_findstr(ST, 'T2')==1); %bit two   for T2 "global"
        T(end+1,:)=double(guru_findstr(ST, 'T1', 3)==1); %bit three for T2 "local"
        T(end+1,:)=double(guru_findstr(ST, 'T2' ,3)==1); %bit four  for T2 "local"
        
      case 'gary'
        T(end+1,:)=double(guru_findstr(ST, 'T1')==1); %bit one   for T1 "global"
        T(end+1,:)=double(guru_findstr(ST, 'T2')==1); %bit one   for T2 "global"
        T(end+1,:)=double(guru_findstr(ST, 'D1')==1); %bit one   for D1 "global"
        T(end+1,:)=double(guru_findstr(ST, 'D2')==1); %bit one   for D2 "global"
        T(end+1,:)=double(guru_findstr(ST, 'T1', 3)==1); %bit one   for T1 "local"
        T(end+1,:)=double(guru_findstr(ST, 'T2', 3)==1); %bit one   for T2 "local"
        T(end+1,:)=double(guru_findstr(ST, 'D1', 3)==1); %bit one   for D1 "local"
        T(end+1,:)=double(guru_findstr(ST, 'D2', 3)==1); %bit one   for D2 "local"
      
      case 'gd' %globally directed
        T(end+1,:)=double(guru_findstr(ST, 'T1')==1); %bit one   for T1 "global"
        T(end+1,:)=double(guru_findstr(ST, 'T2')==1); %bit one   for T2 "global"
      
      case 'ld' %locally directed
        T(end+1,:)=double(guru_findstr(ST, 'T1', 3)==1); %bit one   for T1 "local"
        T(end+1,:)=double(guru_findstr(ST, 'T2', 3)==1); %bit one   for T2 "local"
      
      case 'pc1'
        T(end+1,:)=double( ismember(TT, [LpSm LpSpID LpSpNID])); % is there a target at the higher level?
        T(end+1,:)=double( ismember(TT, [LmSp LpSpID LpSpNID])); % is there a target at the lower level?
        
      case 'mtl' 
%        T(end+1,:)=double(~ismember(TT, [LmSmID LmSmNID])); % is there a target anywhere?
%        T(end+1,:)=double(~ismember(TT, [LpSpID LpSpNID])); % is there a distracter anywhere?
        T(end+1,:)=double( ismember(TT, [LpSm LpSpID LpSpNID])); % is there a target at the higher level?
        T(end+1,:)=double( ismember(TT, [LmSp LpSpID LpSpNID])); % is there a target at the lower level?
        T(end+1,:)=double( ismember(TT, [LmSp LmSmID LmSmNID])); % is there a distractor at the higher level?
        T(end+1,:)=double( ismember(TT, [LpSm LmSmID LmSmNID])); % is there a distractor at the lower level?
        
      % As defined in Sergent, 1982: is there a target?
      case 'sergent'
        T(end+1,:)=double(~ismember(TT, [LmSmID LmSmNID])); % is there a target anywhere?
    
      case 'sergent2'
        T(end+1,:)=double(~ismember(TT, [LmSmID LmSmNID])); % is there a target anywhere?
        T(end+1,:)=double(ismember(TT, [LmSmID LmSmNID])); % is NOT a target anywhere?
    
      otherwise
        error('Unknown task type: %s', taskType);
    end;
    
  %  T = reshape(T,[1 prod(size(T))])
    
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,STIM,ST] = stim2D(nInput)
    global LpSm LmSp LpSp LmSm LpSpID LpSpNID LmSmID LmSmNID
    
    % File in the following format:
    %H_H, H_F, H_L, H_T
    %T_H, T_F, T_L, T_T
    %F_H, F_F, F_L, F_T
    %L_H, L_F, L_L, L_T
    load(fullfile(de_GetBaseDir(), 'data','Sergent_1982.mat'));  %load the input images 
    midpt = (max(I(:)) -min(I(:)))/2;
    I = 2*midpt-I;  %-(I-midpt) + midpt;
    
    % per Sergent, 1982
    STIM = {'H' 'L' 'T' 'F'};
    ST={'T1T1' 'T1D2' 'T1T2' 'T1D1' ...
        'D1T1' 'D1D2' 'D1T2' 'D1D1' ...
        'D2T1' 'D2D2' 'D2T2' 'D2D1' ...
        'T2T1' 'T2D2' 'T2T2' 'T2D1' ...
       };
    
    % Do we need to resize?
    if (~any(nInput-[31 13]))
        X=I;
    
    else
        yscale = nInput(1)/31;        guru_assert(yscale>1);
        xscale = nInput(2)/13;        guru_assert(xscale>1);
        
        % Rescale image
        X = zeros([nInput size(I,2)]);
        for i=1:size(I,2)
            % Scale one dimension
            tmp    = imresize(reshape(I(:,i), [31 13]), min(xscale,yscale));
          
            % Add padding
            npad = max(nInput - size(tmp));
            npad1 = round(npad/2);
            npad2 = npad - npad1;
          
            if (xscale>yscale)
                X(:,npad1+1:end-npad2,i) = tmp;
            else
                X(npad1+1:end-npad2,:,i) = tmp;
            end;
        end;
        X = reshape(X, [prod(nInput) size(X,3)]);
    end;


    % the stimuli are in a different order than in the 1D case;
    % shuffle them around to match
    %
    % This was done by visual inspection
    X=(X-min(X(:)))/(max(X(:))-min(X(:)));   %normalize the values to range from 0 to 1    
%keyboard


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_visualizeData(outFile)
  %
  %

    load(outFile);
    
    switch (length(train.TT))
      case 64, nRows = 8; nCols = 8;
      case 16, nRows = 4; nCols = 4;
      case 8,  nRows = 2; nCols = 4;
      otherwise,         [nRows,nCols] = guru_optSubplots(length(TT));
    end;
    
    for objName = {'train' 'test'}
      objName = objName{1};
      obj = eval(objName);
      
      obj.X = obj.X - min(min(obj.X));
      obj.X = obj.X / max(max(obj.X));
      %obj.T = round(obj.T*2);

      figTitle = sprintf('HL2D %s set; stimSet=%s, taskType=%s, opt=%s', ...
                         objName, stimSet, taskType, [opt{:}]);

      figure;
      set(findobj(gcf,'Type','text'),'FontSize',6) ;
    
      for i=1:length(obj.TT)
        subplot(nRows,nCols,i); 
        colormap(gray);
                  
        imagesc(reshape(obj.X(:,i), nInput)); 
        
        %
        set(gca, 'xtick',[],'ytick',[]);
        hold on;
        TC = num2cell(round(obj.T(:,i)));
        xlabel(sprintf('%s: %s (%s)', obj.XLAB{i}, sprintf('%d', TC{:}), obj.TLAB{i}));
      end;
    
      %
      hold on;
      mfe_suptitle(figTitle);
      
      %
      print(strrep(outFile, '.mat', sprintf('-%s.%s', objName, 'png')), '-dpng');
      close(gcf);
    end;
    
