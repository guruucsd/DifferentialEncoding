function b = guru_hasopt(opt, val)

b = false;
for ii=1:length(opt)
    if (~ischar(opt{ii})), continue; end;
    
    b = strcmp(opt{ii}, val);
    if (b), return; end;
end;
