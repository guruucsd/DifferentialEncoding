function [bins,a,b] = de_SmartHistc(data)

    bins = de_SmartBins(data);
    
    [a,b] = histc(data,bins);
    bins = bins(2:end-1);
    a = a(2:end-1); 
    b=b-1;
    