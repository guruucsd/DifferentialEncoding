function [stats, figs]  = de_Analyzer(mSets, mss)
%function [stats, figs]  = de_Analyzer(mSets, mss)
%
% Trains a differential encoder under the model and training parameters specified
%
% Inputs:
% models   : resulting models after training
%
% Outputs:
% stats      :
% figs       :

  % Get the hierarchical letters
  sergent_dir = fileparts(strrep(which(mfilename), 'lamb_yund_2000', 'sergent_1982'));
  addpath(genpath(sergent_dir));
  [stats, figs] = de_Analyzer(mSets, mss)
  rmpath(genpath(sergent_dir));

