clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

tsteps = 25;
Idel = 1;
Idur = tsteps-Idel;
Sdel = 1; %start measuring output right when it goes off 
Sdur = 1;  %measure for 5 time-steps

net.sets.rseed  = 517;

%training parameters
net.sets.niters          = 2500;
net.sets.online          = false;
net.sets.ncc             = 2;
net.sets.cc_wt_lim       = [-inf inf];
net.sets.W_LIM           = [-5 5];
net.sets.train_criterion = 0.5;
net.sets.dataset         = 'random';
net.sets.init_type       = 'ringo-classifier';
net.sets.train_mode      = 'resilient';

%timing parameters
net.sets.dt              = 0.01;
net.sets.T_INIT          = [0.05 0.05];  %change
net.sets.T_LIM           = net.sets.T_INIT;
net.sets.tsteps          = tsteps+2;   % min 1+3+del to get to contra output; 1+3 to get to ipsi
net.sets.tstart          = 0;
net.sets.tstop           = net.sets.tsteps*net.sets.dt;
net.sets.S_LIM           = net.sets.tstop -net.sets.dt*(Sdel +[1 0]);  % min & max time to consider error

net.sets.D_INIT           = 1*[1 1];%*[1 1; 1 1]; %early lh&rh; late lh&rh
net.sets.D_IH_INIT(1,:,:) = 1*[1 1; 1 1];             %lh;    early->late and late->early
net.sets.D_IH_INIT(2,:,:) = net.sets.D_IH_INIT(1,:,:); %rh;    early->late and late->early
net.sets.D_CC_INIT(1,:,:) = 1*[1 1; 1 1];             %early; l->r and r->l
net.sets.D_CC_INIT(2,:,:) = net.sets.D_CC_INIT(1,:,:); %late;  l->r and r->l

% de-related parameters
net.sets.nhidden_per      = 10;
net.sets.npat             = 10;

net.sets.eta_w           = 1E-1;    %learning rate (initial)
net.sets.eta_w_min       = 0;
net.sets.lambda_w        = 2E-3;    % lambda*E to control kappa. 
net.sets.phi_w           = 0.25;      % multiplicative decrease to eta
net.sets.alpha_w         = 0.15;       %momentum

net.sets.grad_pow        = 3;



%%%%%%%%%%%%%%%%
% Set up the autoencoder
%%%%%%%%%%%%%%%%

net.sets.ac                  = net.sets;
net.sets.ac.train_criterion  = 0.5; 
net.sets.ac.niters           = 1500;
net.sets.ac.init_type        = 'ringo'; % structure
net.sets.ac.nhidden_per      = 10;
net.sets.ac.del              = 10;    
net.sets.ac.ncc              = 2;
net.sets.ac.autoencoder      = true;
net.sets.ac.duplicate_output = false; % :( :( :(
net.sets.ac.noise_init       = 0;%1;
net.sets.ac.noise_input      = 0;%001;%1;
net.sets.ac.force            = false;
net.sets.ac.cc_wt_lim        = [-inf inf];

net.sets.eta_w           = 5E-2;    %learning rate (initial)
net.sets.eta_w_min       = 4E-6;
net.sets.lambda_w        = 5E-3;    % lambda*E to control kappa. 
net.sets.phi_w           = 0.25 * (1/1.5);      % multiplicative decrease to eta
net.sets.alpha_w         = 0.0 * (1/1.5);       %momentum

net.sets.ac.tsteps = tsteps  ;%we'll add another hidden layer, so measure output at one step later
net.sets.ac.tstop  = net.sets.ac.tsteps * net.sets.ac.dt;
net.sets.ac.I_LIM  = net.sets.ac.tstart+net.sets.ac.dt*(Idel +[0 Idur]); %in terms of time, not steps
net.sets.ac.S_LIM  = net.sets.ac.tstop -net.sets.ac.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

net.sets.ac.grad_pow        = 3;


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


