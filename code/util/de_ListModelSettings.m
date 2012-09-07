function de_ListModelSettings(sPath)
  if (~exist('sPath','var'))
    sPath = 'runs';
    clc;  
  end;

  % loop over each result set with matching stem

  % loop over each result set with matching stem
  results = guru_subdirs(sPath);
  
  for i=1:length(results)
   
    % Loop through subdirectories first
    subdirs = guru_subdirs(fullfile(sPath, results(i).name));
    if (~isempty(subdirs))
      de_ListModelSettings(fullfile(sPath, results(i).name));
    end;
  
    % Determine file and check to make sure it exists.
    matFiles = dir(fullfile(sPath, results(i).name, '*.mat'));

    for j=1:length(matFiles)
      matFile = fullfile(sPath, results(i).name, matFiles(j).name);
      
      if (~exist(matFile, 'file'))
        continue;
      end;
    
      try
        loadedModelSettings = guru_loadVars(matFile, 'modelSettings');
      catch 
      end;

      if (~exist('loadedModelSettings','var'))
        continue;
      end;
      
      fprintf('File: %s\n', matFile);
      fprintf(de_modelSummary(loadedModelSettings));
      fprintf('\n');
    end;
  end;