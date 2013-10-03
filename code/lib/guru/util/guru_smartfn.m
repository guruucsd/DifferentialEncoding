function fn = guru_smartfn(fn,type)
% function fn = guru_smartfn(fn,type)
%
% Returns a file path that is guaranteed to not yet contain a file.
%
% Inputs:
% fn   : Desired file path/name
% type : file or dir
%
% Outputs:
% fn : Generated file path/name where no file exists

  if (~exist('type','var')), type = 'file'; end;

  % 
  [PATHSTR,NAME,EXT,VERSN]       = fileparts(fn);
  if (isempty(EXT)),     EXT     = '';  end;
  if (isempty(PATHSTR)), PATHSTR = '.'; end;

  fn = [PATHSTR filesep NAME EXT];

  i = 0;
  while (exist(fn,type))
    i = i + 1;
    fn = sprintf('%s%s%s-%d%s', PATHSTR, filesep, NAME, i, EXT);
  end;
