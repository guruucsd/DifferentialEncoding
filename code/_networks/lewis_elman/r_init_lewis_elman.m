function [net] = r_init_lewis_elman(net, pats)
    
    %%%%%%%%%%%%%%%%%%%%
    % Set up network structure
    %%%%%%%%%%%%%%%%%%%%
    
    %network parameters
    net.ninput  = pats.ninput; 
    net.nhidden = 2*net.sets.nhidden_per; 
    net.noutput = pats.noutput;
    net.ncc     = net.sets.ncc;
    net.nunits  = 1+net.ninput+net.nhidden+net.noutput;    % Includes bias node (index=0)

    % Compute indices to different types of units
    net.idx.lh_input       = 1                         + [1:net.ninput/2]; % 1 is bias
    net.idx.rh_input       = net.idx.lh_input(end)     + [1:net.ninput/2];
    net.idx.lh_hu          = net.idx.rh_input(end)     + [1:net.nhidden/2];
    net.idx.rh_hu          = net.idx.lh_hu(end)        + [1:net.nhidden/2];
    net.idx.lh_output      = net.idx.rh_hu(end     )   + [1:net.noutput/2];
    net.idx.rh_output      = net.idx.lh_output(end)    + [1:net.noutput/2];
    
    % Summary indices
    net.idx.lh_cc  = net.idx.lh_hu(end-net.ncc+1:end);
    net.idx.rh_cc  = net.idx.rh_hu(1:net.ncc);
    net.idx.lh_ih  = setdiff(net.idx.lh_hu, net.idx.lh_cc);
    net.idx.rh_ih  = setdiff(net.idx.rh_hu, net.idx.rh_cc);

    net.idx.input  = [net.idx.lh_input  net.idx.rh_input ];
    net.idx.output = [net.idx.lh_output net.idx.rh_output];
    net.idx.hidden = setdiff(2:net.nunits, [net.idx.input net.idx.output]); %1 is bias
    net.idx.cc    = sort([net.idx.lh_cc net.idx.rh_cc]);
    

    % Create connections
    net.cC = false(net.nunits,net.nunits);             % connections

    net.cC(1,setdiff(2:end, net.idx.input))         = true;    %bias
    
    net.cC(net.idx.lh_input,net.idx.lh_hu) = true;    %input->early hidden
    net.cC(net.idx.rh_input,net.idx.rh_hu) = true; 

    net.cC(net.idx.lh_hu,net.idx.lh_hu) = true; %early hidden recurrent
    net.cC(net.idx.rh_hu,net.idx.rh_hu) = true; 
    net.cC(net.idx.lh_cc,net.idx.rh_cc) = true; %early callosal
    net.cC(net.idx.rh_cc,net.idx.lh_cc) = true;
        
        
    net.cC(net.idx.lh_hu, net.idx.lh_output) = true;    %late hidden->output
    net.cC(net.idx.rh_hu, net.idx.rh_output) = true; 

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

    % "Fan-in" weights (p. 339)
    net.fan_in   = (sum(net.cC,1)-1)*net.sets.tsteps; %inputs over all time
    net.idx.fan.core  = 1+net.ninput+[1:net.nhidden+net.noutput];
    net.idx.fan.bias  = 1:1;
    net.w(net.idx.fan.core,net.idx.fan.core)  = net.w(net.idx.fan.core,net.idx.fan.core)./repmat(net.fan_in(net.idx.fan.core), [length(net.idx.fan.core) 1]);
    net.w(net.idx.fan.bias,:)                 = net.w(net.idx.fan.bias,:)./mean(net.fan_in);
    net.w = net.w.*net.cC;
    
    % Create delays
    net.D  = net.sets.D_INIT(1) + diff(net.sets.D_INIT)*randi(net.sets.D_INIT, size(net.cC)); %random delays, from a given distribution.  Will redo 

    % Intrahemispheric
    net.D(net.idx.lh_ih,net.idx.rh_ih) = net.sets.D_IH_INIT(1,1,1) + diff(net.sets.D_IH_INIT(1,1,:))*randi(net.sets.D_IH_INIT(1,1,:), size(net.D(net.idx.lh_ih,net.idx.rh_ih))); %random ih connections; %early callosal
    net.D(net.idx.rh_ih,net.idx.lh_ih) = net.sets.D_IH_INIT(1,2,1) + diff(net.sets.D_IH_INIT(1,2,:))*randi(net.sets.D_IH_INIT(1,2,:), size(net.D(net.idx.rh_ih,net.idx.lh_ih))); %random CC connections; %early callosal
    % Interhemispheric
    net.D(net.idx.lh_cc,net.idx.rh_cc) = randi(net.sets.D_CC_INIT(1,1,:), size(net.D(net.idx.lh_cc,net.idx.rh_cc))); %random CC connections; %early callosal
    net.D(net.idx.rh_cc,net.idx.lh_cc) = randi(net.sets.D_CC_INIT(1,2,:), size(net.D(net.idx.rh_cc,net.idx.lh_cc))); %random CC connections; %early callosal

    net.Df = double(net.D);


    net.T  = net.sets.T_INIT(1)+diff(net.sets.T_INIT)*rand(net.nunits,1);

    % By default, all existing quantities are changeable.
    net.wC  = net.cC;
    net.DC  = net.cC;
    net.TC  = true(size(net.T));

    
    %%%%%%%%%%%%%%%%%%%%
    % Set up network parameters/values
    %%%%%%%%%%%%%%%%%%%%

    if ~isfield(net, 'fn'),      net.fn = struct(); end;
    
    % Error functions
    
    % sum-squared error
    if ~isfield(net.fn, 'sse'),  net.fn.sse  = @(y,d)   (0.5.*(y-d).^2);        end;
%ben

    if ~isfield(net.fn, 'Err'),  net.fn.Err  = @(y,d)   (net.fn.sse(y,d)); end;
    if ~isfield(net.fn, 'Errp'), net.fn.Errp = @(y,d,p) ((y-d).^p); end;

    % Cross entropy
   % if ~isfield(net.fn, 'Err'),  net.fn.Err  = @(y,d)   (ce(y,d)); end;
   % if ~isfield(net.fn, 'Errp'), net.fn.Errp = @(y,d,p) ( ((y+1)/2-(d+1)/2).^(p)); end;

    
    
    % Activation functions
    
    % 1.72 tanh
%    if ~isfield(net.fn, 'f'),    net.fn.f     = @(x)    (1.7159*(2 ./ (1 + exp(-2 * 2*x/3)) - 1)); end;
%    if ~isfield(net.fn, 'fp'),   net.fn.fp    = @(x,fx) (1.7159*2/3*(1 - (fx/1.7159).^2)); end;
    
    %zero-mean sigmoid
    %if ~isfield(net.fn, 'f'),    net.fn.f      = @(x)    (-1 + 2./(1+exp(-x))); end;
    %if ~isfield(net.fn, 'fp'),   net.fn.fp     = @(x,fx) (fx-fx.^2); end;

    %tanh
    if ~isfield(net.fn, 'f'),    net.fn.f      = @(x)    ((exp(x)-exp(-x)) ./ (exp(x)+exp(-x))); end;
    if ~isfield(net.fn, 'fp'),   net.fn.fp     = @(x,fx) (1-fx.^2); end;


    % output

    % same as input
%    if ~isfield(net.fn, 'fo'),   net.fn.fo     = @(x)    (1.7159*(2 ./ (1 + exp(-2 * 2*x/3)) - 1)); end;
%:    if ~isfield(net.fn, 'fpo'),  net.fn.fpo    = @(x,fx) (1.7159*2/3*(1 - (fx/1.7159).^2)); end;

%    if ~isfield(net.fn, 'fo'),   net.fn.fo    = net.fn.f; end;
%    if ~isfield(net.fn, 'fpo'),  net.fn.fpo   = net.fn.fp; end;
    
    % tanh (normal) (for squashing the output)
    if ~isfield(net.fn, 'fo'),    net.fn.fo      = @(x)    ((exp(x)-exp(-x)) ./ (exp(x)+exp(-x))); end;
    if ~isfield(net.fn, 'fpo'),   net.fn.fpo     = @(x,fx) (1-fx.^2); end;


    % softmax? used for cross-entropy error...
    %if ~isfield(net.fn, 'fo'),    net.fn.fo     = @(x)    (f1(x)); end;
    %if ~isfield(net.fn, 'fpo'),   net.fn.fpo    = @(x,fx) (f2(x)); end;
    

function Err = ce(y,d)
    y = (y+1)/2;
    d = (d+1)/2;
    Err = -(d.*log(abs(y)) + (1-d).*log(abs(1-y)));
    Err( abs(d-y)<=1 & (y<0 | y>1) ) = -Err( abs(d-y)<=1 & (y<0 | y>1) );
   % Err( abs(d-y)>1  & (y<0 | y>1) ) 
    Err(isnan(Err))   = 0;
    Err(isinf(Err))   = log(1000);
    Err(~isreal(Err)) = log(1000);
    
    if (any(Err(:)<0)), error('?'); end;
        

function o = f1(z)
% z=[time pats outputs]
% normalize over PATTERNS (dim 2)

     exps  = exp(z);
     sexps = repmat(sum(exps,2), [1 size(z,2),1]);
     o     = exps./sexps;

     o = 2.*(o-0.5);

     if any(isnan(o(:))), error('o is nan!'); end;
     if any(isinf(o(:))), error('o is inf!'); end;
     
function h1 = f2(z)
% z=[time pats outputs]
% normalize over PATTERNS (dim 2)

     exps  = exp(z);
     sexps = repmat(sum(exps,2), [1 size(z,2),1]);
     h1    = (sexps+1)./(sexps.^2);

     if any(isnan(h1(:))), error('h1 is nan!'); end;
     if any(isinf(h1(:))), error('h1 is inf!'); end;

    
