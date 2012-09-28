function [selectedHUs, nHUs] = de_SelectHUs(mSets, nHUs)
%
%   mSets - settings that we use to determine some random # of hidden units to select

  global selectedHUs_;

  if (~exist('mSets','var'))
      % Nothing to be done but to return cached(global) values

  else
      if (~exist('nHUs', 'var')), nHUs = 20; end;

      if (isempty(selectedHUs_) || (max(selectedHUs_)>mSets.nHidden)) %so that all reproductions use the same set
          selectedHUs_   = randperm(mSets.nHidden); %so that we get to see a variety
          selectedHUs_   = sort(selectedHUs_(1:nHUs))
      end;
  end;

  selectedHUs = selectedHUs_;
  nHUs = length(selectedHUs); % # HUs we got
