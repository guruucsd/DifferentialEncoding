function huencs = de_StatsHUEncodings(mss, dset)
%
% For a given input, get the hidden unit encodings

  if (isempty(mss) || isempty(mss{1}))
      huencs = [];
      return;
  end;
  mSets = mss{1}(1);
  nHUs = (mSets.nHidden/mSets.hpl);
  selectedHUs = 1:nHUs; % get one full layer of hidden units
  %[selectedHUs,    nHUs]    = de_SelectHUs(selectedHUs); % this turns out to be a global assignment
  [selectedImages, nImages] = de_SelectImages(dset);

  huencs = cell(size(mss));
  for i=1:length(mss)
    huencs{i} = zeros(length(mss{i}), nHUs, nImages); %

    for j=1:length(mss{i})
      fprintf( '%d ', j);

      model = mss{i}(j);

      % Four ways we can get the hidden unit encodings:
      % 1. Find them pasted on the model (model.ac.hu)
      % 2. Load them from a file (de_GetOutFile(model,'ac.hu'))
      % 3. Find weights pasted on the model (model.ac.Weights) and calculate them.
      % 4. Load the weights from a file and calculate them

      % Disabled, seems broken
      if (false && isfield(model.ac, 'hu'))
          huencs{i}(j, :, :) = reshape(model.ac.hu(selectedHUs, :), [1 nHUs nImages]);

      % Disabled, seems broken
      elseif (false && exist(de_GetOutFile(model,'ac.hu'), 'file'))
          hu = load(de_GetOutFile(model,'ac.hu'), 'hu');
          if (isfield(hu.hu,'test')), hu = hu.hu.test;
          else,                       hu = hu.hu.train; end;
          huencs{i}(j, :, :) = reshape(hu(selectedHUs, :), [1 nHUs nImages]);

      elseif (isfield(model.ac, 'Weights'))
          [~,~,encs]       = guru_nnExec(model.ac, dset.X(:,selectedImages), dset.X(1:end-1,selectedImages));           % Produce hidden unit activations
          huencs{i}(j,:,:) = reshape(encs(selectedHUs,:), [1 nHUs nImages]);

      else
          model            = de_LoadProps(mss{i}(j), 'ac', 'Weights');
          [~,~,encs]       = guru_nnExec(model.ac, dset.X(:,selectedImages), dset.X(1:end-1,selectedImages));           % Produce hidden unit activations
          huencs{i}(j,:,:) = reshape(encs(selectedHUs,:), [1 nHUs nImages]);
      end;

    end;
    fprintf('\t');
  end;
