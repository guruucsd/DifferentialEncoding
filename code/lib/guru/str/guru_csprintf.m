function carr = guru_csprintf(fmt, cells, delim)
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
    delim = '|||';
  end;
  
  %
  if (exist('fmt','var') && ~isempty(fmt))
    carr = mfe_split(delim, sprintf([fmt delim], cells{:}));
    carr = carr(1:end-1);
   
  % oh no, must auto-detect!
  else
      carr = cell(size(cells));
      
      for i=1:length(cells)
          if     (iscell    (cells{i})), carr{i} = guru_cell2str(cells{i}, ' ');
          elseif (isnumeric (cells{i})), carr{i} = ['[' num2str(cells{i}) ']'];
          elseif (ischar    (cells{i})), carr{i} = cells{i};
          elseif (isinteger (cells{i})), carr{i} = num2str(cells{i});
          elseif (islogical (cells{i})), carr{i} = num2str(cells{i});
          elseif (isfloat   (cells{i})), carr{i} = num2str(cells{i});
          elseif (isreal    (cells{i})), carr{i} = num2str(cells{i});
          else, error('Unknown type for conversion to string.');
          end;
      end;          
  end;
