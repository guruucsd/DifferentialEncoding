function de_LogSettingsMap(mSets)
%
%  Logs the map of settings=>hash value to a file.
%
% Input params:
%   mSets: model settings to print and map to a hash

    % Get the string and hash
    str  = de_modelSummary(mSets, 'pre-hash');
    hash = de_modelSummary(mSets, 'hash');

    % Massage and log to text file
    str = [ hash sprintf(':\n') str ];

    % Make the output path
    fn = de_GetOutFile(mSets, 'settings-map');
    if (~exist(guru_fileparts(fn, 'pathstr')))
      guru_mkdir(guru_fileparts(fn, 'pathstr'));
    end;

    % Read through all lines; don't write if it's there
    fid = fopen(fn, 'a+');
    while (~feof(fid))
      [x,count] = fscanf(fid, '%d:\n');
      if (strcmp(hash, sprintf('%d', x)))
        return;
      elseif (count==0)
        if (isempty(fscanf(fid, '%s\n')))
          break;
        end;
      end;
    end;

    % It's not there, write it.
    fprintf(fid, str);
    fclose(fid);

