function [models] = de_DETrainAll(modelSettings)
%[models] = de_DETrainAll(modelSettings)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% model      : see de_model for details
%
% Outputs:
% models     : a model object for each trained model, with properties
%              specifying training parameters, final weights, training errors, etc.
  
  %----------------
  % Loop over architecture variables
  %   (if testing "robustness" of model)
  %----------------
  
  nc = modelSettings.nConns; nh = modelSettings.nHidden;
  for cc=1:length(nc), for hh=1:length(nh)
    model        = modelSettings;  %rmfield(modelSettings,'runs');
    model.nConns = nc(cc); model.nHidden = nh(hh);

    %----------------
    % Loop over training parameters
    %   (to search parameter space)
    %----------------
    acis = modelSettings.ac.AvgError; acas=modelSettings.ac.Acc; 
    aces = modelSettings.ac.EtaInit;  acds=modelSettings.ac.Dec;
    pis = modelSettings.p.AvgError;   pas=modelSettings.p.Acc; 
    pes = modelSettings.p.EtaInit;    pds=modelSettings.p.Dec;
    
    for aci=1:length(acis), for aca=1:length(acas)
    for ace=1:length(aces), for acd=1:length(acds)
      for pi=1:length(pis), for pa=1:length(pas)
      for pe=1:length(pes), for pd=1:length(pds)
       
        model.ac.AvgError = acis(aci); model.ac.Acc = acas(aca);
        model.ac.EtaInit  = aces(ace); model.ac.Dec = acds(acd);
        model.p.AvgError  = pis(pi);   model.p.Acc = pas(pa);
        model.p.EtaInit   = pes(pe);   model.p.Dec = pds(pd);
        
        models(:,:,pd,pe,pa,pi,acd,ace,aca,aci,cc,hh) = ...
          de_DETrainer(modelSettings, model);
          
      end; end; %pd, pe
      end; end; %pa, pi
    end; end; %acd, %ace
    end; end; %aca, aci
    
  end; end; %hh,cc
