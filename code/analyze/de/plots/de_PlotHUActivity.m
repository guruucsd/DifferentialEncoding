function [fig] = de_PlotHUActivity(models)
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

  nDims = length(models(1).nInput);

  switch (nDims)
    case 1, fig = de_PlotHUActivity_Instance1D(models(1));
    case 2, fig = de_PlotHUActivity_Instance2D(models(1));
  end;

  switch (nDims)
    case 1, fig(2) = de_PlotHUActivity_Average1D(models);
    case 2, fig(2) = de_PlotHUActivity_Average2D(models);
  end;
    
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotHUActivity_1D(imgs, mu, t)
    nHidden = size(imgs,1);
    nInput  = size(imgs,2);
    
    imagesc(imgs, [0 1]); 
    hold on; 
    plot(mu,1:nHidden,'y*');
    set(gca,'ytick',unique([1 5:5:nHidden nHidden]));
    set(gca,'xtick',unique([1 5:5:nInput  nInput]));
    xlabel('Input unit #'); ylabel('Hidden unit #');
    
    mfe_suptitle(t);

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUActivity_Instance1D(model)
  % 1d plot
    fig = guru_newFig('hu-activity-inst', 'hu', model.nHidden, model.nInput);

  % 1d plot
    C = (w ~= 0);
    
    % For each hidden node,
    img = zeros(nHidden, nInput);
    for i=1:nHidden

      % Set the input to have only that node on
      X = zeros(nHidden, 1);
      X(i) = 1;
      Y = zeros(nInput, 1);
      
      % Propagate the activation
      [err,grad,out]=emo_backprop(X, Y, w, C, 3, 1 ); %constants are dummies
      
      img(i,:) = out(nHidden+1:end)-0.5;
    end;

    [junk, mu] = de_connector(models(1));
    model = de_LoadProps(model, 'ac', 'Weights');
    
    de_PlotHUActivity_1D( ...
        model.ac.Weights(model.nInput+1:end,model.nInput+1:end), ...
        model.nInput, ...
        model.nHidden, ...
        mu, ...
        sprintf('Instance activations plot, o=%4.1f', model.sigma) ...
      );
      

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUActivity_Average1D(models, mu)
  % 1d plot
    fig = guru_newFig('hu-activity-avg', 'hu', models(1).nHidden, models(1).nInput);

    [junk, mu] = de_connector(models(1));
    models = de_LoadProps(models, 'ac', 'Weights');
    
    % Plot the connectivity pattern
    ac = [models.ac];
    
    de_PlotHUActivity_1D( ...
        c, mu, ...
        models(1).nInput, ...
        models(1).nHidden, ...
        sprintf('Average activations plot, o=%4.1f', models(1).sigma) ...
      );

      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_PlotHUActivity_2D(imgs, mu, t)
  %2d plot
  % c is [nHidden x imgHeight x imgWidth]
  
    nHidden = size(imgs,1);
    inPix = [size(imgs,2) size(imgs,3)];
    [cy,cx] = find(mu);
    hpl     = nHidden / length(cx);
    
    [nRows,nCols] = guru_optSubplots(nHidden);
    for i=1:length(cx)
      for j=1:hpl
        hu = (j-1)*length(cx)+i;
        
        % Plot the connectivity pattern
        subplot(nRows, nCols, hu);
        colormap(gray);
        %keyboard
        imagesc(squeeze(imgs(hu,:,:)));%, [-0.5 0.5]);
        set(gca,'ytick',[], 'xtick', []);
        %hold on;
        %plot(cx(i), cy(i), '*g');
      end;    
    end;
    
    mfe_suptitle(t);
    

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUActivity_Instance2D(model)
  %2d plot
    fig = guru_newFig('hu-activity-inst', 'hu', model.nHidden, model.nInput);
        

    [junk, hpl, mu] = de_connector(model);
    
    % For each hidden node,
    imgs = zeros([model.nHidden, model.nInput]);
    model = de_LoadProps(model, 'ac', 'Weights');
    for hu=1:model.nHidden
      inPix = prod(model.nInput);
      X = zeros(model.nHidden, 1);
      X(hu) = 1;       % Set the input to have only that node on
      Y = zeros(inPix, 1);
      W = model.ac.Weights( inPix+1:end, inPix+1:end );
      
      % Propagate the activation
      [err,grad,out]=emo_backprop(X, Y, W, (W~=0), model.ac.XferFn, 1 ); %constants are dummies
    
      imgs(hu,:,:) = reshape(out((model.nHidden+1):end), model.nInput);
    end;
    
    imgs = imgs - 0.5;
    
    de_PlotHUActivity_2D( imgs, mu, sprintf('Instance hu activity plot, o=%4.1f', model.sigma));

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotHUActivity_Average2D(models)
  %2d plot
    fig = guru_newFig('hu-activity-avg', 'hu', models(1).nHidden, models(1).nInput);

    [junk, hpl, mu] = de_connector(models(1));
    
    % For each hidden node,
    imgs = zeros([models(1).nHidden, models(1).nInput]);

    for i=1:length(models)
      model = de_LoadProps(models(i), 'ac', 'Weights');

      fprintf( '%d ', i);

      for hu=1:model.nHidden
        inPix = prod(model.nInput);
        X = zeros(model.nHidden, 1);
        X(hu) = 1;       % Set the input to have only that node on
        Y = zeros(inPix, 1);
        W = model.ac.Weights( inPix+1:end, inPix+1:end );
        
        % Propagate the activation
        [err,grad,out]=emo_backprop(X, Y, W, (W~=0), model.ac.XferFn, 1 ); %constants are dummies
      
        imgs(hu,:,:) = reshape(out((model.nHidden+1):end), model.nInput) / length(models);
      end;
    end;
    
    imgs = imgs - 0.5;
    
    de_PlotHUActivity_2D( imgs, mu, sprintf('Average hu activity plot, o=%4.1f', models(1).sigma));
