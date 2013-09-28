function out_images = de_StatsHUOutputs(mss, dset)
%
% For a single hidden unit, activate it and show the output image

  if (isempty(mss) || isempty(mss{1}))
      out_images = [];
      return;
  end;
  [selectedHUs, nHUs] = de_SelectHUs(mss{1}(1)); % get a random set of HUs

  out_imgs = cell(size(mss));
  for i=1:length(mss)
    out_images{i} = zeros([length(mss{i}), nHUs, mss{i}(1).nInput]);

    for j=1:length(mss{i})
      fprintf( '%d ', j);

      % We're going to run a (2-layer) perceptron;
      %   Input is the hidden unit activities (a single unit on, plus possibly a bias)
      %   Output is the output image.
      model = mss{i}(j);
      if (~isfield(model.ac, 'Weights'))
          model   = de_LoadProps(model, 'ac', 'Weights');
      end;

      inPix   = prod(model.nInput);
      W       = model.ac.Weights( (inPix+1):end, (inPix+1):end ); % remove inputs, keep hu->output connections
      C       = (W~=0);
      Y_dummy = zeros(inPix,1);

      % Produce output images from single hidden unit activations
      error('This function must be migrated to either use guru_nnExec, or to use its logic for setting up the transfer functions appropriately')
      for hu=1:nHUs
        X                             = zeros(1+model.nHidden, 1);
        if (model.ac.useBias), X(1,:) = dset.bias; end; % set bias input
        X(selectedHUs(hu))            = min(emo_trnsfr(model.ac.XferFn,inf), 100); % Turn only this hu on, at max.  NOTE that this will be weird if we're using linear units, so I've done some artificial min ...

        % Propagate the activation
        [~,~,out_act] = emo_backprop(X, Y_dummy, W, C, model.ac.XferFn ); %expected output (Y_dummy) doesn't matter, as we don't use the "error"
        out_act       = out_act((model.nHidden+2):end,:);
        out_images{i}(j,hu,:,:) = reshape(out_act, model.nInput);

        clear('out_act');
      end;
    end;

    fprintf('\t');
  end;
