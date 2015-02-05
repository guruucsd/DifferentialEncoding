function dates = str2date(txt, species, type)
%function dates = str2date(txt, species, type)
%
% take a date (E56, P122), and converts it
%   to a date since some landmark (by default, conception)
%
% gestation, lifespan: http://pin.primate.wisc.edu/factsheets/entry/chimpanzee
% sexual maturity: http://animaldiversity.ummz.umich.edu/accounts/Pan_troglodytes/


  % Should be static globals
  species_keys      = {'cat',  'macaque','chimp','human'};
  species_birthdate = [150          156       240     270];
  species_adult     = 365*[2.5        4         8      15]; %sexual maturity
  species_death     = 364*[7         25        40      75]; 
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
      elseif strcmp('death',txt{di}), dates(di) = species_death(species_idx);
      else, error('Unknown date type: %s', txt{di});
      end;
  end;
      

  % Then, convert to desired type
  switch type
      case 'postconception', ;
      otherwise, error('Unknown type: %s', type);
  end;