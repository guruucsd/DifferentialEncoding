function [buf,sz] = mfe_readIML(fn)
%
% Actually taken from http://www.kyb.tuebingen.mpg.de/bethge/vanhateren/iml/readIML.m ;
%   used to read IML files from the van Hateren database
%

    f1=fopen(fn,'rb','ieee-be');
    w=1536;h=1024;sz=[h,w];
    buf=fread(f1,[w h],'uint16')'; % image is stored on its side
    fclose(f1);