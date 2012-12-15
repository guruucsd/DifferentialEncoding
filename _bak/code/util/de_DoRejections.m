function [mss] = de_DoRejections(mss, rejectTypes, verbose)
%function [rejectTypes, models] = de_DoRejections(models, fittypes,)
%
% Rejects trials based on a given rejections algorithm
%
% Input:
% model         : see de_model for details
% LS            :
% errAutoEnc    :
% rmodes         : (optional) rejections mode
%
% Output:
% rejectTypes     : indices of runs that should be rejected
% models
  if (~exist('verbose','var')), verbose = false; end;
  if (~iscell(mss)),            mss = num2cell(mss, 1); end;

  nSigmas = length(mss);
  
  % Do the rejections
  for k=1:nSigmas
      keepers = sum(rejectTypes{k},2) == 0;

      if (~any(keepers))
          warning('Rejected all (%d/%d) models', length(keepers), length(mss{k}));
      end;
  
      mss{k}  = mss{k}(keepers);

      if (verbose)
        fprintf('Rejections: %d\n', sum(~keepers));    % Show AC & P settings
      end;

  end;
