function [pat,frequency,orientation,imgheight,imgwidth] = readpat(filename,restore)
% READPAT reads gabor filter responses from a pat file
%[pat frequency orientation imgheight imgwidth]=readpat(filename,restore)
%
%   filename: the pat file name
%   restore: return the pat as a vector if restore=0 (default), 
%   restore=1: as a 3D matrix of imgheight,imgwidth,frequency*orientation         
%   restore=2: as a 4D matrix of imgheight,imgwidth,orientation,frequency
%
%   pat: the responses
%   frequency: number of gabor filter frequencies
%   orientation: number of gabor filter orientations
%   imgheight, imgwidth: the size of original images

p=load(filename);
pat=p(5:end);
frequency=p(1);
orientation=p(2);
imgheight=p(3);
imgwidth=p(4);
if nargin>=2
    if restore==1
        pat=reshape(pat,imgheight,imgwidth,frequency*orientation);
    elseif restore==2
        pat=reshape(pat,imgheight,imgwidth,orientation,frequency);
    end
end
