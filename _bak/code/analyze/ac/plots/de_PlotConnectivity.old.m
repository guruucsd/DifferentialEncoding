function [fig] = de_PlotConnectivity(models)
%function [fig] = de_PlotConnectivity(models)
%
% Show the average or instance connectivity of a model
%
% Input:
% model         : see de_model for details
%
% Output:
% h             : array of handles to plots

  % Plot 1: show trend of encoding error, according to type (Reza's plots)
  %   This plot will show outliers as spikes.
  % Create old-style info

  nDims   = length(models(1).nInput);
  nSigmas = length(models);

  switch (nDims)
    case 1, fig = de_PlotConnectivity_Instance1D(models(1));
    case 2, fig = de_PlotConnectivity_Instance2D(models(1));
  end;

  switch (nDims)
    case 1, fig(2) = de_PlotConnectivity_Average1D(models);
    case 2, fig(2) = de_PlotConnectivity_Average2D(models);
  end;
 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fh = de_PlotConnectivity_1D(C, mu, nInput, nHidden, t)
  % 1d plot
    
    C_idx = (nInput+1):(nInput+nHidden);
    halfC = C(C_idx, 1:nInput);

    fh = figure;
    imagesc(halfC); 
    hold on; 
    plot(mu,1:nHidden,'y*');
    set(gca,'ytick',unique([1 5:5:nHidden nHidden]));
    set(gca,'xtick',unique([1 5:5:nInput  nInput]));
    xlabel('Input unit #'); ylabel('Hidden unit #');
    %x`set(xlim, [1 nInput], 'ylim', [1 
    mfe_suptitle(t);
   % end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotConnectivity_Instance1D(model)
  % 1d plot
    
    [junk, hpl, mu] = de_connector(model);
    model = de_LoadProps(model, 'ac', 'Weights');
    
    C     = full(model.ac.Weights ~=0);

    fh = de_PlotConnectivity_1D( ...
        C, mu, ...
        model.nInput, ...
        model.nHidden, ...
        sprintf('Instance connectivity plot, o=%4.1f', model.sigma) ...
      );

    fig = de_NewFig(fh, 'connect-inst', 'hu', model.nHidden, model.nInput);
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotConnectivity_Average1D(models)
  % 1d plot

    [junk, hpl, mu] = de_connector(models(1));
    models = de_LoadProps(models, 'ac', 'Weights');
    
    % Plot the connectivity pattern
    ac = [models.ac];
    w  = reshape(full(vertcat(ac.Weights)), [size(ac(1).Weights,1) length(ac) size(ac(1).Weights,2)]);
    c  = squeeze(mean( (w ~= 0), 2));
    
    fh = de_PlotConnectivity_1D( ...
        c, mu, ...
        models(1).nInput, ...
        models(1).nHidden, ...
        sprintf('Average connectivity plot, o=%4.1f', models(1).sigma) ...
      );

    fig = de_NewFig(fh, 'connect-avg', 'hu', models(1).nHidden, models(1).nInput);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotConnectivity_2D(c, mu, t)
  %2d plot
  % c is [nHidden x imgHeight x imgWidth]
  
    nHidden = size(c,1);
    inPix = [size(c,2) size(c,3)];
    [cy,cx] = find(mu);
    hpl     = nHidden / length(cx);
    
    [nRows,nCols] = guru_optSubplots(nHidden);
    for i=1:length(cx)
      for j=1:hpl
        hu = (j-1)*length(cx)+i;
        layer = squeeze(c(hu,:,:));
        
        % Plot the connectivity pattern
        subplot(nRows, nCols, hu);
        imagesc(layer);
        set(gca,'ytick',[], 'xtick', []);
        hold on;
        plot(cx(i), cy(i), '*g');
      end;    
    end;
    
    hold on;    
    mfe_suptitle(t);
    

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotConnectivity_Instance2D(model)
  %2d plot
    fig = de_NewFig('connect-inst', 'hu', model.nHidden, model.nInput);
        
    [junk, hpl, mu] = de_connector(model);
    model = de_LoadProps(model, 'ac', 'Weights');
    
    inPix = prod(model.nInput);
    c     = (model.ac.Weights ~= 0);
    c2    = reshape(full(c((inPix+1):(inPix+model.nHidden),1:inPix)), [model.nHidden model.nInput]);
 
    de_PlotConnectivity_2D( c2, mu, sprintf('Instance connectivity plot, o=%4.1f', model.sigma));
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotConnectivity_Average2D(models)
  %2d plot
    fig = de_NewFig('connect-avg', 'hu', models(1).nHidden, models(1).nInput);

    [junk, hpl, mu] = de_connector(models(1));
    models = de_LoadProps(models, 'ac', 'Weights');
    
    inPix = prod(models(1).nInput);
    c2 = zeros([models(1).nHidden models(1).nInput]);
    
    for i=1:length(models)
      c     = (models(i).ac.Weights ~= 0);
      c2    = c2 + reshape(full(c((inPix+1):(inPix+models(i).nHidden),1:inPix)), [models(i).nHidden models(i).nInput]) / length(models);
    end;

    fig.name   = 'connect-avg';
    fig.handle = figure;

    de_PlotConnectivity_2D( c2, mu, sprintf('Average connectivity plot, o=%4.1f', models(1).sigma));

