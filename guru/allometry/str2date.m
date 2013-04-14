function dates = str2date(txt, species, type)
  % Should be static globals
  species_keys = {'cat','macaque'};
  species_birthdate = [150 156];
  species_adult = [365*2.5 365*4];
  
  % 
  if ~exist('type','var'), type='postconception'; end;
  if ~iscell(txt), txt = {txt}; end;
  
  % First calc from conception
  species_idx = find(strcmp(species_keys, species));
  if isempty(species_idx), error('unknown species: %s', species); end;
  
  
  dates = zeros(size(txt));
  for di=1:numel(txt)
      if     txt{di}(1)=='E',         dates(di) = str2num(txt{di}(2:end));
      elseif txt{di}(1)=='P',         dates(di) = species_birthdate(species_idx) + str2num(txt{di}(2:end));
      elseif strcmp('adult',txt{di}), dates(di) = species_adult(species_idx);
      else, error('Unknown date type: %s', txt{di});
      end;
  end;
      

  % Then, convert to desired type
  switch type
      case 'postconception', ;
      otherwise, error('Unknown type: %s', type);
  end;