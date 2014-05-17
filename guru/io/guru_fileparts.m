function [part] = guru_fileparts(filename, partName)
% [part] = guru_fileparts(filename, part)
%
% Like MATLAB fileparts, but you specify the part you want.
% Allows better inlining / succinctness of code

  if ~exist('partName','var'), partName = 'path'; end;

  [pathstr, name, ext] = fileparts(filename);

  switch (partName)
    case {'path','pathstr'}, part = pathstr;
    case 'name',    part = name;
    case 'ext',     part = ext;
%    case 'versn',   part = versn;
    case 'filename', part = [name ext];
      case 'dir', part = guru_fileparts(guru_fileparts(filename, 'path'), 'name');

    otherwise,      error('Unknown file part: %s', partName);
  end;
