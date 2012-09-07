function fn = guru_getTmpFilename(stem, ext)

if ~exist('stem','var'), stem = 'test'; end;

i=0;
while true
  if (exist('ext','var')), fn = sprintf('%s%d.%s', stem, i, ext); 
  else,                    fn = sprintf('%s%d', stem, i);
  end;
  
  if ~exist(fn, 'file'), break; end;
  
  i = i + 1;
end;
