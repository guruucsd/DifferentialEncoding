function obj1 = guru_mergeStruct(obj1, obj2)

    fn = fieldnames(obj2);
    
    for fi=1:length(fn)
        if isfield(obj1, fn{fi}) && isstruct(obj1.(fn{fi})) && isstruct(obj2.(fn{fi}))
           obj1.(fn{fi}) = guru_mergeStruct(obj1.(fn{fi}), obj2.(fn{fi}));
        else
            obj1.(fn{fi}) = obj2.(fn{fi});
        end;
    end;
    