function DE_PATH = de_GetBaseDir(p)
  global DE_PATH;

  if (exist('DE_PATH','var') && ~isempty(DE_PATH))
      return;
  elseif (~exist('p','var'))
    p = pwd;
  end;

  while (length(p)>1)
     if (exist(fullfile(p, 'code')) == 7 ...
         && exist(fullfile(p, 'experiments')) == 7)
         break;
     end;
     p=guru_fileparts(p, 'pathstr'); %go to parent directory
  end;

  if (length(p)==1)
      try,
          p = de_GetBaseDir('~/de');

          error('BaseDir not found.  DE basedir must contain "code" and "scripts" subdirectories');
          p = [];
      end;
  end;

  % We have it!
  DE_PATH = p;
