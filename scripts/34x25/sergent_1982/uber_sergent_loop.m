clear all variables; clear all globals;
dbstop if error

% I want to test spatial frequency processing with different hu/hpl, sigma, and nconn setups

hu_hpl = [850 1; 425 2; 108 8; 425 1; 108 4];
sigma  = [ 2 4; 4 8; 4 12; 6 8; 6 12];
nconn  = [ 8; 10; 15; 20; 40];

stats = {'ipd','distns','images','ffts'};
plts = {'ls-bars', stats{:}};

trn = cell(length(hu_hpl),length(sigma),length(nconn));
tst  = cell(size(trn));

% key stats
interact = zeros(size(trn));
rejs     = zeros([size(trn),2]);
bars     = zeros([size(trn),2,2]);
ipd_fc   = zeros(size(rejs));
ipd_nn   = zeros(size(rejs));

for hi=1:length(hu_hpl), for si=1:length(sigma), for ci=1:length(nconn)
    nparams = prod(hu_hpl(hi, :)) * nconn(ci);

    [args,opts]  = uber_sergent_args('nHidden', prod(hu_hpl(hi, :)), 'hpl', hu_hpl(hi,2), ...
                                     'sigma', sigma(si, :), 'nConns', nconn(ci), ...
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
      warning('parameter combination fails: hu_hpl=[%d %d], sigma=[%f %f], nconn=%d', hu_hpl(hi,:), sigma(si,:), nconn(ci));
      keyboard     
      interact(hi,si,ci) = NaN;
      rejs(hi,si,ci,:) = NaN;
      bars(hi,si,ci,:,:) = NaN;
      ipd_fc(hi,si,ci,:) = NaN;
      ipd_nn(hi,si,ci,:) = NaN;

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
        end;
       
        % Blank out some 'expensive' fields
        trn25.models = [];              tst25.models = [];
        trn25.stats.rej.ac.images = []; tst25.stats.rej.ac.images = [];
        trn25.stats.rej.ac.ffts   = []; tst25.stats.rej.ac.ffts   = [];

        % Save off the results
        trn{hi,si,ci}  = trn25;
        tst{hi,si,ci}  = tst25;

        interact(hi,si,ci) = tst25.stats.rej.basics.anova.stats{4,end};
        rejs(hi,si,ci,:)   = [nnz(sum(tst25.stats.raw.r{1},2)) nnz(sum(tst25.stats.raw.r{end},2))];    
        bars(hi,si,ci,:,:) = [tst25.stats.rej.basics.ls_mean{1}(3:4) tst25.stats.rej.basics.ls_mean{end}(3:4)];
        ipd_fc(hi,si,ci,:) = tst25.stats.rej.ac.ipd.from_center_mean;
        ipd_nn(hi,si,ci,:) = tst25.stats.rej.ac.ipd.nearest_neighbor_mean;
    end;


end; end; end;

save
