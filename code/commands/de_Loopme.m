function allstats = de_Loopme(expt, stimSet, taskType, opt, ...
                              d1, d1args, d2, d2args, ...
                              varargin)
%
%

  tic;

  outfile = fullfile(de_GetBaseDir(), 'runs', guru_callerAt(1));
  
  if (exist(outfile, 'file'))
    load(outfile,'allstats');
    return;
  end;
  

  % Massage inputs  
  if (~exist('d1','var') || isempty(d1)), error('d1?'); end;
  if (~exist('d2','var') || isempty(d2)), error('d2?'); end;
  
  if (~iscell(d1))
    d1 = {d1};
    d1args = {d1args};
  end;
  if (~iscell(d2))
    d2 = {d2};
    d2args = {d2args};
  end;
  
  
  % Figure out the datafile
  dataFile = de_GetDataFile(expt, stimSet, taskType, opt);
  [TLBL LpSpID LpSpNID LpSm LmSp LmSmID LmSmNID] = guru_loadVars( dataFile, 'TLBL', 'LpSpID', 'LpSpNID', 'LpSm', 'LmSp', 'LmSmID', 'LmSmNID' );
  conds = [LpSpID LpSpNID LpSm LmSp LmSmID LmSmNID];

  % Gather the stats
  allstats   = cell(length(d1args{1}), length(d2args{1}));
  %alldata    = zeros(length(conds), 2, length(d1args{1}), length(d2args{1}));

  for d1i=1:length(d1args{1})
    for d2i=1:length(d2args{1})
      loopargs = varargin;
      
      for i=1:length(d1args)
        loopargs{end+1} = d1{i};
        loopargs{end+1} = d1args{i}(d1i);
      end;
      for i=1:length(d2args)
        loopargs{end+1} = d2{i};
        loopargs{end+1} = d2args{i}(d2i);
      end;
      
      % optional args
      if (~guru_contains('plots', loopargs))
        loopargs{end+1} = 'plots';
        loopargs{end+1} = {};
      end;
      if (~guru_contains('stats', loopargs))
        loopargs{end+1} = 'stats';
        loopargs{end+1} = {};
      end;
      if (~guru_contains('out.data', loopargs))
        loopargs{end+1} = 'out.data';
        loopargs{end+1} = {'info'};
      end;

      % Train it up
      %keyboard
      [mSets,mss,allstats{d1i,d2i}] = de_Simulator(expt, stimSet, taskType, opt, loopargs{:});
      clear('mSets','mss');
    end;
  end;
  
  %save this off!
  save(outfile);
  
  % toc,keyboard;
  toc;
