% This successfully run, under the below commit, for 850x1
% git checkout a0713561f421b56368ecbe77e476d75a4b1fc2bb
% and results are saved into
% 850x1.mat
%
clear all variables; clear all globals;
dbstop if error

% I want to test spatial frequency processing with different hu/hpl, sigma, and nconn setups

hu_hpl = [ 108 8; 108 4; 850 1; 425 2; 425 1];
sigmas = [ 2 4; 2 6; 2 8; 2 12; 4 6; 4 8; 4 12; 6 8; 6 12; 8 12];
nconn  = [ 6; 10; 15; 20; 40];

stats = {'ipd','distns','images','ffts'};
plts = {'ls-bars', stats{:}};

for hi=1:length(hu_hpl),
  outfile = sprintf('h%dx%d.mat', hu_hpl(hi,:));

  % Cache results
  if exist(outfile,'file'), continue; end;
  
  % Otherwise, save all results to disk
  trn = cell(length(sigmas)*length(nconn),1);
  tst  = cell(size(trn));

  % key stats
  interact = cell(size(trn));%zeros(size(trn));
  rejs     = cell(size(trn));%zeros([size(trn),2]);
  bars     = cell(size(trn));%zeros([size(trn),2,2]);
  ipd_fc   = cell(size(trn));%zeros(size(rejs));
  ipd_nn   = cell(size(trn));%zeros(size(rejs));

  parfor sci=1:length(sigmas)*length(nconn)
    si = 1+floor((sci-1)/length(nconn));
    ci = sci-(si-1)*length(nconn);
    %fprintf('%d %d %d\n', hi, si, ci); continue;
    
    nparams = prod(hu_hpl(hi, :)) * nconn(ci);

    [args,opts]  = uber_sergent_args('nHidden', prod(hu_hpl(hi, :)), 'hpl', hu_hpl(hi,2), ...
                                     'sigma', sigmas(si, :), 'nConns', nconn(ci), ...
                                     'ac.EtaInit', 5E-2 * (425*2*12/nparams), ...
                                     'plots',plts,'stats',stats,'runs',25);

    % Make sure that this is trainable.
    try
        [trn2, tst2] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, {args{:}, 'runs', 2, 'plots',{},'stats',{}});
        rej = [nnz(sum(tst2.stats.raw.r{1},2)) nnz(sum(tst2.stats.raw.r{end},2))];
    catch
        rej = [2 2];
    end
    
    
    % If not, skip; leave the data empty
    if any(rej==2)
      error(NaN, 'parameter combination fails: hu_hpl=[%d %d], sigma=[%f %f], nconn=%d', hu_hpl(hi,:), sigmas(si,:), nconn(ci));
      interact{hi,sci} = NaN;
      rejs{hi,sci} = NaN(1,2);
      bars{hi,sci} = NaN(2,2);
      ipd_fc{hi,sci} = NaN(1,2);
      ipd_nn{hi,sci} = NaN(1,2);

    % If so, train all!
    else
        trn25 = struct('mSets', trn2.mSets); trn25.mSets.runs = 25;
        tst25 = struct('mSets', tst2.mSets); tst25.mSets.runs = 25;
        if (exist(de_GetOutFile(trn25.mSets, 'stats'),'file')), trn25.stats = getfield(load(de_GetOutFile(trn25.mSets, 'stats')),'stats'); end;
        if (exist(de_GetOutFile(tst25.mSets, 'stats'),'file')), tst25.stats = getfield(load(de_GetOutFile(tst25.mSets, 'stats')),'stats'); end;

        if isfield(trn25,'stats') && isfield(tst25,'stats')
            fprintf('Hey!  Using cached results! :D\n');
        else
            [trn25,tst25] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, args);
            close all;
        end;
       
        % Blank out some 'expensive' fields
        trn25.models = [];              tst25.models = [];
        trn25.stats.rej.ac.images = []; tst25.stats.rej.ac.images = [];
        trn25.stats.rej.ac.ffts   = []; tst25.stats.rej.ac.ffts   = [];

        % Save off the results
        trn{hi,sci}  = trn25;
        tst{hi,sci}  = tst25;

        interact{hi,sci} = tst25.stats.rej.basics.anova.stats{4,end};
        rejs{hi,sci}     = [nnz(sum(tst25.stats.raw.r{1},2)) nnz(sum(tst25.stats.raw.r{end},2))];    
        bars{hi,sci}     = [tst25.stats.rej.basics.ls_mean{1}(3:4) tst25.stats.rej.basics.ls_mean{end}(3:4)];
        ipd_fc{hi,sci}   = tst25.stats.rej.ac.ipd.from_center_mean;
        ipd_nn{hi,sci}   = tst25.stats.rej.ac.ipd.nearest_neighbor_mean;
        
    end;
    trn2 = []; tst2 = []; %parfor 'clear'
    trn25 = []; tst25 = []; %parfor 'clear'
  end;

  % Turn into data
  interact = reshape(cell2mat(interact), [length(sigmas) length(nconn)]);
  rej      = reshape(cell2mat(rej),      [size(interact) 2]);
  bars     = reshape(cell2mat(bars),     [size(interact) 2 2]);
  ipd_fc   = reshape(cell2mat(ipd_fc),   size(bars));
  ipd_nn   = reshape(cell2mat(ipd_nn),   size(bars));
  
  save(outfile);
end;

save('all.mat');
