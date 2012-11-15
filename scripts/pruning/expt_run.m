% Compare different levels of pruning on the same sigma and lambda
%
tic;
clear all variables;
close all;
addpath(genpath('../../code'));
de_SetupExptPaths('sergent_1982');

%~/de/code/lib/'));
%addpath(genpath('~/de/code/paths/'));
%addpath(genpath('~/de/code/train/'));
%addpath(genpath('~/de/code/util/'));

%= Sig=6, 15->10 nhidden=850*2 on a 10-10-10-10-10 sched
%= Sig=6, 10->5 nhidden=850*2 on a 10-10-10-10-10 sched
%= Sig=15, 10->5 nhidden=850*2 on a 10-10-10-10-10 sched
%= Sig=15, 15->8 nhidden=850*1 on a 10-10-10-10-10 sched
%= Sig=15, 15->8 nhidden=425*3 on a 10-10-10-10-10 sched
%= Sig=30, 60->5 nhidden=425*3 on a 10-10-10-10-10 sched
%= Sig=30, 60->5 nhidden=425*3 on a 15-10-8-7-5-5 sched
%= Sig=20, 20->10; nhidden=425*3
%= Sig=20, 15->10; nhidden=1700
%= Sig=20, 15->10;  nhidden=1134

%sigma                =    1*[  15  15   2   6   6   6  15  15  15  30  20   20   20]; % Width of gaussian
%nConnPerHidden_Start =    1*[  10  10  20  30  10  15  10  15  15  60  20   15   15]; % # initial random connections to input (& output), per hidden unit
%nConnPerHidden_End   =    1*[   5   5   5  15   5  10   5   8   8   5  10   10   10]; % # post-pruning random connections to input (& output), per hidden unit
%hpl                  =    1*[   2   1   2   2   2   2   1   3   3   3   1    1    1];
%nHidden              = hpl.*[ 850 850 850 850 850 850 850 850 425 425 425 1700 1134];
sigma                =    1*[  10   6   6  15  15  15  30  20  20   2  30  10  10  10]; % Width of gaussian
nConnPerHidden_Start =    1*[  20   6  15  10  15  15  60  20  15  10  10  60  10  20]; % # initial random connections to input (& output), per hidden unit
nConnPerHidden_End   =    1*[  10   3  10   5   8   8   5  10  10   5   5   5   5  10]; % # post-pruning random connections to input (& output), per hidden unit
hpl                  =    1*[   2   1   1   1   2   1   1   1   1   1   1   2   1];
nHidden              = hpl.*[ 408 111 425 425 425 425 425 425 425 425 425 102 102];
dataset_train        =      repmat({'n'}, size(sigma));
lambdas              = 0.00*ones(size(sigma)); % Weight decay const[weights=(1-lambda)*weights]
dnw                  =      true(size(sigma));
zscore               = 0.025*ones(size(sigma));
AvgErr               =    0*ones(size(sigma));
sz                   = repmat({'small'}, size(sigma));
prune_loc            = repmat({'input'}, size(sigma)); %input or output
prune_strategy       = repmat({'activity'},size(sigma)); %weights, weighted_weights, or activity

dataset_test         = dataset_train;

N                    = 4*ones(size(sigma));
iters_per            = repmat( {[10*ones(1,5)]}, size(sigma) );
tag                  = repmat( {'test20'}, size(sigma) );

kernels              = repmat( {repmat([8,1],[length(iters_per{1}) 1])}, size(sigma) );
for ii=1:length(kernels)
    nkernels(ii)     = size(kernels{ii},2);
    for ki=1:nkernels(ii)
      klabs(ii,ki)      = guru_cell2str({kernels{ii}(:,ki)'});
    end;
end;

mSets.debug          = 1:10;
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
	mSets.AvgErr               = AvgErr(si);
	mSets.zscore               = zscore(si);

	ws.dataset_train = struct('name', dataset_train{si}, 'opts', {{sz{si} 'dnw', dnw(si)}});
  ws.N         = N(si);
  ws.iters_per = iters_per{si};
  ws.tag       = tag{si};
  ws.nkernels  = nkernels(si);
  ws.klabs     = klabs(si,:);
  ws.prune_loc = prune_loc{si};
  ws.prune_strategy = prune_strategy{si};

	ws.scriptdir = guru_fileparts(pwd,'name');
	ws.desc      = sprintf('%s.sig%02dc%02dto%02dnH%04dx%d.%s', sz{si}, round(mSets.sigma), mSets.nConnPerHidden_Start, mSets.nConnPerHidden_End, mSets.nHidden/mSets.hpl, mSets.hpl, dataset_train{si});
	ws.matdir    = fullfile('~/_cache/scripts', ws.scriptdir, 'runs', dataset_train{si}, ws.tag, ws.desc);
	ws.pngdir    = fullfile('png', ws.tag, ws.desc); %sprintf('png-%s', ws.desc);
		
	

	%%%%%%%%%%%%%%%%%
	% Run simulations & collect data
	%%%%%%%%%%%%%%%%%
	
	fns = cell(ws.N,ws.nkernels);

	% Train
	fprintf('\n==========\nTraining on kernels [ %s] %d times each; nCs=%2d, nCe=%2d, sig=%3.1f, hpl=%d, lambda=%3.2f\n', ...
			sprintf('%d ', ws.kernels), ws.N, ...
			mSets.nConnPerHidden_Start, mSets.nConnPerHidden_End, mSets.sigma, ...
			mSets.hpl, mSets.lambda);
	for mi=1:ws.nkernels*ws.N %lsf,msf,hsf
		fi = 1+floor((mi-1)/ws.N);
		ni = mi-(fi-1)*ws.N;

		%fprintf('k=%d #%d\n', ws.kernels(fi), ni);
	
		fns{mi}  = fullfile(ws.matdir,sprintf('pruning-de-freq-%s-%d.mat', ws.klabs{fi}, ni));
	
		if (exist(fns{mi},'file'))
			if (ismember(11, mSets.debug)), fprintf('Skipping trained model @ %s\n', fns{mi}); end;
			continue;
		end;

    ws.kernels   = kernels{si}(:,fi)';
		
		curmodel          = mSets;
		curmodel.fi       = fi; %mark these so we can debug later
		curmodel.ni       = ni;
		curmodel.randSeed = ni;
		
		[curmodel,ws,s,fs] = autoencoder(curmodel, ws);      % run the script
		close all;        % close figures
	
		% Move output
		if (~exist(ws.matdir,'dir')), mkdir(ws.matdir); end;
		unix( ['mv "' fs{4} '" "' fns{mi} '"'] );
	
		if (~exist(ws.pngdir,'dir')), mkdir(ws.pngdir); end;
		unix( ['mv "' fs{1} '" "' fullfile(ws.pngdir, sprintf('z_recon-%s-%d.png', ws.klabs{fi}, ni)) '"'] );
		unix( ['mv "' fs{2} '" "' fullfile(ws.pngdir, sprintf('z_conn-%s-%d.png',  ws.klabs{fi}, ni)) '"'] );
		unix( ['mv "' fs{3} '" "' fullfile(ws.pngdir, sprintf('z_hist-%s-%d.png',  ws.klabs{fi}, ni)) '"'] );
	end;
	
	% Collect stats
	s.dist_orig_full = cell(ws.nkernels,ws.N);
	s.dist_end_full  = cell(ws.nkernels,ws.N);
	models           = cell(ws.nkernels,1);
	wss              = cell(ws.nkernels,1);
  s.model          = cell(ws.nkernels,1);

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
      s.model{fi} = [s.model{fi} ld.s.model];
    end;
	end;


	% Save off results
	if (~exist(ws.matdir,'dir')), mkdir(ws.matdir); end;
	save(fullfile(ws.matdir, 'expt_sf'));

  expt_analyze( models, wss, s );
  close all;
    
  toc
  fprintf('\n\n');
end;
