% # sizes of hidden layers
%[68 50], [48 35], [34 25]
%[68 50], [34 25], [24 18] % factor of 2 (1/4 units), sqrt(2) (1/2 units)

sizes = [34 25; 24 18];


% Go from big to small
for si=2:size(sizes,1)
  %% Step 1: train the network with the added layer
  nInput = sizes(si-1,:);
  nHidden = 0;
  nOutput = sizes(si);

  % create separate datasets, and combine
  [trn,tst] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'nInput', nInput});
  [trn,tst] = de_MakeDataset('sergent_1982', 'sergent_1982', 'sergent', {'nInput', nOutput});

  %% Step 2: get the encodings for the hidden layer

  % Create model
  model.nInput = nInput;
  model.nHidden =
  model.nOutput =
  model.Weights =


end;


% Go from small to big
for si=size(sizes,1)-1:-1:1

  %% Step 1: train the network with the added layer

  %% Step 2: get the outputs for the current layer; they're the inputs for the next loop

end;


% Now, get all weights together, and train the network fully


% Finally, analyze the output images

