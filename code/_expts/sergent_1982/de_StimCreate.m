function [train,test,aux] = de_StimCreate(stimSet, taskType, opt)
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

  if (~exist('stimSet', 'var') || isempty(stimSet)), stimSet  = 'sergent'; end;
  if (~exist('taskType','var')), taskType = 'sergent';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Assign an index to each stimulus type
  idx.LpSpID  = 1;
  idx.LpSpNID = 2;
  idx.LpSm    = 3;
  idx.LmSp    = 4;
  idx.LmSmID  = 5;
  idx.LmSmNID = 6;
  idx.LpSp    = 7; %these are not actual conditions, but can be used for summary
  idx.LmSm    = 8; % this too

  TALL = [idx.LpSm idx.LmSp idx.LpSpID idx.LpSpNID idx.LmSmID idx.LmSmNID idx.LpSp idx.LmSm];

  % Labels for reporting / plotting
  TLBL{idx.LpSm}    = 'L+S-';
  TLBL{idx.LmSp}    = 'L-S+';
  TLBL{idx.LpSp}    = 'L+S+';
  TLBL{idx.LmSm}    = 'L-S-';

  TLBL{idx.LpSpID}  = sprintf('L+S+ ID');
  TLBL{idx.LpSpNID} = sprintf('L+S+ N.ID');
  TLBL{idx.LmSmID}  = sprintf('L-S- ID');
  TLBL{idx.LmSmNID} = sprintf('L-S- N.ID');


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % With this info, create our X and TT vectors
  [train.X, STIM, train.ST, train.nInput] = stim2D(idx);

  % Now index and apply options, including input weightings.
  if (~isempty(taskType))
      [train.TIDX, train.TT]                    = de_indexStim(TALL, train.ST, idx);
      [train.ST, STIM, train.TIDX, train.TT]    = de_selectTask(taskType, train.ST, STIM, TALL, train.TIDX, train.TT, idx);
      [train.X, train.ST, train.TIDX, train.TT] = de_createTrainingSets(stimSet, train.X, train.ST, TALL, train.TIDX, idx);
      [train.X, train.ST, train.TIDX, train.TT] = de_applyOptions(opt, train.X, train.ST, STIM, TALL, train.TIDX, train.TT, idx);

      % Nail down targets for each taskdb
      [train.T]         = de_createTargets(taskType, train.ST, train.TT, idx);

      train.TLAB = cell(size(train.T,2),1);
      for i=1:length(train.TLAB)
        train.TLAB{i} = TLBL{train.TT(i)};
      end;
  end;

  train.XLAB = cell(size(train.X,2),1);
  for i=1:length(train.XLAB)
    lgStim = (train.ST{i}(2)-'0') + (train.ST{i}(1)=='D')*2;
    smStim = (train.ST{i}(4)-'0') + (train.ST{i}(3)=='D')*2;

    train.XLAB{i} = sprintf('%s|%s', STIM{lgStim}, STIM{smStim});
  end;

  % Now say that test data is the same as training data.
  test     = train;
  aux.idx  = idx;
  aux.TLBL = TLBL;



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [TIDX, TT] = de_indexStim(TALL, ST, idx)
  %
  %
  %
    TT = zeros(size(ST));
    TT(find(strcmp(ST, 'T1T1'))) = idx.LpSpID;
    TT(find(strcmp(ST, 'T2T2'))) = idx.LpSpID;
    TT(find(strcmp(ST, 'T1T2'))) = idx.LpSpNID;
    TT(find(strcmp(ST, 'T2T1'))) = idx.LpSpNID;
    TT(find(strcmp(ST, 'D1D1'))) = idx.LmSmID;
    TT(find(strcmp(ST, 'D2D2'))) = idx.LmSmID;
    TT(find(strcmp(ST, 'D1D2'))) = idx.LmSmNID;
    TT(find(strcmp(ST, 'D2D1'))) = idx.LmSmNID;
    TT(find(strcmp(ST, 'T1D1'))) = idx.LpSm;
    TT(find(strcmp(ST, 'T1D2'))) = idx.LpSm;
    TT(find(strcmp(ST, 'T2D1'))) = idx.LpSm;
    TT(find(strcmp(ST, 'T2D2'))) = idx.LpSm;
    TT(find(strcmp(ST, 'D1T1'))) = idx.LmSp;
    TT(find(strcmp(ST, 'D1T2'))) = idx.LmSp;
    TT(find(strcmp(ST, 'D2T1'))) = idx.LmSp;
    TT(find(strcmp(ST, 'D2T2'))) = idx.LmSp;

    %
    for i=TALL
      TIDX{i} = find(TT==i);
    end;
    % Manually paste on 'summary' types
    TIDX{idx.LpSp} = [TIDX{idx.LpSpID} TIDX{idx.LpSpNID}];
    TIDX{idx.LmSm} = [TIDX{idx.LmSmID} TIDX{idx.LmSmNID}];




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X, ST, TIDX, TT] = de_createTrainingSets(stimSet, X, ST, TALL, TIDX, idx)
  %
  %  Take the original set of one unique stimuli, and duplicate / eliminate
  %  some to make a true training set.  Then massage all other dependent
  %  variables to make them match.

    % Triplicate ID/NID for - cases
    %16: 4 LpSm, 4 LmSp, 2 LpSpID, 2 LpSpNID, 2 LmSmID, 2 LmSmNID
    %Ser 8       8       8         8         16        16

    switch (stimSet)
      case 'dff'
        reindex = [TIDX{idx.LpSm} TIDX{idx.LmSp}];

      case 'de' %no-op (taken care of at stim2D level)
        reindex = 1:size(X,2);

      case {'sergent_1982'}
        warning('Using duplicated stimuli, to accurately reflect weighting of stimulus classes shown to each subject.')
        reindex = [TIDX{idx.LpSm}    TIDX{idx.LpSm} ...
                   TIDX{idx.LmSp}    TIDX{idx.LmSp} ...
                   TIDX{idx.LpSpID}  TIDX{idx.LpSpID}  TIDX{idx.LpSpID}  TIDX{idx.LpSpID} ...
                   TIDX{idx.LpSpNID} TIDX{idx.LpSpNID} TIDX{idx.LpSpNID} TIDX{idx.LpSpNID} ...
                   TIDX{idx.LmSmID}  TIDX{idx.LmSmID}  TIDX{idx.LmSmID}  TIDX{idx.LmSmID} ...
                   TIDX{idx.LmSmID}  TIDX{idx.LmSmID}  TIDX{idx.LmSmID}  TIDX{idx.LmSmID} ...
                   TIDX{idx.LmSmNID} TIDX{idx.LmSmNID} TIDX{idx.LmSmNID} TIDX{idx.LmSmNID} ...
                   TIDX{idx.LmSmNID} TIDX{idx.LmSmNID} TIDX{idx.LmSmNID} TIDX{idx.LmSmNID}];

      otherwise
        error('Unknown stimSet type: %s', stimSet);
    end;

    %reindex if necessary
    X = X(:,reindex);
    ST = ST(reindex);
    [TIDX, TT] = de_indexStim(TALL, ST, idx);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [ST, STIM, TIDX, TT] = de_selectTask(taskType, ST, STIM, TALL, TIDX, TT, idx)

    switch (taskType)

        % switch all distracters with all targets
        case {'sergent-swapped','sergent-shuffled'}
          STIM = STIM([4 3 2 1]);
          ST   = strrep(ST, 'T1','[TMP-T1]'); % temp
          ST   = strrep(ST, 'D1','[TMP-D1]'); %

          ST   = strrep(ST, 'T2','D1'); % T2=>D1
          ST   = strrep(ST, 'D2','T1'); % D2=>T1

          ST   = strrep(ST, '[TMP-T1]', 'D2'); % T1=>D2
          ST   = strrep(ST, '[TMP-D1]', 'T2'); % D1=>T2

        % Switch T1 with D2 and vice-verse
        case {'sergent-reza-ized', 'sergent-D1#T2'}
          STIM = STIM([1 3 2 4]); %switch T2 with D1

          % Do the string switch of T2 with D1
          ST   = strrep(ST, 'T2','[TMP]'); %
          ST   = strrep(ST, 'D1', 'T2'); % set D1 to T2
          ST   = strrep(ST, '[TMP]', 'D1');% set T2 to D1

        case 'sergent-D2#T2'
          STIM = STIM([1 4 3 2]); %switch T2 with D2

          % Do the string switch of T2 with D2
          ST   = strrep(ST, 'T2','[TMP]'); %
          ST   = strrep(ST, 'D2', 'T2'); % set D2 to T2
          ST   = strrep(ST, '[TMP]', 'D2');% set T2 to D2

        case 'sergent-D1#T1'
          STIM = STIM([3 2 1 4]); %switch T1 with D1

          % Do the string switch of T1 with D1
          ST   = strrep(ST, 'T1','[TMP]'); %
          ST   = strrep(ST, 'D1', 'T1'); % set D1 to T1
          ST   = strrep(ST, '[TMP]', 'D1');% set T1 to D1

        case 'sergent-D2#T1'
          STIM = STIM([4 2 3 1]); %switch D2 with T1

          % Do the string switch of D2 with T1
          ST   = strrep(ST, 'D2','[TMP]'); %
          ST   = strrep(ST, 'T1', 'D2'); % set T1 to D2
          ST   = strrep(ST, '[TMP]', 'T1');% set D2 to T1
    end;

    [TIDX, TT] = de_indexStim(TALL, ST, idx);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X, ST, TIDX, TT] = de_applyOptions(opt, X, ST, STIM, TALL, TIDX, TT, idx)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T]         = de_createTargets(taskType, ST, TT, idx)
  %
  % Take the input vector and taskType, and create a set of labels
  %

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
        T(end+1,:)=double( ismember(TT, [idx.LpSm idx.LpSpID idx.LpSpNID])); % is there a target at the higher level?
        T(end+1,:)=double( ismember(TT, [idx.LmSp idx.LpSpID idx.LpSpNID])); % is there a target at the lower level?

      case 'mtl'
%        T(end+1,:)=double(~ismember(TT, [LmSmID LmSmNID])); % is there a target anywhere?
%        T(end+1,:)=double(~ismember(TT, [LpSpID LpSpNID])); % is there a distracter anywhere?
        T(end+1,:)=double( ismember(TT, [idx.LpSm idx.LpSpID idx.LpSpNID])); % is there a target at the higher level?
        T(end+1,:)=double( ismember(TT, [idx.LmSp idx.LpSpID idx.LpSpNID])); % is there a target at the lower level?
        T(end+1,:)=double( ismember(TT, [idx.LmSp idx.LmSmID idx.LmSmNID])); % is there a distractor at the higher level?
        T(end+1,:)=double( ismember(TT, [idx.LpSm idx.LmSmID idx.LmSmNID])); % is there a distractor at the lower level?

      % As defined in Sergent, 1982: is there a target?
      case {'sergent' ...
            'sergent-swapped','sergent-shuffled', ...
            'sergent-reza-ized', 'sergent-D1#T2', ...
            'sergent-D2#T2', ...
            'sergent-D1#T1', ...
            'sergent-D2#T1'}
        T(end+1,:)=double(~ismember(TT, [idx.LmSmID idx.LmSmNID])); % is there a target anywhere?


      case 'sergent2'
        T(end+1,:)=double(~ismember(TT, [idx.LmSmID idx.LmSmNID])); % is there a target anywhere?
        T(end+1,:)=double(ismember(TT, [idx.LmSmID idx.LmSmNID])); % is NOT a target anywhere?

      otherwise
        error('Unknown task type: %s', taskType);
    end;

  %  T = reshape(T,[1 prod(size(T))])


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,STIM,ST,nInput] = stim2D(idx)
    nInput = [34 25];

    % File in the following format:
    %H_H, H_F, H_L, H_T
    %T_H, T_F, T_L, T_T
    %F_H, F_F, F_L, F_T
    %L_H, L_F, L_L, L_T
    load(fullfile(de_GetOutPath([], 'datasets'), 'sergent', 'Sergent_1982.mat'));  %load the input images
    midpt = (max(I(:)) -min(I(:)))/2;
    I = 2*midpt-I;  %-(I-midpt) + midpt;

    % per Sergent, 1982
    STIM = {'H' 'L' 'T' 'F'};
    ST={'T1T1' 'T1D2' 'T1T2' 'T1D1' ...
        'D1T1' 'D1D2' 'D1T2' 'D1D1' ...
        'D2T1' 'D2D2' 'D2T2' 'D2D1' ...
        'T2T1' 'T2D2' 'T2T2' 'T2D1' ...
       };

    % Take 31x13 image, expand to 34x25 by padding
    X = zeros(prod(nInput),size(I,2));
    for ii=1:16
        X_tmp = zeros([34 25]);
        X_tmp(3:end-1,7:end-6) = reshape(I(:,ii), [31 13]);
        %X_tmp = imresize(X_tmp, 4, 'nearest');
        %X_tmp = X_tmp(2:end,:); % remove first row
        X(:,ii) = reshape(X_tmp, [prod(nInput) 1]);
    end;

    X = (X-min(X(:)))/(max(X(:))-min(X(:)));   %normalize the values to range from 0 to 1
    X = round(X);                              % Make into binary image

    guru_assert(~any(mod(X(:),1)));
