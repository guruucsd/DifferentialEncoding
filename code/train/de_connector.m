function [Con,Wts] = de_connector(model)
%[Con, mu] = de_connector(model)
%
% Creates a connectivity matrix for the given model
%
% Inputs:
% model : see de_model for details
%
% Outputs:
% Con   : connectivity matrix

  % Train connections
  if (isfield(model.ac,'ct'))
      [Con,Wts] = de_connect_trained(model, model.ac.ct);
  elseif nargout>1
      [Con,Wts] = de_connect_random(model);
  else
      [Con]     = de_connect_random(model);
  end;
