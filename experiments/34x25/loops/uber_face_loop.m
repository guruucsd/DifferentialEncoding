% This successfully run, under the below commit, for 850x1

% git checkout a0713561f421b56368ecbe77e476d75a4b1fc2bb
% and results are saved into
% 850x1.mat
%
addpath('../young_bion_1981');
% I want to test spatial frequency processing with different hu/hpl, sigma, and nconn setups

hu_hpl = [ 850 1; 108 8; 425 2; 108 6];
sigmas = [ 2; 4; 6; 8; 12 ];
nconn  = [ 6; 10; 15; 20; 40];

for hi=1:length(hu_hpl),

  % Look for cached results on disk
  outfile = fullfile('mat',sprintf('face-uber-h%dx%d.mat', hu_hpl(hi,:)));
  if exist(outfile,'file'), continue; end;

  % Build a local cache
  trn = cell(size(nconn)); tst = cell(size(nconn));
  for ci=1:length(nconn)
    nparams = prod(hu_hpl(hi, :)) * nconn(ci);
    %if (nparams < 108*4*12),
    %    fprintf('we know we can''t train with this low param value: h=%dx%d,c=%d; skipping!\n', hu_hpl(hi,:),nconn(ci));
    %    continue;
    %end;
    [args,opts]  = uber_face_args('runs',25, ...
                                     'nHidden', prod(hu_hpl(hi, :)), 'hpl', hu_hpl(hi,2), ...
                                     'sigma', sigmas, 'nConns', nconn(ci), ...
                                     'ac.EtaInit', 4E-2 * (425*2*12/nparams), ...
                                     'ac.Acc', 2E-5, ...
                                     'plots',{},'stats', {'ipd','distns','ffts'});

    % Get the result
    [trn{ci},tst{ci}] = de_SimulatorUber('vanhateren/250', 'young_bion_1981/orig/recog', opts, args);

    % Clean up
    close all;
    trn{ci}.models = [];              tst{ci}.models = [];
    %trn{ci}.stats.rej.ac.images = []; tst{ci}.stats.rej.ac.images = [];
    %trn{ci}.stats.rej.ac.ffts   = []; tst{ci}.stats.rej.ac.ffts   = [];
  end;

  save(outfile,'trn','tst');
end;
