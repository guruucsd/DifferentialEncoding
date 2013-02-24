function [net,pats,data,f,sets] = r_main(net,pats,data)
%

    % Validate & set defaults
    [net] = r_massage_params(net);
    rand('seed',net.sets.rseed);

    % Create patterns for the given training paradigm
    if (~exist('pats','var'))
        pats = r_pats(net);
    end;
    
    % If the network doesn't exist, then start net from scratch
    if (~isfield(net,'w'))
        [net] = net.fn.init(net, pats);
    end;

    % Train the network
    fprintf('Training [autoencoder=%d] network with tsteps=%d, max_del=%d, to tc=%4.2f\n', ...
             (isfield(net.sets, 'autoencoder') && net.sets.autoencoder), ...
             net.sets.tsteps, max(net.sets.D_CC_INIT(:)), net.sets.train_criterion);
    if ~exist('data','var')
      [net,data] = net.fn.train(net,pats.train);
    else
      [net,data] = net.fn.train(net,pats.train,data);
    end;

    % analyze
    [data]     = r_test(net,pats,data); %regular test
%    [data.an]  = r_analyze(net, pats, data);
    
    % Save result
    save(net.sets.matfile,'net','pats','data');
    
