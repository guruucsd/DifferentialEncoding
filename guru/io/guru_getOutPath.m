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
    case {'cache'}
        project_name = guru_getProjectName();
        outdir = fullfile('~', '_cache', project_name);

    case {'datasets'}
        outdir = fullfile('~', 'datasets');

    case {'plot', 'results'}
        project_dir = guru_getProjectDir();
        outdir = fullfile(project_dir, 'results');

    otherwise
          error('Unknown type: %s', dirtype);
end;


function script_name = guru_getScriptName()
    abc = dbstack;
    script_name = abc(length(abc)).name;


function script_dir = guru_getScriptDir()
    script_name = guru_getScriptName();
    script_dir = fileparts(which(script_name));


function project_dir = guru_getProjectDir()
    d = guru_getScriptDir();
    while d
        if exist(fullfile(d, '.git'), 'dir')
            break
        end;
        d = fileparts(d);
    end;
    project_dir = d;


function project_name = guru_getProjectName()
    project_dir = guru_getProjectDir();
    project_name = guru_fileparts(project_dir, 'name');
