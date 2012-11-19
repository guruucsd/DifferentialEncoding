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
        ERROR(isnan(ERROR)) = 0; % this is what happens when you hit it exactly; 0*-inf.
        ERROR(isinf(ERROR)) = log(1000); % this is what happens when your value is exact (0 or 1), and it's wrong.  Make it look like 0.999 or 0.001
        guru_assert(all(T>=0 & T<=1), 'for cross-entropy error to work, T must be between 0 and 1')
        guru_assert(all(Y>=0 & Y<=1), 'for cross-entropy error to work, Y must be between 0 and 1')
  end;
