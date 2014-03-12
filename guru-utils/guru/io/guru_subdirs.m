function [results] = guru_subdirs(path, filter)
  if (~exist('filter','var'))
    filter = '*';
  end;
  
  results = dir(fullfile(path, filter));
  results = results(find([results.isdir]==1));
  results = results(find(~strcmp({results.name},'.')));
  results = results(find(~strcmp({results.name},'..')));
  