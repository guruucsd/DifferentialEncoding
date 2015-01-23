function outdir = guru_getOutPath(dirtype)
%
% Points us to specific output paths, given
%   an assumed directory structure
%
% dirtype: 'cache' or 'datasets'
%
% outdir: full local path
%

  switch (dirtype)
    case {'cache'},
        outdir = fullfile('~', '_cache');

    case {'datasets'}
        outdir = fullfile('~', 'datasets');

    case {'results'}
        abc = dbstack;
        script_name = abc(length(abc)).name;
        script_dir = fileparts(which(script_name));
        outdir = fullfile(script_dir, '..', '..', 'results');

    otherwise
          error('Unknown type: %s', dirtype);
end;

%  if (~guru_findstr(de_GetBaseDir(), outdir) && ~guru_findstr('~', outdir))
%    outdir = fullfile(de_GetBaseDir(), outdir);
%  end;


