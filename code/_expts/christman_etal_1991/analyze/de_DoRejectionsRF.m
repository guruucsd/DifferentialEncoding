function [varargout] = de_DoRejectionsSF(models, varargin)%rmodes,rc)
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
% models          :
  % Since each sigma is independent, we may have different #s of 'runs'
  %   per sigma.  So, we can't use a matrix of structs, we need to separate
  %   into a cell array.
  nSigmas = size(models,2);
  runs    = size(models,1);
  if (~iscell(models))
    models  = mat2cell(models, runs, ones(1,nSigmas));
  end;

