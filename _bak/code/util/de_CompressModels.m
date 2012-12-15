function [models] = de_CompressModels(models)
%
%

  % Compress the data
  for i=1:prod(size(models))
    % Can get connectivity matrix back later
    if (isfield(models(i).ac,'Conn'))
      if (~isempty(models(i).ac.Conn))
        models(i).ac.Weights = sparse(models(i).ac.Weights.*models(i).ac.Conn);
      end;
      models(i).ac = rmfield(models(i).ac,'Conn');
    end;
    
    % Can get connectivity matrix back later
    if (isfield(models(i), 'p') && isfield(models(i).p,'Conn'))
      if (~isempty(models(i).p.Conn))
        models(i).p.Weights = sparse(models(i).p.Weights.*models(i).p.Conn);
        models(i).p = rmfield(models(i).p,'Conn');
      end;
    end;
  end;