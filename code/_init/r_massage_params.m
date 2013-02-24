function [net] = r_massage_params(net)
% Take in a network, validate required parameters, and add any optional parameters that weren't specified'
%
% Required:
%   D_INIT:   delays on intra-area connections
%   D_CC_INIT: delays on inter-hemispheric connections
%   D_IH_INIT: delays on inter-area/intra-hemispheric connections
%
%   nhidden_per: # hidden units per area
%   init_type:   determines algorithm/code for initializing network.  Can be ringo or lewis_elman
%   ncc:         # interhemispheric units
%
%   tsteps:     total # of steps to run the network
%   dt:         time represented by a single timestep
%   tstart:     start time of system
%   tstop:      stop time in seconds (tstart+dt*tsteps)
%   dataset:    dataset to train on (random, lewis_elman, de_1D)
%
%   I_LIM:  time for input signal to be on
%   S_LIM:  max and min time to consider output
%   T_INIT: initial time constants (range to select randomly from)
%   T_LIM:  max/min time constants
%
%   eta_[w,T,D]:    learning rate
%   lambda_w: lambda*E to control kappa
%   phi_w:    multiplicative decrease to eta
%   alpha_w: momentum
%
%%%%
%   
%
%   REL_E_MAX:    maximum relative error increase that is acceptable
%   bad_pct_w:    allowable % of bad weight updates for a good training iteration
%   bad_pct_T:    allowable % of bad time constant updates for a good training iteration
%   bad_pct_D:    allowable % of bad delay updates for a good training iteration
%   wt_class:     How much to weight classification (vs error) in error [0 to 1]
%   wt_act:
%   wt_wts:
%   verbose
%   test_freq
    
    % 
%   online')),    sets.online      = false;      end;
%   bias_val')),  sets.bias_val    = 1;          end;
%   grad_pow')),  sets.grad_pow    = 1;          end;

    %%%%%%%%%%%%%%%%
    % Separate
    sets = net.sets;
    if (isfield(net,'fn')), fn = net.fn;
    else,                  fn = struct(); end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Required parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (~isfield(sets,'D_INIT')),      error('sets.D_INIT not set.'); end;      
    if (~isfield(sets,'D_CC_INIT')),   error('sets.D_CC_INIT not set.');  end;
    if (~isfield(sets,'D_IH_INIT')),   error('sets.D_IH_INIT not set.');  end;

    % Network structure params
%    if (~isfield(sets,'autoencoder')), error('sets.autoencoder not set.'); end;
    if (~isfield(sets,'nhidden_per')), error('sets.nhidden_per not set.'); end;
    if (~isfield(sets,'init_type')),   error('sets.init_type not set.'); end;
    if (~isfield(sets,'ncc')),         error('sets.ncc not set.'); end;

    % Timing params
    if (~isfield(sets,'tsteps')),      error('sets.tsteps not set.'); end;% min 1+3+del to get to contra output; 1+3 to get to ipsi
    if (~isfield(sets,'dt')),          error('sets.dt not set.'); end;
    if (~isfield(sets,'tstart')),      error('sets.tstart not set.'); end;
    if (~isfield(sets,'tstop')),       error('sets.tstop not set.'); end;
    if (~isfield(sets,'dataset')),     error('sets.dataset not set.'); end;

    if (~isfield(sets,'I_LIM')),       sets.I_LIM = sets.tstart + [sets.dt sets.tstop]; end; %in terms of time, not steps
    if (~isfield(sets,'S_LIM')),       error('sets.S_LIM not set.'); end;  % min & max time to consider error
    if (~isfield(sets,'T_INIT')),      error('sets.T_INIT not set.'); end;  %change     
    if (~isfield(sets,'T_LIM')),       sets.T_LIM = sets.T_INIT; end;

    % Training params
    %if (~isfield(sets,'npat')),     error('sets.npat not set.'); end;
    if (~isfield(sets,'eta_w')),     error('sets.eta_w not set.'); end;    %learning rate (initial)
    if (~isfield(sets,'lambda_w')),  error('sets.lambda_w not set.'); end;    % lambda*E to control kappa. 
    if (~isfield(sets,'phi_w')),     error('sets.phi_w not set.'); end;      % multiplicative decrease to eta
    if (~isfield(sets,'alpha_w')),   error('sets.alpha_w not set.'); end;      %momentum


    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Optional parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%

    % Training params
    if (~isfield(sets,'train_criterion')), sets.train_criterion = 0.5;   end;
    if (~isfield(sets,'niters')),    sets.niters      = 2500;            end;
    if (~isfield(sets,'train_type')),sets.train_type  = 'resilient';     end;
    if (~isfield(sets,'ac_factor')), sets.ac_factor   = 1.0;             end; %train criterion & training params for ac, compared to classifier
    if (~isfield(sets,'w_decay')),    sets.w_decay    = 0.0;             end; % amount of weight decay (regularization); 0=none
    if (~isfield(sets,'noise_init')), sets.noise_init = 0.0;             end; %no noisy initialization
    if (~isfield(sets,'noise_input')),sets.noise_input= 0.0;             end; %no noisy training inputs
    if (~isfield(sets,'force')),      sets.force      = true;            end; %no forced re-training
    
    if (~isfield(sets,'eta_w_min')), sets.eta_w_min   = 0;   end;    
    
    if (~isfield(sets,'eta_T')),     sets.eta_T       = 0;   end;     %learning rate (initial)
    if (~isfield(sets,'eta_T_min')), sets.eta_T_min   = 0;   end;
    if (~isfield(sets,'lambda_T')),  sets.lambda_T    = 0;   end;   % additive increase (times TOTAL ERROR)
    if (~isfield(sets,'phi_T')),     sets.phi_T       = 0;   end;        % multiplicative decrease to eta
    if (~isfield(sets,'alpha_T')),   sets.alpha_T     = 0;   end;     %momentum
    
    if (~isfield(sets,'eta_D')),     sets.eta_D       = 0;   end;      %learning rate (initial)
    if (~isfield(sets,'eta_D_min')), sets.eta_D_min   = 0;   end;
    if (~isfield(sets,'lambda_D')),  sets.lambda_D    = 0;   end;  % additive increase (times TOTAL ERROR)
    if (~isfield(sets,'phi_D')),     sets.phi_D       = 0;   end;  % multiplicative decrease to eta
    if (~isfield(sets,'alpha_D')),   sets.alpha_D     = 0;   end;  %momentum
    
    % Init params
    if (~isfield(sets,'W_INIT')),    sets.W_INIT      = [-1    1];        end;
    if (~isfield(sets,'W_LIM')),     sets.W_LIM       = [-inf  inf];      end;
    if (~isfield(sets,'D_CC_LIM')),  sets.D_CC_LIM    = sets.D_CC_INIT;   end;
    if (~isfield(sets,'D_IH_LIM')),  sets.D_IH_LIM    = sets.D_IH_INIT;   end;
%    if (~isfield(sets,'D_LIM')),     sets.D_LIM       = sets.D_INIT;      end;

    % Error cases
    if (~isfield(sets,'REL_E_MAX')), sets.REL_E_MAX   = .5;         end;
    if (~isfield(sets,'bad_pct_w')), sets.bad_pct_w   = 1;          end;
    if (~isfield(sets,'bad_pct_T')), sets.bad_pct_T   = 1;          end;
    if (~isfield(sets,'bad_pct_D')), sets.bad_pct_D   = 1;          end;
    if (~isfield(sets,'wt_class')),  sets.wt_class    = 0;          end;  % How much to weight classification (vs error) in error
    if (~isfield(sets,'wt_act')),    sets.wt_act      = 0;          end;
    if (~isfield(sets,'wt_wts')),    sets.wt_wts      = 0;          end;
    if (~isfield(sets,'verbose')),   sets.verbose     = false;      end;
    if (~isfield(sets,'test_freq')), sets.test_freq   = 100;        end;
    
    % 
    if (~isfield(sets,'online')),    sets.online      = false;      end;
    if (~isfield(sets,'bias_val')),  sets.bias_val    = 1;          end;
    if (~isfield(sets,'grad_pow')),  sets.grad_pow    = 1;          end;
    if (~isfield(sets,'rseed')),     sets.rseed       = randi(1E3), end;

    if (~isfield(sets, 'axon_noise')), sets.axon_noise=0; 
    elseif numel(sets.axon_noise)>1, guru_assert(sets.niters==numel(sets.axon_noise), 'axon_noise must be scalar, or size must match niters'); end;
    %    if (isfield(sets, 'autoencoder') && ~sets.autoencoder)
%        if (~isfield(sets,'ac')), sets.ac = sets; end;
        
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Massaged parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%

    sets.init_type  = strrep(sets.init_type,  '-', '_');
    sets.dataset    = strrep(sets.dataset,    '-', '_');
    sets.train_type = strrep(sets.train_type, '-', '_');
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculated parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%
    if (~isfield(sets, 'D_LIM'))
        all_delays = [sets.D_INIT(:); sets.D_CC_INIT(:); sets.D_IH_INIT(:)];
        sets.D_LIM = [min(all_delays) max(all_delays)];
    end;


    fn.init    = str2func(['r_init_'    sets.init_type]);
    fn.pats    = str2func(['r_pats_'    sets.dataset]);
    fn.train   = str2func(['r_train_'   sets.train_type]);
    fn.analyze = str2func(['r_analyze_' sets.dataset]);
    
    % Make a filename for saving
    if (~isfield(sets,'matfile'))
        sets.matfile = sprintf('%s_t%d_d%d_r%d_%s',sets.dataset,sets.tsteps,max(sets.D_CC_INIT(:)),sets.rseed, r_get_hash(sets));
        if (isfield(sets,'autoencoder') && sets.autoencoder)
          sets.matfile = [sets.matfile '-ac'];
        end;
        sets.matfile = [sets.matfile '.mat'];
    end;
    
    
    %%%%%%%%%%%%%%%%
    % recombine
    net.sets = sets;
    net.fn   = fn;
    

function h = r_get_hash(sets)
    origString = r_dump_sets(sets);
    h = sprintf('%d', round( sum(origString.*[1:5:5*length(origString)]) ));
    
function [str] = r_dump_sets(sets)
    
    str = '';
    a = fields(sets);
    for ai=1:length(a)
        v = sets.(a{ai});
        str = [str '%s: ' a{ai}]; 
        if (isnumeric(v))
            str = [str mat2str(v(:))]; 
        elseif (ischar(v))
            str = [str v];
        elseif (islogical(v))
            if (v), str = [str 'true']; else, str = [str 'false']; end;
        elseif (isstruct(v))
            str = [str sprintf('{[struct %s]: %s}', a{ai}, r_dump_sets(v))];
        else
            error('unknown type for net.sets.%s', a{ai});
        end;
        str = sprintf('%s\n', str);
    end;
    

