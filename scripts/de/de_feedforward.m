clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

%%%%%%

net.sets.rseed  = 517

tsteps = 13;
Idel = 1;
Idur = tsteps-Idel;
Sdel = 0; %start measuring output right when it goes off 
Sdur = 3;  %measure for 5 time-steps

% de-related parameters
net.sets.nhidden_per     = 5;


%training parameters
net.sets.niters          = 2500;
net.sets.online          = false;
net.sets.ncc             = 0;
net.sets.train_criterion = 0.5; 
net.sets.tsteps          = tsteps+2;   % min 1+3+del to get to contra output; 1+3 to get to ipsi
net.sets.dataset         = 'de_1D';
net.sets.init_type       = 'de_feedforward_classifier';
net.sets.train_mode      = 'resilient';
net.sets.T_INIT          = [0.025 0.025];  %change     
net.sets.T_LIM           = net.sets.T_INIT;
net.sets.pres_loc        = {'LVF' 'RVF'};
net.sets.duplicate_output= true;
net.sets.combine_outputs = false;

%timing parameters
net.sets.dt     = 0.01;
net.sets.tstart = 0;
net.sets.tstop  = net.sets.tsteps*net.sets.dt;
net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[1 0]);  % min & max time to consider error

net.sets.eta_w           = 5E-1;    %learning rate (initial)
net.sets.eta_w_min       = 0;
net.sets.lambda_w        = 1E-2;    % lambda*E to control kappa. 
net.sets.phi_w           = 0.25;      % multiplicative decrease to eta
net.sets.alpha_w         = 0.10;       %momentum

net.sets.grad_pow        = 3;


%%%%%%%%%%%%%%%%
% Set up the autoencoder
%%%%%%%%%%%%%%%%

net.sets.ac                  = net.sets;
net.sets.ac.niters          = 1500;
net.sets.ac.init_type        = 'de_feedforward'; % structure
net.sets.ac.nconn            = 7;      % de-specific
net.sets.ac.sigs             = [6 3];  % de-specific
net.sets.ac.nhidden_per      = 100;
net.sets.ac.del              = 1;    
net.sets.ac.ncc              = 50;
net.sets.ac.autoencoder      = true;
net.sets.ac.duplicate_output = false;
net.sets.ac.combine_outputs  = true;
net.sets.ac.noise_init       = 0.001;%1;
net.sets.ac.noise_input      = 0;%001;%1;
net.sets.ac.pres_loc         = {'LVF' 'CVF' 'RVF'};
net.sets.ac.force            = false;
net.sets.ac.cc_wt_lim        = [-inf inf];
net.sets.cc_wt_lim           = [-inf inf];

net.sets.ac.train_criterion = net.sets.train_criterion;
net.sets.ac.eta_w           = 5E-2;
net.sets.ac.lambda_w        = 5E-3;
net.sets.ac.phi_w           = 0.5;

net.sets.ac.tsteps = tsteps  ;%we'll add another hidden layer, so measure output at one step later
net.sets.ac.tstop  = net.sets.ac.tsteps * net.sets.ac.dt;
net.sets.ac.I_LIM  = net.sets.ac.tstart+net.sets.ac.dt*(Idel +[0 Idur]); %in terms of time, not steps
net.sets.ac.S_LIM  = net.sets.ac.tstop -net.sets.ac.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

% Initialize the full model, but don't train
%net.sets.niters          = 0;
%[net] = r_main(net);

% Train without CC cxns
%net_nocc                           = net;
%net_nocc.cC(net.idx.cc,net.idx.cc) = false;
%net_nocc.wC                        = net_nocc.cC;
%net_nocc.w                         = net_nocc.w.*net_nocc.cC;
%net_nocc.sets.niters               = 0;
%[net_nocc, pats_nocc, data_nocc]   = r_main(net_nocc);
%[data.an]                          = r_analyze(net_nocc, pats_nocc, data_nocc);

% Now continue training with CC
%net.w(find(net_nocc.w)) = net_nocc.w(find(net_nocc.w));
%net.sets.niters          = 500;
[net,pats,data]          = r_main(net);
[data.an]                = r_analyze(net, pats, data);
