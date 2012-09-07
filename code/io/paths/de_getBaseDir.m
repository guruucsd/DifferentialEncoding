function p = de_getBaseDir(p)
  if (~exist('d','var'))
    p = pwd;
  end;

  while (length(p)>1 && (~exist(fullfile(p,'code')) || ~exist(fullfile(p,'scripts')) || ~exist(fullfile(p,'data'))))
     p=guru_fileparts(p, 'pathstr');
  end;

  if (length(p)==1)
    p = [];
  elseif (~exist('guru_nnTrain','file'))
    addpath(genpath(fullfile(p, 'code')));
  end;
