function DE_PATH = de_GetBaseDir(p)
  global DE_PATH;
  
  if (exist('DE_PATH','var') && ~isempty(DE_PATH))
      return;
  elseif (~exist('p','var'))
    p = pwd;
  end;

  while (length(p)>1)
     if ((guru_findstr('v1.', guru_fileparts(p, 'name'))==1) || ...
         (guru_findstr('v2.', guru_fileparts(p, 'name'))==1) || ...
         (guru_findstr('v3.', guru_fileparts(p, 'name'))==1) || ...
         (guru_findstr('v4.', guru_fileparts(p, 'name'))==1) || ...
         (guru_findstr('v5.', guru_fileparts(p, 'name'))==1) || ...
         (guru_findstr('v6.', guru_fileparts(p, 'name'))==1) || ...
         (guru_findstr('v7.', guru_fileparts(p, 'name'))==1) || ...
         (      strcmp('DE',  guru_fileparts(p, 'name'))))
        break;
     end;
     p=guru_fileparts(p, 'pathstr'); %go to parent directory
  end;

  if (length(p)==1)
      error('BaseDir not found.  DE basedir must be embedded in a directory starting with "v1."');
    p = [];
  elseif (~exist(fullfile(p, 'code')))
      error('BaseDir identified but does not contain directory "code".');
  end;
  
  % We have it!
  DE_PATH = p;
