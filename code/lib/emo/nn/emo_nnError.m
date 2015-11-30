function [err, errP] = emo_nnError(errorType, Y, T, RAW_ERROR)
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

  if (~exist('errorType','var') || isempty(errorType)), errorType = 2; end;

  switch(errorType)
    case {1,'abs'},
      if ~exist('RAW_ERROR', 'var'), RAW_ERROR = Y-T; end;
      err = abs(RAW_ERROR);
      if nargout>1, errP = ones(size(Y)); end;

    case {2,'squ'},
      if ~exist('RAW_ERROR', 'var'), RAW_ERROR = Y-T; end;
      err = (RAW_ERROR.^2)/2;
      if nargout>1, errP = RAW_ERROR; end;

    case {3,'cent'}
        err = -(T.*log(Y) + (1-T).*log(1-Y));
        if ~exist('RAW_ERROR', 'var'), RAW_ERROR = Y-T; end;
          errP = -RAW_ERROR;
        end;
  end;
