function de_SetupExptPaths(expt_name)
% This function calls generic functions that are implemented / overwritten
%   by particular experiments.  Add the path to the current experiment, so that
%   it's functions are the ones run.

  % Find the directory for this experiment
  expt_dir = de_GetExptDir(expt_name);
  if (~exist(expt_dir, 'dir')), error('Experiment does not exist at expected directory: %s', expt_dir); end;

  % Parse out paths
  p = mfe_split(':', path());
  
  % Remove all other experiments
  base_expts_dirname = guru_fileparts(guru_fileparts(expt_dir, 'path'), 'name');
  other_expt_dirs    = p(guru_instr(p, fullfile('',base_expts_dirname,'')));
  if (~isempty(other_expt_dirs)), 
      rmpath(other_expt_dirs{:}); % a hack about the structure of the directories here
  end;
  
  % Add back THIS experiment to the top of the path
  addpath(genpath(expt_dir));
