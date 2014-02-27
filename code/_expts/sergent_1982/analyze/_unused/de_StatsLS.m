function [err] = de_StatsLS(LS)
%function [err] = de_StatsLS(LS)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
%
% Output:
% err           :
% learningError :

  %--------------------------------------------------------------------------
  %Step 1: separate errors into 4 cell arrays

  %--------------------------------------------------------------------------
  for i=1:length(LS)
    %if (isempty(options))
    %  LS{i} = LS{i}./repmat(sum(LS{i},2),[1 4]);
    %end;
    err(:,i) = mean( LS{i}, 1 );
    %std(:,i) = std(LS{i});
  end;

