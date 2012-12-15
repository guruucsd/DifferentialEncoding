function [gaborfilters, gfParams] = gfCreateFilterBank(frequency, orientation, filtersize, ftype)

gfParams = cell(frequency,orientation);

for k=1:frequency
    f=(2*pi/min(filtersize))*(2^k);
    for o=0:orientation-1
        gfParams{k,o+1}=[f,o*pi/orientation];
        gaborfilters{k,o+1}=gfCreateFilter( gfParams{k,o+1}(1), ...
                                            gfParams{k,o+1}(2), ...
                                            filtersize, ...
                                            ftype );
    end
end
