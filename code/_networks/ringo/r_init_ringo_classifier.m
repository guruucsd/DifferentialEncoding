function [net,pats] = r_init_ringo_classifier(net, pats)

    %%%%%%%%%%%%%%%%%%%%
    % Set up the autoencoder
    %%%%%%%%%%%%%%%%%%%%

    % Now construct an autoencoder
    net.ac.sets                  = rmfield(net.sets,'matfile'); %to force a save
 %   net.ac.sets.init_type        = 'ringo'; % structure
 %   net.ac.sets.autoencoder      = true;
 %   net.ac.sets.duplicate_output = true;

    % Should find a better way top propagate these
%    net.ac.sets.train_criterion = (1/net.sets.ac_factor)*net.sets.train_criterion;
%    net.ac.sets.eta_w           = (1/net.sets.ac_factor)*net.sets.eta_w;
%    net.ac.sets.lambda_w        = (1/net.sets.ac_factor)*net.sets.lambda_w;
%    net.ac.sets.phi_w           = (net.sets.ac_factor) *net.sets.phi_w;
    
    % And
%    net.sets.autoencoder      = false;
%    net.sets.duplicate_output = false;

%    net.sets.tsteps = net.sets.tsteps + 2  ;%we'll add another hidden layer, so measure output at one step later
%    net.sets.tstop  = net.sets.tsteps * net.sets.dt;
%    net.sets.S_LIM  = net.sets.S_LIM  + 2*net.sets.dt;
   
    %%%%%%%%%%%%%%%%%%%%
    % Set up network structure
    %%%%%%%%%%%%%%%%%%%%

    %network parameters
    net.ninput  = 2*net.sets.ac.nhidden_per; 
    net.nhidden = 2*net.sets.nhidden_per;
    net.noutput = 10;
    net.ncc     = 0;
    net.nunits  = 1+net.ninput+net.nhidden+net.noutput;    % Includes bias node (index=0)

    net.cC = false(net.nunits);
    net.cC(1,2:end) = true; %bias; will remove wrong conections below
    
    % Compute indices to different types of units
    net.idx.lh_input       = 1                          + [1:net.ninput/2];
    net.idx.rh_input       = net.idx.lh_input(end)      + [1:net.ninput/2];
    net.idx.lh_classifiers = net.idx.rh_input(end)      + [1:net.nhidden/2];
    net.idx.rh_classifiers = net.idx.lh_classifiers(end)+ [1:net.nhidden/2];
    net.idx.lh_output      = net.idx.rh_classifiers(end)+ [1:net.noutput/2];
    net.idx.rh_output      = net.idx.lh_output(end)     + [1:net.noutput/2];
 
    % Summary indices    
    net.idx.input  = [net.idx.lh_input  net.idx.rh_input ];
    net.idx.output = [net.idx.lh_output net.idx.rh_output];
    net.idx.hidden = setdiff(1:net.nunits, [net.idx.input net.idx.output]);
    net.idx.lh_cc  = [];
    net.idx.rh_cc  = [];
    net.idx.cc     = sort([net.idx.lh_cc net.idx.rh_cc]);
    

    % Create connections
    net.cC = false(net.nunits,net.nunits);             % connections

    net.cC(1,[net.idx.hidden net.idx.output])         = true;    %bias
    
    net.cC(net.idx.lh_input,net.idx.lh_classifiers) = true;    %input->hidden
    net.cC(net.idx.rh_input,net.idx.rh_classifiers) = true; 

    net.cC(net.idx.lh_classifiers, net.idx.lh_output) = true;      %hidden->output
    net.cC(net.idx.rh_classifiers, net.idx.rh_output) = true; 


    %%%%%%%%%%%%%%%%%%%%
    % Set up network parameters/values
    %%%%%%%%%%%%%%%%%%%%
    
    % Create weights
    net.w  = net.sets.W_INIT(1)+diff(net.sets.W_INIT)*rand(size(net.cC));
    net.T  = net.sets.T_INIT(1)+diff(net.sets.T_INIT)*rand(net.nunits,1);
    net.D  = net.sets.D_INIT(1)+diff(net.sets.D_INIT)*randi(net.sets.D_INIT, size(net.cC)); %actual 
    


    % "Fan-in" weights (p. 339)
    net.fan_in   = (sum(net.cC,1)-1)*net.sets.tsteps; %inputs over all time
    net.idx.fan.core  = 1+net.ninput+[1:net.nhidden+net.noutput];
    net.idx.fan.bias  = 1:1;
    net.w(net.idx.fan.core,net.idx.fan.core)  = net.w(net.idx.fan.core,net.idx.fan.core)./repmat(net.fan_in(net.idx.fan.core), [length(net.idx.fan.core) 1]);
    net.w(net.idx.fan.bias,:)                 = net.w(net.idx.fan.bias,:)./mean(net.fan_in);
    net.w = net.w.*net.cC;
    
    % Create delays
    net.D(~net.cC) = 1; %dummy ones for all connections
    % no cc connections
    
    net.Df = double(net.D);


    % By default, all existing quantities are changeable.
    net.wC  = net.cC;
    net.DC  = net.cC;
    net.TC  = true(size(net.T));

    
    %%%%%%%%%%%%%%%%%%%%
    % Set up network parameters/values
    %%%%%%%%%%%%%%%%%%%%
    
    net.fn.sse  = @(y,d)     (0.5.*(y-d).^2);
    net.fn.Err  = @(s,y,d)   (0.5.*(s.*((y-d)).^2));
    net.fn.Errp = @(s,y,d,p) (     (s.*((y-d)).^p));
        
    %zero-mean sigmoid
%    net.fn.f      = @(x)  (-1 + 2./(1+exp(-x)));
%    net.fn.fp     = @(fx) (fx-fx.^2);

    %tanh
%    net.fn.f      = @(x)  ((exp(x)-exp(-x)) ./ (exp(x)+exp(-x)));
%    net.fn.fp     = @(fx) (1-fx.^2);

    %1.71*tanh(2*x/3)
    net.fn.f     = @(x) (1.7159*(2 ./ (1 + exp(-2 * 2*x/3)) - 1));
    net.fn.fp    = @(fx) (1.7159*2/3*(1 - (fx/1.7159).^2));


