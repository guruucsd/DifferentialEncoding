function [ERROR] = emo_nnError(RAW_ERROR, errorType)
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
    case 1, ERROR = abs(RAW_ERROR);
    case 2, ERROR = (RAW_ERROR.^2)/2;
    case 3, ERROR = sum(emo_nnError(RAW_ERROR,1),1);
    case 4, ERROR = sum(emo_nnError(RAW_ERROR,2),1);
    case 5, ERROR = sum(emo_nnError(RAW_ERROR,3));
    case 6, ERROR = sum(emo_nnError(RAW_ERROR,4));
  end;
