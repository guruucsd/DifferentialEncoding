function [cargs]  = base_args_and_setup(varargin)

  %% Generic setup
  more off
  if exist('OCTAVE_VERSION', 'builtin') == 0  % MATLAB
    dbstop if error
    dbstop if warning
  else  % OCTAVE
    debug_on_error = 1;
    pkg load image;
    pkg load statistics;
  end;

  % Add absolute path to the 'code' directory
  script_dir = fileparts(which(mfilename));
  code_dir = fullfile(script_dir, '..', 'code');
  addpath(genpath(code_dir));

  % Return whatever args we got (for now)
  cargs = varargin;