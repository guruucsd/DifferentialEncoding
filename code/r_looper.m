function r_looper(net, n_nets)
%function r_looper(net, n_nets)
%
% Loops over some # of networks to execute them.


    % Select # of networks to run
    if ~exist('n_nets','var')
      if isfield(net.sets,'n_nets'), n_nets = net.sets.n_nets;
      else                           n_nets = 10;
      end;
    end;

    % Get random seed, save default network settings
    min_rseed = net.sets.rseed;
    sets= net.sets;

    parfor s=(min_rseed-1+[1:n_nets])
        r_dummy(sets, s);
    end;


function r_dummy(sets, s)

   % Make sure not to reuse networks!
   net.sets = sets;
   net.sets.rseed = s;

    %
    net = r_massage_params(net);
    matfile = fullfile(net.sets.dirname, net.sets.matfile); %getfield(getfield(, 'sets'),'matfile'));
    if exist(matfile, 'file')    
        fprintf('Skipping %s\n', matfile);
        return;
    end; % don't re-run

    %
    if ~exist(net.sets.dirname,'dir'), mkdir(net.sets.dirname); end;

    try
     [net,pats,data]          = r_main(net);
     [data.an]                = r_analyze(net, pats, data);
     %unix(['mv ' net.sets.matfile ' ./' net.sets.dirname]);
   catch err
     fprintf(lasterr);
     err.stack.file
   end;