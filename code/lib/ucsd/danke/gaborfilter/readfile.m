function text = readfile(filename, skipblank)
% This function reads in a text file and return its lines as cells text{k}
% Empty lines are skipped (DEFAULT), otherwise specify skipblank = 0.

if nargin < 2
    skipblank = 1;
end

fid=fopen(filename);
if fid == -1
    disp(['Error: file cannot open: ' filename]);
    return;
end

lineid = 0;
while (1)
    % read line
    tline = fgetl(fid);
    if skipblank & ~ischar(tline), break, end
    lineid = lineid + 1;
    text{lineid} = tline;
end
fclose(fid);