% This successfully run, under the below commit, for 850x1
% git checkout a0713561f421b56368ecbe77e476d75a4b1fc2bb
% and results are saved into
% 850x1.mat
%
clear all variables; clear all globals;
dbstop if error

% I want to test spatial frequency processing with different hu/hpl, sigma, and nconn setups

hu_hpl = [ 108 8; 108 4; 850 1; 425 2; 425 1];
sigmas = [ 2; 4; 6; 8; 12 ];
nconn  = [ 6; 10; 15; 20; 40];
cfact  = [ 1.5 2 5];

for hi=1:length(hu_hpl)

  % Look for cached results on disk
  outfile = sprintf('h%dx%d.mat', hu_hpl(hi,:));
  if exist(outfile,'file'), continue; end;

  % Build a local cache
<<<<<<< HEAD
  trn = cell(length(sigmas),length(nconn),length(cfact)); tst = cell(size(trn));
  for si=1:length(sigmas), for ci=1:length(nconn), for fi=1:length(cfact)
=======
  trn = cell(length(nconn),length(cfact)); tst = cell(length(nconn), length(cfact));
  for ci=1:length(nconn), for fi=1:length(cfact)
>>>>>>> 9e4a6f18e9f0ace5aa4146d13efc1cf63aabc183

    % Set up params
    nparams = prod(hu_hpl(hi, :)) * nconn(ci);
    [args,opts]  = uber_sergent_args('runs',25, ...
                                     'nHidden', prod(hu_hpl(hi, :)), 'hpl', hu_hpl(hi,2), ...
<<<<<<< HEAD
                                     'sigma', sigmas(si), 'nConns', nconn(ci), ...
=======
                                     'sigma', sigmas, 'nConns', nconn(ci), ...
>>>>>>> 9e4a6f18e9f0ace5aa4146d13efc1cf63aabc183
                                     'ac.EtaInit', 5E-2 * (425*2*12/nparams), ...
                                     'plots',{},'stats', {'ipd','distns','ffts'});
    args         = pruning_args( args{:}, 'ac.ct.nConnPerHidden_Start', ceil(nconn(ci)*cfact(fi)) );


    % Get the result
<<<<<<< HEAD
    [trn{si,ci,fi},tst{si,ci,fi}] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, args);
=======
    [trn{ci,fi},tst{ci,fi}] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, args);
>>>>>>> 9e4a6f18e9f0ace5aa4146d13efc1cf63aabc183


    % Clean up
    close all;
    trn{ci,fi}.models = [];              tst{ci,fi}.models = [];
    %trn{ci}.stats.rej.ac.images = []; tst{ci}.stats.rej.ac.images = [];
    %trn{ci}.stats.rej.ac.ffts   = []; tst{ci}.stats.rej.ac.ffts   = [];
<<<<<<< HEAD
  end; end; end;
=======
  end; end;
>>>>>>> 9e4a6f18e9f0ace5aa4146d13efc1cf63aabc183

  save(outfile,'trn','tst');
  keyboard
end;
