function dates = datefromtext(txt, species, type)
  if ~exist('type','var'), type='postconception'; end;
  if ~iscell(txt), txt = {txt}; end;

  dates = str2date(txt, species, type);
  