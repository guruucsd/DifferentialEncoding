function [part] = guru_fileparts(filename, partName)
% [part] = guru_fileparts(filename, part)
%
% Like MATLAB fileparts, but you specify the part you want. 
% Allows better inlining / succinctness of code

  [pathstr, name, ext, versn] = fileparts(filename);
  
  switch (partName)
    case 'pathstr', part = pathstr;
    case 'name',    part = name;
    case 'ext',     part = ext;
    case 'versn',   part = versn;
    otherwise,      error('Unknown file part: %s', partName);
  end;
