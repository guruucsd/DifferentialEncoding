function models = de_LoadProps(models, objname, propname)
%
%

  % List of props
  if (iscell(propname))
    for i=1:length(propname)
      models = de_LoadProps(models, objname, propname{i});
    end;

  % Single props
  else

    switch (propname)
      case 'Weights', inPropname = lower(propname);
      otherwise,      inPropname = propname;
    end;

    % Easy and efficient to do for a single model
    if (length(models)==1)
      if (~isfield(models.(objname), propname))
        models.(objname).(propname) = guru_loadVars( de_GetOutFile(models, [objname '.' inPropname]), inPropname );
      end;

    % Slower and harder to do an array of objects
    else
      if (~isfield(models(1).(objname), propname))
        obj = {models.(objname)};
        for i=1:length(models)
          obj{i}.Weights = guru_loadVars( de_GetOutFile(models(i), [objname '.' inPropname]), inPropname );
        end;
     
        [models.(objname)] = deal(obj{:});
      end;
    end;
  end;
