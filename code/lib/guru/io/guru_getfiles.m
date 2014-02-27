function [files,subdirs] = guru_getfiles(path, filter, traverse)
% Recursive search

  if (~exist('path',    'var')), path='.'; end;
  if (~exist('filter',  'var')), filter='*'; end;
  if (~exist('traverse','var')), traverse=1; end;

  % Get all the files
  files  = dir(fullfile(path,filter));
  files  = files(find([files.isdir]==0));
  files  = rmfield(files,'isdir');
  if (~isempty(files))
    [files.path] = deal(path);
  else
    files = [];
  end;

  % get all the subdirectories
  subdirs = dir(path);
  subdirs = subdirs(find([subdirs.isdir]));
  subdirs = subdirs(find(~strcmp({subdirs.name},'.')));
  subdirs = subdirs(find(~strcmp({subdirs.name},'..')));
  subdirs = rmfield(subdirs,'isdir') ;
  if (~isempty(subdirs))
    [subdirs.path] = deal(path);
  end;

  if (traverse)
    for i=1:length(subdirs)
      [tf, ts] = guru_getfiles(fullfile(subdirs(i).path, subdirs(i).name), filter, traverse);

      if (~isempty(tf)), files    = [files; tf];   end;
      if (~isempty(ts)), subdirs  = [subdirs; ts]; end;
    end;
  end;
