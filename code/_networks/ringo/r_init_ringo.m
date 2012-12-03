function [net] = r_init_ringo(net, pats)
%
% net.ninput
% net.nhidden
% net.
%

    %%%%%%%%%%%%%%%%%%%%
    % Set up network structure
    %%%%%%%%%%%%%%%%%%%%
    
    %network parameters
    net.ninput  = pats.ninput; 
    net.nhidden = 2*net.sets.nhidden_per*2; 
    net.noutput = pats.noutput; 
    net.ncc     = net.sets.ncc;
    net.nunits  = 1+net.ninput+net.nhidden+net.noutput;    % Includes bias node (index=0)

    % Compute indices to different types of units
    net.idx.lh_input       = 1                         + [1:net.ninput/2];
    net.idx.rh_input       = net.idx.lh_input(end)     + [1:net.ninput/2];
    net.idx.lh_early_hu    = net.idx.rh_input(end)     + [1:net.nhidden/4];
    net.idx.rh_early_hu    = net.idx.lh_early_hu(end)  + [1:net.nhidden/4];
    net.idx.lh_late_hu     = net.idx.rh_early_hu(end)  + [1:net.nhidden/4];
    net.idx.rh_late_hu     = net.idx.lh_late_hu(end)   + [1:net.nhidden/4];
    net.idx.lh_output      = net.idx.rh_late_hu(end)   + [1:net.noutput/2];
    net.idx.rh_output      = net.idx.lh_output(end)    + [1:net.noutput/2];
    
    % Summary indices
    net.idx.lh_early_cc  = net.idx.lh_early_hu(end-net.ncc+1:end);
    net.idx.rh_early_cc  = net.idx.rh_early_hu(1:net.ncc);
    net.idx.lh_late_cc   = net.idx.lh_late_hu(end-net.ncc+1:end);
    net.idx.rh_late_cc   = net.idx.rh_late_hu(1:net.ncc);
    net.idx.lh_early_ih  = setdiff(net.idx.lh_early_hu, net.idx.lh_early_cc);
    net.idx.rh_early_ih  = setdiff(net.idx.rh_early_hu, net.idx.rh_early_cc);
    net.idx.lh_late_ih   = setdiff(net.idx.lh_late_hu, net.idx.lh_late_cc);
    net.idx.rh_late_ih   = setdiff(net.idx.rh_late_hu, net.idx.rh_late_cc);

    net.idx.input  = [net.idx.lh_input  net.idx.rh_input ];
    net.idx.output = [net.idx.lh_output net.idx.rh_output];
    net.idx.hidden = setdiff(1:net.nunits, [net.idx.input net.idx.output]);
    net.idx.lh_cc = [net.idx.lh_early_cc net.idx.lh_late_cc];
    net.idx.rh_cc = [net.idx.rh_early_cc net.idx.rh_late_cc];
    net.idx.cc    = sort([net.idx.lh_cc net.idx.rh_cc]);
    

    % Create connections
    net.cC = false(net.nunits,net.nunits);             % connections

    net.cC(1,setdiff(2:end, net.idx.input))         = true;    %bias
    
    net.cC(net.idx.lh_input,net.idx.lh_early_hu) = true;    %input->early hidden
    net.cC(net.idx.rh_input,net.idx.rh_early_hu) = true; 

    net.cC(net.idx.lh_early_hu,net.idx.lh_early_hu) = true; %early hidden recurrent
    net.cC(net.idx.rh_early_hu,net.idx.rh_early_hu) = true; 
    net.cC(net.idx.lh_early_cc,net.idx.rh_early_cc) = true; %early callosal
    net.cC(net.idx.rh_early_cc,net.idx.lh_early_cc) = true;
        
    net.cC(net.idx.lh_early_ih,net.idx.lh_late_ih) = true;    %early->late hidden
    net.cC(net.idx.rh_early_ih,net.idx.rh_late_ih) = true; 
    net.cC(net.idx.lh_late_ih,net.idx.lh_early_ih) = true;    %late->early hidden
    net.cC(net.idx.rh_late_ih,net.idx.rh_early_ih) = true; 
    
    net.cC(net.idx.lh_late_hu,net.idx.lh_late_hu) = true; %late hidden recurrent
    net.cC(net.idx.rh_late_hu,net.idx.rh_late_hu) = true; 
    net.cC(net.idx.lh_late_cc,net.idx.rh_late_cc) = true; %late callosal
    net.cC(net.idx.rh_late_cc,net.idx.lh_late_cc) = true;
        
    net.cC(net.idx.lh_late_hu, net.idx.lh_output) = true;    %late hidden->output
    net.cC(net.idx.rh_late_hu, net.idx.rh_output) = true; 

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
    net.D  = net.sets.D_INIT(1) + diff(net.sets.D_INIT)*randi(net.sets.D_INIT, size(net.cC)); %random CC connections
    
    


    % "Fan-in" weights (p. 339)
    net.fan_in   = (sum(net.cC,1)-1)*net.sets.tsteps; %inputs over all time
    net.idx.fan.core  = 1+net.ninput+[1:net.nhidden+net.noutput];
    net.idx.fan.bias  = 1:1;
    net.w(net.idx.fan.core,net.idx.fan.core)  = net.w(net.idx.fan.core,net.idx.fan.core)./repmat(net.fan_in(net.idx.fan.core), [length(net.idx.fan.core) 1]);
    net.w(net.idx.fan.bias,:)                 = net.w(net.idx.fan.bias,:)./mean(net.fan_in);
    net.w = net.w.*net.cC;
    
    % Create delays
    net.D(~net.cC) = 1; %dummy ones for all NON-connections
    
    % Intrahemispheric
    net.D(net.idx.lh_early_ih,net.idx.lh_late_ih)  = net.sets.D_IH_INIT(1,1,1) + diff(net.sets.D_IH_INIT(1,1,:))*randi(net.sets.D_IH_INIT(1,1,:), size(net.D(net.idx.lh_early_ih,net.idx.lh_late_ih))); %random CC connections; %early callosal
    net.D(net.idx.lh_late_ih, net.idx.lh_early_ih) = net.sets.D_IH_INIT(1,2,1) + diff(net.sets.D_IH_INIT(1,2,:))*randi(net.sets.D_IH_INIT(1,2,:), size(net.D(net.idx.lh_late_ih, net.idx.lh_early_ih))); %random CC connections; %early callosal
    net.D(net.idx.rh_early_ih,net.idx.rh_late_ih)  = net.sets.D_IH_INIT(2,1,1) + diff(net.sets.D_IH_INIT(2,1,:))*randi(net.sets.D_IH_INIT(2,1,:), size(net.D(net.idx.rh_early_ih,net.idx.rh_late_ih))); %random CC connections; %late callosal
    net.D(net.idx.rh_late_ih, net.idx.rh_early_ih) = net.sets.D_IH_INIT(2,2,1) + diff(net.sets.D_IH_INIT(2,2,:))*randi(net.sets.D_IH_INIT(2,2,:), size(net.D(net.idx.rh_late_ih, net.idx.rh_early_ih))); %random CC connections; %late callosal
    
    % Interhemispheric
    net.D(net.idx.lh_early_cc,net.idx.rh_early_cc) = net.sets.D_CC_INIT(1,1,1) + diff(net.sets.D_CC_INIT(1,1,:))*randi(net.sets.D_CC_INIT(1,1,:), size(net.D(net.idx.lh_early_cc,net.idx.rh_early_cc))); %random CC connections; %early callosal
    net.D(net.idx.rh_early_cc,net.idx.lh_early_cc) = net.sets.D_CC_INIT(1,2,1) + diff(net.sets.D_CC_INIT(1,2,:))*randi(net.sets.D_CC_INIT(1,2,:), size(net.D(net.idx.rh_early_cc,net.idx.lh_early_cc))); %random CC connections; %early callosal
    net.D(net.idx.lh_late_cc, net.idx.rh_late_cc)  = net.sets.D_CC_INIT(2,1,1) + diff(net.sets.D_CC_INIT(2,1,:))*randi(net.sets.D_CC_INIT(2,1,:), size(net.D(net.idx.lh_late_cc, net.idx.rh_late_cc))); %random CC connections; %late callosal
    net.D(net.idx.rh_late_cc, net.idx.lh_late_cc)  = net.sets.D_CC_INIT(2,2,1) + diff(net.sets.D_CC_INIT(2,2,:))*randi(net.sets.D_CC_INIT(2,2,:), size(net.D(net.idx.rh_late_cc, net.idx.lh_late_cc))); %random CC connections; %late callosal

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

