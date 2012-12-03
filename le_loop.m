clear globals variables;
addpath(genpath('code'));
dbstop if error;
dbstop if warning;

%%%%%%

%net.sets.rseed  = 61     %434,603 worked, smooth as butter ... 1 timestep delay :/ 
                     %285 finished in 459 with 3 interhemispheric connections!!
                     % 

Idel = 1;
Idur = 5;
Sdel = 0;
Sdur = 1;

%training parameters
net.sets.train_criterion = 0.75; 
net.sets.del             = 1;

net.sets.tsteps          = 20;%Idel + Idur;%+net.sets.del;   % min 1+3+del to get to contra output; 1+3 to get to ipsi
net.sets.dt              = 0.01;
net.sets.tstart          = 0;
net.sets.tstop           = net.sets.tsteps*net.sets.dt;

net.sets.init_type       = 'ringo-classifier';
net.sets.dataset         = 'lewis-elman';
net.sets.nhidden_per     = 15;
net.sets.ncc             = 3;
net.sets.T_INIT          = [0.05 0.05];  %change     
net.sets.T_LIM           = net.sets.T_INIT;


net.sets.eta_w           = (5E-2);    %learning rate (initial)
net.sets.eta_w_min       = 4E-6;
net.sets.lambda_w        = (1E-2);    % lambda*E to control kappa. 
net.sets.phi_w           = 0.15;      % multiplicative decrease to eta
net.sets.alpha_w         = 0.15;       %momentum

net.sets.ac_factor       = 1.5;
net.sets.niters          = 1500;
net.sets.online          = false;
net.sets.grad_pow        = 3;


% Looping variables
nmodels = 10;
dels    = [1 5 10];
tstepz  = [15:5:45 55:10:75];
tcs     = [0.75];  %change

if (~exist('mat','dir')), mkdir('mat'); end;
for mi=nmodels:-1:1
    net.sets.rseed = mi;

    for tci = 1:length(tcs)
        net.sets.train_criterion = tcs(tci); 

        for tsi = 1:length(tstepz)
            net.sets.tsteps   = tstepz(tsi);
            %Idur = net.sets.tsteps - Idel;
            net.sets.tstop  = net.sets.tstart+net.sets.tsteps*net.sets.dt;
            net.sets.I_LIM  = net.sets.tstart+net.sets.dt*(Idel +[0 Idur]); %in terms of time, not steps
            net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error
            
            for di=1:length(dels)
                net.sets.del  = dels(di); 
                net.sets.D_LIM = [1 net.sets.del];
                
                % Set the defaults here, getting a new filename, 
                %   so that we can tweak the filename and check
                %   to see if it exists.
                net.sets = r_massage_params(guru_rmfield(net.sets,'matfile'));
                net.sets.matfile = fullfile('mat', net.sets.matfile);
            
                % Only run this simulation if necessary
                if (exist(net.sets.matfile,'file')), 
                    fprintf('Found %s; moving on...\n', net.sets.matfile);

                % Run simulation
                else
                    fprintf('Making %s...\n', net.sets.matfile);
                    r_main(net);
                end;
            end; 
        end;
    end;
end;
