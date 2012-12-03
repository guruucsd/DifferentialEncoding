function [net] = r_init_de_feedforward(net, pats)
    
    %%%%%%%%%%%%%%%%%%%%
    % Set up network structure
    %%%%%%%%%%%%%%%%%%%%
    
    %network parameters
    net.ninput  = pats.ninput; 
    net.nhidden = 2*net.sets.nhidden_per; 
    net.noutput = pats.noutput; 
    net.ncc     = net.sets.ncc;
    net.nunits = 1+net.ninput+net.nhidden+net.noutput;    % Includes bias node (index=0)

    % Compute indices to different types of units
    net.idx.lvf_input      = 1                         + [1:net.ninput/2];
    net.idx.rvf_input      = net.idx.lvf_input(end)    + [1:net.ninput/2];
    net.idx.lh_hu          = net.idx.rvf_input(end)    + [1:net.nhidden/2];
    net.idx.rh_hu          = net.idx.lh_hu(end)        + [1:net.nhidden/2];
    net.idx.lh_output      = net.idx.rh_hu(end)        + [1:net.noutput/2];
    net.idx.rh_output      = net.idx.lh_output(end)    + [1:net.noutput/2];

    % Summary indices    
%    net.idx.lh_cc  = net.idx.lh_hu(end-net.ncc+1:end); %topographic, from inside-out
%    net.idx.rh_cc  = net.idx.rh_hu(1:net.ncc);
    net.idx.lh_cc  = net.idx.lh_hu(round(linspace(1, length(net.idx.lh_hu), net.ncc)));
    net.idx.rh_cc  = net.idx.rh_hu(length(net.idx.rh_hu)+1-round(linspace(1, length(net.idx.rh_hu), net.ncc)));
    net.idx.lh_ih  = setdiff(net.idx.lh_hu, net.idx.lh_cc);
    net.idx.rh_ih  = setdiff(net.idx.rh_hu, net.idx.rh_cc);

    net.idx.input  = [net.idx.lvf_input net.idx.rvf_input ];
    net.idx.output = [net.idx.lh_output net.idx.rh_output];
    net.idx.hidden = [net.idx.lh_hu     net.idx.rh_hu];
    net.idx.cc     = sort([net.idx.lh_cc net.idx.rh_cc]);
    

    % Create connections
    net.cC = false(net.nunits,net.nunits);             % connections

    net.cC(1,[net.idx.hidden net.idx.output])         = true;    %bias
    
    % No Visual cross-over
    net.cC(net.idx.lvf_input,net.idx.rh_hu) = de_connector1D(net.ninput, net.sets.nhidden_per, net.sets.nconn, net.sets.sigs(1));    %input->hidden
    net.cC(net.idx.rvf_input,net.idx.lh_hu) = de_connector1D(net.ninput, net.sets.nhidden_per, net.sets.nconn, net.sets.sigs(2)); 

    net.cC(net.idx.lh_hu,net.idx.lh_hu) = eye(size(net.cC(net.idx.lh_hu,net.idx.lh_hu))); % hidden recurrent
    net.cC(net.idx.rh_hu,net.idx.rh_hu) = eye(size(net.cC(net.idx.rh_hu,net.idx.rh_hu))); 
    net.cC(net.idx.lh_cc,net.idx.rh_cc) = eye(size(net.cC(net.idx.lh_cc,net.idx.rh_cc))); %callosal
    net.cC(net.idx.rh_cc,net.idx.lh_cc) = eye(size(net.cC(net.idx.rh_cc,net.idx.lh_cc)));
    
    % symmetric DE connectivity to output
    if (mod(length(net.idx.lh_output), length(net.idx.rvf_input))==0)
        ndups = round(length(net.idx.lh_output)/length(net.idx.rvf_input));
        net.cC(net.idx.lh_hu, net.idx.lh_output) = repmat(net.cC(net.idx.rvf_input,net.idx.lh_hu)', [1 ndups]);
        net.cC(net.idx.rh_hu, net.idx.rh_output) = repmat(net.cC(net.idx.lvf_input,net.idx.rh_hu)', [1 ndups]); 
    
    % full connectivity to output
    else
        error('Full connectivity to output?\n');
        net.cC(net.idx.lh_hu, net.idx.lh_output) = true;
        net.cC(net.idx.rh_hu, net.idx.rh_output) = true;
    end;

    % Validation:
    %sum(net.cC,1)-1 %receptive field, bias removed;
                   %                  input->0, 
                   %                  early_hidden->23, 
                   %                  early_cc->17, 
                   %                  late_hidden->18, 
                   %                  late_cc->12, 
                   %                  output->20
                   
    %sum(net.cC,2)'   %projective field; input->20, 
                   %                  early_hidden->18, 
                   %                  early_cc->12, 
                   %                  late_hidden->23, 
                   %                  late_cc->17, 
                   %                  output->0
    

    %%%%%%%%%%%%%%%%%%%%
    % Set up network parameters/values
    %%%%%%%%%%%%%%%%%%%%
    
    % Create weights
    net.w  = net.sets.W_INIT(1)+diff(net.sets.W_INIT)*rand(size(net.cC));
    net.T  = net.sets.T_INIT(1)+diff(net.sets.T_INIT)*rand(net.nunits,1);
    net.D  = net.sets.D_INIT(1) + diff(net.sets.D_INIT)*randi(net.sets.D_INIT, size(net.cC)); %actual 
    


    % "Fan-in" weights (p. 339)
    net.fan_in   = (sum(net.cC,1)-1)*net.sets.tsteps; %inputs over all time
    net.idx.fan.core  = 1+net.ninput+[1:net.nhidden+net.noutput];
    net.idx.fan.bias  = 1:1;
    net.w(net.idx.fan.core,net.idx.fan.core)  = net.w(net.idx.fan.core,net.idx.fan.core)./repmat(net.fan_in(net.idx.fan.core), [length(net.idx.fan.core) 1]);
    net.w(net.idx.fan.bias,:)                 = net.w(net.idx.fan.bias,:)./mean(net.fan_in);
    net.w = net.w.*net.cC;
    
    % Create delays
    net.D(~net.cC) = 1; %dummy ones for all connections
    net.D(net.idx.lh_cc,net.idx.rh_cc) = net.sets.del; %early callosal
    net.D(net.idx.rh_cc,net.idx.lh_cc) = net.sets.del;
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
