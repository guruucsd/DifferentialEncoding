function [rho,pval] = de_StatsVsHuman(mSets, LS)
%function [rho,pval] = de_StatsVsHuman(mSets, LS)
%

  % Make sure we have RH vs LH
  guru_assert(length(mSets.sigma)==2);

  % Define human data
  humanRTs = zeros(6,2); %6 condition, 2 visual fields
  [ss,ssIdx] = sort(mSets.sigma);
  lvfIdx = ssIdx(1); %rh = small sigma
  rvfIdx = ssIdx(2); %lh = large sigma

  humanRTs(mSets.data.LpSpID,  lvfIdx) = 519;
  humanRTs(mSets.data.LpSpID,  rvfIdx) = 536;
  humanRTs(mSets.data.LpSpNID, lvfIdx) = 547;
  humanRTs(mSets.data.LpSpNID, rvfIdx) = 579;
  humanRTs(mSets.data.LpSm,    lvfIdx) = 547;
  humanRTs(mSets.data.LpSm,    rvfIdx) = 610;
  humanRTs(mSets.data.LmSp,    lvfIdx) = 625;
  humanRTs(mSets.data.LmSp,    rvfIdx) = 594;
  humanRTs(mSets.data.LmSmID,  lvfIdx) = 639;
  humanRTs(mSets.data.LmSmID,  rvfIdx) = 623;
  humanRTs(mSets.data.LmSmNID, lvfIdx) = 668;
  humanRTs(mSets.data.LmSmNID, rvfIdx) = 650;

  % Group the experiment data
  ls = zeros(size(humanRTs));
  for ss=1:length(mSets.sigma)
    ls(:,ss) = mean(LS{ss}(:, [mSets.data.LpSpID mSets.data.LpSpNID mSets.data.LpSm mSets.data.LmSp mSets.data.LmSmID mSets.data.LmSmNID]),1);
  end;

  % Calculate the correlation in the desired conditions
  conds = [mSets.data.LpSm mSets.data.LmSp];
  sz    = [length(conds)*length(mSets.sigma) 1];
  [rho,pval] = corr(reshape(ls(conds,:), sz), reshape(humanRTs(conds,:), sz));

%  for ss=1:length(mSets.sigma)
%
%    % Normalize ls and human data
%    ls(conds) = ls(conds)
%    coefficient(ss) = (ls*humanRTs(:,ss)) / (norm(humanRTs(:,ss)) * norm(ls));
%      end;

