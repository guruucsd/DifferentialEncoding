function [ERROR] = emo_nnError(errorType, RAW_ERROR, Y, T)
%
% Input:
% RAW_ERROR  :
% errorType : (optional) error calculation
%                      1 : abs(error)
%                      2 : sum-squared error (divided by 2)
%           (default: 2)
%
% Output:
% ERROR : The error calculation

  if (~exist('errorType','var') || isempty(errorType))
    errorType = 2;
  end;
  
  switch(errorType)
    case {1,'abs'}, ERROR = abs(RAW_ERROR);
    case {2,'squ'}, ERROR = (RAW_ERROR.^2)/2;
    case {3,'cent'}
        ERROR = -(T.*log(Y) + (1-T).*log(1-Y));
%        fprintf('%f\n',sum(ERROR,1))
        guru_assert(all(ERROR>=0), 'abc')
  end;
