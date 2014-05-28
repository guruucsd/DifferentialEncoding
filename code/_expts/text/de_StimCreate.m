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

  if (~exist('stimSet', 'var') || isempty(stimSet)), stimSet  = 'kangaroos'; end;
  if (~exist('taskType','var')), taskType = '';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  txt = fileread(fullfile(fileparts(which(mfilename)), sprintf('%s.txt', stimSet)));
  txt_opt = {'FontSize', guru_getopt(opt, 'FontSize', 12), ...
             'FontName', guru_getopt(opt, 'FontName', 'Times'), ...
             'FontWeight', guru_getopt(opt, 'FontWeight', 'Normal') ...
            };

  width = guru_getopt(opt, 'width', 200);
  height = guru_getopt(opt, 'height', 100);
  skip = guru_getopt(opt, 'skip', 20);

  nchar = length(txt);
  nimg = ceil(nchar / skip);

  X = zeros(width, height, nimg); % sideways
  XLAB = cell(nimg, 1);
  fprintf('# images: %d.  ', nimg);
  ii = 1;
  for chr =1:skip:nchar
      fprintf('%d ', ii);
      curtxt = txt([chr:end 1:chr-1]);
      img = guru_text2im(curtxt, width, height, txt_opt{:});
      X(:,:,ii) = reshape(img', size(X(:,:,ii)));
      XLAB{ii} = guru_iff(length(curtxt) > 20, [curtxt(1:20) '...'], curtxt);
      ii = ii + 1;
  end;

  train.X = reshape(X, [width*height nimg]);
  train.XLAB = XLAB;
  train.nInput = [width height];
  test = train;
  aux = struct();

