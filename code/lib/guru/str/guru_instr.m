function b = guru_instr(strs, substrs)
    if ~iscell(strs),    b = guru_instr({strs}, substrs); return; end;
    if ~iscell(substrs), b = guru_instr(strs,  {substrs}); return; end;
    
    b = false(size(strs));

    for i=1:length(substrs)
        nob = find(~b);
        if (isempty(nob)), break; end;
        
        f = strfind(strs(nob), substrs{i});
        for j=1:length(f)
            b(nob(j)) = ~isempty(f{j});
        end;
    end;
    