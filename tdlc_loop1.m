clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

tsteps = 35;
Idel = 1;
Idur = tsteps-Idel;
Sdel = 1; %start measuring output right when it goes off 
Sdur = 1;  %measure for 5 time-steps

%training parameters
net.sets.niters          = 1000;
net.sets.online          = false;
net.sets.ncc             = 2;
net.sets.cc_wt_lim       = [-inf inf];
net.sets.W_LIM           = [-inf inf];
net.sets.train_criterion = 0.5; 
net.sets.dataset         = 'random';
net.sets.init_type       = 'ringo';
net.sets.train_mode      = 'resilient';

%timing parameters
net.sets.dt     = 0.01;
net.sets.T_INIT = [0.10 0.10];  %change     
net.sets.T_LIM  = net.sets.T_INIT;
net.sets.tstart = 0;
net.sets.tsteps = tsteps  ;%we'll add another hidden layer, so measure output at one step later
net.sets.tstop  = net.sets.tsteps * net.sets.dt;
net.sets.I_LIM  = net.sets.tstart+net.sets.dt*(Idel +[0 Idur]); %in terms of time, not steps
net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

net.sets.D_INIT           = 1*[1 1];%*[1 1; 1 1]; %early lh&rh; late lh&rh
net.sets.D_IH_INIT(1,:,:) = 1*[1 1; 1 1]; %lh;    early->late and late->early
net.sets.D_IH_INIT(2,:,:) = 1*[1 1; 1 1]; %rh;    early->late and late->early
net.sets.D_CC_INIT(1,:,:) = 1*[1 1; 1 1]; %early; l->r and r->l
net.sets.D_CC_INIT(2,:,:) = 1*[1 1; 1 1]; %late;  l->r and r->l

net.sets.eta_w           = 9E-2;    %learning rate (initial)
net.sets.eta_w_min       = 0;
net.sets.lambda_w        = 1E-2;    % lambda*E to control kappa. 
net.sets.phi_w           = 0.15;      % multiplicative decrease to eta
net.sets.alpha_w         = 0.5;       %momentum

net.sets.grad_pow        = 3;

net.sets.nhidden_per      = 15;
%net.sets.autoencoder      = false;
%net.sets.duplicate_output = false; % :( :( :(
%net.sets.noise_init       = 0;%1;
%net.sets.noise_input      = 0;%001;%1;

% Looping variables
nmodels = 10;

dummy_mat = net.sets.D_IH_INIT;

var1.name = 'D_CC_INIT';
var1.vals = { 1*dummy_mat 5*dummy_mat 10*dummy_mat 20*dummy_mat 30*dummy_mat};

var2.name = 'D_IH_INIT';
var2.vals = { 1*dummy_mat 5*dummy_mat 10*dummy_mat 20*dummy_mat 30*dummy_mat};

if (~exist('mat','dir')), mkdir('mat'); end;

for mi=nmodels:-1:1
    net.sets.rseed = mi;

    for vi1 = 1:length(var1.vals)
        net.sets.(var1.name) = var1.vals{vi1};

        for vi2 = 1:length(var2.vals)
            net.sets.(var2.name) = var2.vals{vi2};

            % Massage secondary variables
%            switch (var1.name)
%            end;

            % Set the defaults here, getting a new filename, 
            %   so that we can tweak the filename and check
            %   to see if it exists.
            net.sets = guru_rmfield(net.sets,'matfile');
            net      = r_massage_params(net);
            net.sets.matfile = fullfile('mat', net.sets.matfile);

            % Only run this simulation if necessary
            if (exist(net.sets.matfile,'file')), 
                fprintf('Found %s; moving on...\n', net.sets.matfile);

            % Run simulation
            else
                fprintf('Making %s...\n', net.sets.matfile);

                %
                [net12,pats12,data12]          = r_main(net);
                [data12.an]                = r_analyze(net12, pats12, data12);
            end;
        end;
    end;
end;
