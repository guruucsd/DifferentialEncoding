function de_migrateProperty(origPropName, newPropName)
  a=dir('.');
  
  for f=1:length(a)
    if (f.isdir), continue; end;
    if (~strcmp('.mat',guru_fileparts(f.name,'ext'))), continue; end;
    
    % change the prop
    r     = load(f.name);
    model = de_changeProperty(model, origPropName, newPropName);
    for i=1:prod(size(models))
      models(i) = de_changeProperty(models(i), origPropName, newPropName);
    end;
    
    % save the results
    save(f.name, 'model','models');
  end;
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function model = de_changeProperty(model, origPropName, newPropName)
  %
    if (isfield(model,origPropName))
      model = setField(model,newPropName,getField(model,origPropName));
      model = rmField(model,origPropName);
    end;
    
    if (isfield(model,'ac'))
      model.ac = de_changeProperty(model.ac, origPropName, newPropName);
    end;
    if (isfield(model,'p'))
      model.p  = de_changeProperty(model.ac, origPropName, newPropName);
    end;
    