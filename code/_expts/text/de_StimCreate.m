function [train,test,aux] = de_StimCreate(stimSet, taskType, opt)
%

  if (~exist('stimSet', 'var') || isempty(stimSet)), stimSet  = 'kangaroos'; end;
  if (~exist('taskType','var')), taskType = '';     end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  script_dir = fileparts(which(mfilename));
  text_filepath = fullfile(script_dir, sprintf('%s.txt', stimSet));
  if ~exist(text_filepath, 'file')
      error('stimSet must point to a valid text file within %s', script_dir);
  end;
  txt = fileread(text_filepath);
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

