function carr = csprintf(fmt, cells, delim)
%function carr = csprintf(fmt, cells, delim)
%
% Prints a cell array of values to a cell array of string
%
% Inputs:
% fmt   : format string
% cells : cell array to print
% delim : (optional) delimiter to use to make the trick work.
%
% Outputs:
% carr  : cell array of strings

  if (~exist('delim','var') || isempty(delim))
    delim = '|x|';
  end;
  
  carr = mfe_split(delim, sprintf([fmt delim], cells{:}));
  carr = carr(1:end-1);