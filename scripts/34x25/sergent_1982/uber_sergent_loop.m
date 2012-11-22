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

for hi=1:length(hu_hpl),

  % Look for cached results on disk
  outfile = sprintf('h%dx%d.mat', hu_hpl(hi,:));
  if exist(outfile,'file'), continue; end;

  % Build a local cache
  trn = cell(size(nconn)); tst = cell(size(nconn));
  for ci=1:length(nconn)
    nparams = prod(hu_hpl(hi, :)) * nconn(ci);

    [args,opts]  = uber_sergent_args('runs',25, ...
                                     'nHidden', prod(hu_hpl(hi, :)), 'hpl', hu_hpl(hi,2), ...
                                     'sigma', sigmas, 'nConns', nconn(ci), ...
                                     'ac.EtaInit', 5E-2 * (425*2*12/nparams), ...
                                     'plots',{},'stats', {'ipd','distns','ffts'});

    % Get the result
    [trn{ci},tst{ci}] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, args);

    % Clean up
    close all;
    trn{ci}.models = [];              tst{ci}.models = [];
    %trn{ci}.stats.rej.ac.images = []; tst{ci}.stats.rej.ac.images = [];
    %trn{ci}.stats.rej.ac.ffts   = []; tst{ci}.stats.rej.ac.ffts   = [];
  end;

  save(outfile,'trn','tst');
  keyboard
end;
