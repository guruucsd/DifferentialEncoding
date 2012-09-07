function [outFile] = de_getDataFile(dim, stimSet, taskType, opt, stem, fileType, outdir)
%
%
%

  if (~exist('stem',   'var') || (isempty(stem) && ~ischar(stem))),         stem     = sprintf('data%dD', dim); end;
  if (~exist('fileType','var')|| (isempty(fileType) && ~ischar(fileType))), fileType = 'mat'; end;
  if (~exist('outdir','var')  || (isempty(outdir) && ~ischar(outdir))),     outdir   = sprintf('%dD.%s', dim, stimSet); end;
  
  switch (fileType)
    case 'mat'
      outStem = sprintf('%s.%s', stem, stimSet);
      if (~isempty(opt))
        for i=1:length(opt), outStem = [outStem '.' opt{i}]; end;
      end;
      if (~strcmp('sergent',taskType)), outStem = [outStem '.' taskType]; end;
      outFile = [outStem '.mat'];  

    case 'dir'
      outFile = sprintf('%s-%s', stem, stimSet);

    otherwise
      error('Unknown file type: %s', fileType);
  end;
  
  outFile = fullfile(outdir, outFile);