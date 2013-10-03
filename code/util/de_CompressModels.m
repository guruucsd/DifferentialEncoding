function [models] = de_CompressModels(models)
%
% Remove fields that are unnecessary

  % Compress the data
  
  for i=1:prod(size(models))
    % AC:
    %   1. Can get connectivity matrix back later
    %.  2. Eta is a training thing; don't need it
    %
    if (isfield(models(i).ac,'Conn'))
      if (~isempty(models(i).ac.Conn))
        models(i).ac.Weights = sparse(models(i).ac.Weights.*models(i).ac.Conn);
      end;
      models(i).ac = rmfield(models(i).ac,'Conn');
    end;
    
    if (isfield(models(i).ac, 'Eta'))
        models(i).ac = rmfield(models(i).ac, 'Eta');
    end;
    

    % P:
    %   1. Can get connectivity matrix back later
    %   2. Eta is a training thing; don't need it
    %
    if (isfield(models(i), 'p'))
        if (isfield(models(i).p,'Conn'))
            if (~isempty(models(i).p.Conn))
                models(i).p.Weights = sparse(models(i).p.Weights.*models(i).p.Conn);
                models(i).p = rmfield(models(i).p,'Conn');
            end;
        end;

        if (isfield(models(i).p, 'Eta'))
            models(i).p = rmfield(models(i).p, 'Eta');
        end;
    end;    
    
    
    % data
    %   1. train and test are big but redundant; we have the dataFile stamped
    %
    %if (isfield(models(i), 'data'))
    %   if (isfield(models(i).data, 'train')), models(i).data = rmfield(models(i).data,'train'); end;
    %   if (isfield(models(i).data, 'test')),  models(i).data = rmfield(models(i).data,'test');  end;
    %end;
    
  end;