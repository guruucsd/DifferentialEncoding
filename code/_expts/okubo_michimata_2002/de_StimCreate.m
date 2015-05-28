function [train,test,aux] = de_StimCreate(stimSet, taskType, opt)
%
%Input:
%  stimSet  : a string specifying the (INPUT) image dataset. 
%               'dots' => the "dot" stimuli shown on the left of Figure 1.
%               'dots-cb' => the contrast balanced "dot" stimuli shown on the right of Figure 1. 
%
%  taskType : a string specifying the (OUTPUT) task.
%               'categorical' => whether the dots are above or below the line.
%               'coordinate' => how far the dots are from the line.
% 
%  opt      : a vector of options; all listed will be applied
%               (none used here)
%%
%OUTPUT: three variables, two with the same structure.
%
% train, test: training and test data sets, containing the following fields:
%    train.X    : matrix containing 16 vectors, each a unique hierarchical stimulus.
%    train.TT   : 16 indices, one for each hierarchical stimulus, taken from TALL
%    train.ST   : vector of 16 strings, describing each unique hierarchical stimulus.
%               Tells the two stimuli and relationship that make up the hierarchical stimulus
%    train.TIDX : ?
%
%    train.Y    : target vectors for the autoencoder (same as X)
%    train.T    : target vectors for the perceptron (labels, based on task)
%
%    test.*     : same as train object, but
%
% aux: generic structure for saving off experiment-specific data. Here, contains:
%    aux.idx : indexing of which trials correspond to local/global targets and distractors.
%    aux.TLBL : human-readable labels for each of the perceptron outputs.

  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  % Create the input images.
  heights = 2 * guru_getopt(opt, 'heights', [[0.5 1.0 1.5 2.5 3.0 3.5] -1*[0.5 1.0 1.5 2.5 3.0 3.5]]);
  train.nInput = [68 50];
  train.X = zeros(prod(train.nInput), 0);
  train.XLAB = guru_csprintf('height=%.2f', num2cell(heights));

  for h=heights
    img = create_cat_coord_stimuli(h);
    train.X(:, end+1) = img(:);%rd_stimuli(h);
  end;

  % Create the output vectors.
  if ~isempty(taskType)
    switch (taskType)
      case 'categorical', train.T = heights > 0;
      case 'coordinate', train.T = abs(heights);
      otherwise, error('Unknown taskType: %s', taskType);
    end;
  end;

  % Now say that test data is the same as training data.
  test     = train;
  aux.heights = heights;


function [ image ] = create_cat_coord_stimuli( height )
% Takes two parameters:
%   height (vertical displacement of 2 dots from middle 5), 
%   above (1 for true, 0 for false, i.e. below)
img_height = 50;
img_width = 68;
midline = img_height/2;
stimuli_mid = img_width/2;
five_stimuli_width = 44;
padding = 12;

image = ones(img_height, img_width);

% create the five stimuli, same on all images
for ii = 1:10:41
  image(midline, padding+ii) = 0;
  image(midline+1, padding+ii) = 0;
  image(midline, padding+ii+1) = 0;
  image(midline+1, padding+ii+1) = 0;
end

    height = height * -1;

% create the 2 stimuli based on the height

image(midline+height,29) = 0;
image(midline+height, 28) = 0;
image(midline+height+1, 29) = 0;
image(midline+height+1, 28) = 0;

image(midline+height, 39) = 0;
image(midline+height, 38) = 0;
image(midline+height+1, 39) = 0;
image(midline+height+1, 38) = 0;


