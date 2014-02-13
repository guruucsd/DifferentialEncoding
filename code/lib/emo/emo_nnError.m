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
% err : The error calculation^M
% errP: gradient of the error function, evaluated at Y^M
%
% NOTE: $HACK: to make T and Y match for cross-entropy, things got fouled
% up for RAW_ERROR.  Had to add a - sign, for all the gradients... did I
% mess this up, upstream, forgetting a - sign in using the gradient?

  if (~exist('errorType','var') || isempty(errorType)), errorType = 2; end;

  switch(errorType)
    case {1,'abs'},
      if ~exist('RAW_ERROR', 'var'), RAW_ERROR = Y-T; end;
      err = abs(RAW_ERROR);
      if nargout>1, errP = ones(size(Y)); end;

    case {2,'squ'},
      if ~exist('RAW_ERROR', 'var'), RAW_ERROR = Y-T; end;
      err = (RAW_ERROR.^2)/2;
      if nargout>1, errP = -RAW_ERROR; end;

    case {3,'cent'}
        guru_assert(all(T>=0 & T<=1), 'for cross-entropy error to work, T must be between 0 and 1')
        guru_assert(all(Y>=0 & Y<=1), 'for cross-entropy error to work, Y must be between 0 and 1')

        err = -(T.*log(Y) + (1-T).*log(1-Y));
        %keyboard
        %if nnz(isnan(err)) + nnz(isinf(err)) == numel(err)
        %    error('You have %d outputs at 0 and %d outputs at 1, which is %5.1f%% of your outputs.
        err(isnan(err)) = 0; % this is what happens when you hit it exactly; 0*-inf.
        err(isinf(err)) = log(1000); % this is what happens when your value is exact (0 or 1), and it's wrong.  Make it look like 0.999 or 0.001

        if nargout>1,
          if ~exist('RAW_ERROR', 'var'), RAW_ERROR = Y-T; end;
          errP = -RAW_ERROR;
        end;
        guru_assert(all(T>=0 & T<=1), 'for cross-entropy error to work, T must be between 0 and 1')
        guru_assert(all(Y>=0 & Y<=1), 'for cross-entropy error to work, Y must be between 0 and 1')
  end;
