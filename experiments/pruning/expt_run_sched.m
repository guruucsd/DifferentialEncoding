
% Compare different levels of pruning on the same sigma and lambda
%
tic;
clear all variables;
close all;
addpath(genpath('../../code'));
de_SetupExptPaths('sergent_1982');

sigma                =    1*[  10];%   6   6  15  15  15  30  20  20   2  30  10  10  10]; % Width of gaussian
nConnPerHidden_Start =    1*[  30];%   6  15  10  15  15  60  20  15  10  10  60  10  20]; % # initial random connections to input (& output), per hidden unit
nConnPerHidden_End   =    1*[  15];%   3  10   5   8   8   5  10  10   5   5   5   5  10]; % # post-pruning random connections to input (& output), per hidden unit
hpl                  =    1*[   1];%   1   1   1   2   1   1   1   1   1   1   2   1];
nHidden              = hpl.*[ 850];% 111 425 425 425 425 425 425 425 425 425 102 102];
dataset_train        =      repmat({'n'}, size(sigma));
lambdas              = 0.05*ones(size(sigma)); % Weight decay const[weights=(1-lambda)*weights]
dnw                  =   false(size(sigma));
zscore               = 0.05*ones(size(sigma));
AvgError             = 1E-4*ones(size(sigma));
sz                   = repmat({'small'}, size(sigma));
prune_loc            = repmat({'input'}, size(sigma)); %input or output
prune_strategy       = repmat({'weights'},size(sigma)); %weights, weighted_weights, or activity

N                    = 40*ones(size(sigma));
tag                  = repmat( {'natimg-sched-img2pol'}, size(sigma) );

iters_per            = repmat( {[7*ones(1,6) 50]; [ 7*ones(1,6) 50]}, size(sigma) );
%iters_per            = repmat( {[10*ones(1,4) 25]; [ 5 5 5 5 25]}, size(sigma) );
%iters_per            = repmat( {[20 1]; [20 1]}, size(sigma) );
%iters_per            = repmat( {[4*ones(1,10) 1]; [4*ones(1,10) 1]}, size(sigma) );
%iters_per            = repmat( {[4*ones(1,10) 50]; [1*ones(1,5) 7*ones(1,5) 50]}, size(sigma) );
%kernels              = repmat( {[linspace(1.5,20,10) 0]; [linspace(1.5,20,5) zeros(1,5) 0]}, size(sigma) );
%kernels              = repmat( {[linspace(1.5,20,10) 0]; [linspace(-20,-1.5,10) 0]}, size(sigma) );
%kernels              = repmat( {[linspace(1.5,10,10) 0]; [zeros(1,10) 0]}, size(sigma) );
%kernels              = repmat( {[1.5 0]; [0 0]}, size(sigma) );
%kernels              = repmat( {[1.5 3 6 12 0];[0 0 0 0 0]}, size(sigma) );
kernels              = repmat( {[3 5 6.5 11 16 NaN NaN]; [6.5 11 16 NaN NaN NaN NaN]}, size(sigma) );

klabs                = cell(size(kernels));
plot_formats         = {'png', 'fig'};


for ii=1:size(kernels,2)
    nkernels(ii)     = size(kernels,1);
    for ki=1:nkernels(ii)
      klabs{ki,ii}   = [guru_cell2str(kernels(ki,ii)) ' - ' guru_cell2str(iters_per(ki,ii))];
    end;
end;

mSets.debug          = 1:11;
mSets.lrrev          = false;
%mSets.linout         = true;

% Allow multiple loops, for simplicity's sake (hi, nohup! :D)

for si=1:length(lambdas)

    mSets.sigma                = sigma(si);
    mSets.nConnPerHidden_Start = nConnPerHidden_Start(si);
    mSets.nConnPerHidden_End   = nConnPerHidden_End(si);
    mSets.lambda               = lambdas(si);
    mSets.hpl                  = hpl(si);
    mSets.nHidden              = nHidden(si);
    mSets.AvgError             = AvgError(si);
    mSets.zscore               = zscore(si);

    ws.dataset_train = struct('name', dataset_train{si}, 'opts', {{sz{si} 'dnw', dnw(si), 'img2pol'}});
    ws.N         = N(si);
    ws.iters_per = iters_per(:,si);
    ws.tag       = tag{si};
    ws.nkernels  = nkernels(si);
    ws.klabs     = klabs(:,si);
    ws.prune_loc = prune_loc{si};
    ws.prune_strategy = prune_strategy{si};

    ws.scriptdir   = guru_fileparts(pwd,'name');
    ws.desc        = sprintf('%s.sig%02dc%02dto%02dnH%04dx%d.%s', sz{si}, round(mSets.sigma), mSets.nConnPerHidden_Start, mSets.nConnPerHidden_End, mSets.nHidden/mSets.hpl, mSets.hpl, dataset_train{si});
    [~,ws.homedir] = unix('echo $HOME'); ws.homedir = strtrim(ws.homedir);
    ws.matdir      = fullfile(ws.homedir, '_cache/scripts', ws.scriptdir, 'runs', dataset_train{si}, ws.tag, ws.desc);
    ws.plotdir     = fullfile('plots', ws.tag, ws.desc); %sprintf('plots-%s', ws.desc);

    ws

    %%%%%%%%%%%%%%%%%
    % Run simulations & collect data
    %%%%%%%%%%%%%%%%%

    fns = cell(ws.N,ws.nkernels);
    wss = cell(ws.N, ws.nkernels);
    fi=0; ni=0;
    % Train
    fprintf('\n==========\nTraining on kernels [ %s] %d times each; nCs=%2d, nCe=%2d, sig=%3.1f, nH=%d, hpl=%d, lambda=%3.2f\n', ...
        [ws.klabs{:}], ws.N, ...
        mSets.nConnPerHidden_Start, mSets.nConnPerHidden_End, mSets.sigma, ...
        mSets.nHidden/mSets.hpl, mSets.hpl, mSets.lambda ...
    );

    for mi=1:ws.nkernels*ws.N %lsf,msf,hsf
        fi = 1+floor((mi-1)/ws.N);
        ni = mi-(fi-1)*ws.N;
        wss{mi} = ws;

        fns{mi}  = fullfile(wss{mi}.matdir,sprintf('pruning-de-freq-%s-%d.mat', wss{mi}.klabs{fi}, ni));
        if (exist(fns{mi},'file'))
            if (ismember(11, mSets.debug)), fprintf('Skipping trained model @ %s\n', fns{mi}); end;
            continue;
        end;

        wss{mi}.kernels   = kernels{fi,si};
        wss{mi}.iters_per = iters_per{fi,si};
        curmodel          = mSets;
        curmodel.fi       = fi; %mark these so we can debug later
        curmodel.ni       = ni;
        curmodel.randSeed = ni;

        [curmodel,wss{mi},s,fs] = autoencoder(curmodel, wss{mi}, plot_formats);      % run the script
        close all;        % close figures

        % Move output
        if (~exist(wss{mi}.matdir,'dir')), guru_mkdir(wss{mi}.matdir); end;
        unix( ['mv "' fs{end} '" "' fns{mi} '"'] );

        if (~exist(wss{mi}.plotdir,'dir')), guru_mkdir(wss{mi}.plotdir); end;
        for pfi=1:length(plot_formats)
            fmt = plot_formats{pfi};

            unix( ['mv "' fs{3 * (pfi - 1) + 1} '" "' fullfile(wss{mi}.plotdir, sprintf('z_recon-%s-%d.%s', wss{mi}.klabs{fi}, ni, fmt)) '"'] );
            unix( ['mv "' fs{3 * (pfi - 1) + 2} '" "' fullfile(wss{mi}.plotdir, sprintf('z_conn-%s-%d.%s',  wss{mi}.klabs{fi}, ni, fmt)) '"'] );
            unix( ['mv "' fs{3 * (pfi - 1) + 3} '" "' fullfile(wss{mi}.plotdir, sprintf('z_hist-%s-%d.%s',  wss{mi}.klabs{fi}, ni, fmt)) '"'] );
        end;
    end;

    % Collect stats
    s.dist_orig_full = cell(ws.nkernels,ws.N);
    s.dist_end_full  = cell(ws.nkernels,ws.N);
    models           = cell(ws.nkernels,1);
    wss              = cell(ws.nkernels,1);
   %$s.model          = cell(ws.nkernels,1);

    for fi=1:ws.nkernels
        for ni=1:ws.N
            ld = load(fns{ni,fi}, 'model', 's', 'ws');

            model                   = ld.model;
            s.dist_orig_full{fi,ni} = vertcat(ld.s.dist_orig{:});
            s.dist_end_full {fi,ni} = vertcat(ld.s.dist_end{:});

            model.debug = mSets.debug;

            % Hacky fix-up on load
            if (~isfield(model, 'lrrev')),      model.lrrev = false; end;
            if (~isfield(model, 'randSeed')),   model.randSeed = ni; end;
            if (isfield(model, 'reductRate')),  model = rmfield(model, 'reductRate'); end;

            % Massage model
            model.ac.Weights   = model.Weights;  model = rmfield(model, 'Weights');
            model.ac.Conn      = model.Conn;     model = rmfield(model, 'Conn');
            model.ac.errorType = model.errorType;
            model.ac.XferFn    = model.XferFn;
            %fprintf('Loaded results from %s\n', fns{ni,fi});

            models        {fi}    = [models{fi} model];
            wss{fi} = [wss{fi} ld.ws];
            %s.model{fi} = [s.model{fi} ld.s.model];
        end;
    end;

    % Save off results
    if (~exist(ws.matdir,'dir')), guru_mkdir(ws.matdir); end;
    save(fullfile(ws.matdir, mfilename));

    expt_analyze( models, wss, s, plot_formats );
    close all;

    toc
    fprintf('\n\n');
end;  % looping over lambdas
