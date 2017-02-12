function [stats] = de_StatsDistributions(mss)
%
% Returns the distribution of weights and connections over all models within each sigma

  stats.weights_in  = cell(length(mss),1);
  stats.weights_out = cell(length(mss),1);
  stats.cxns_in     = cell(length(mss),1);
  stats.cxns_out    = cell(length(mss),1);

  for si=1:length(mss)
    fprintf('\t%d: ', si);
    if isempty(mss{si}),
      continue;
    end;

    % Each model set can have a completely different configuration,
    %   so recompute everthing for each set.
    mSets = mss{si}(end);
    [~,mupos] = de_connector_positions(mSets.nInput, mSets.nHidden/mSets.hpl);
    mupos = round(mupos);
    midpt = mSets.nInput+1;

    nall = length(mss{si}) * mSets.nHidden * mSets.nConns;
    nPix = prod(mSets.nInput);

    stats.weights_in{si}  = zeros(mSets.nInput*2);
    stats.weights_out{si} = zeros(mSets.nInput*2);
    stats.cxns_in{si}     = zeros(mSets.nInput*2);
    stats.cxns_out{si}    = zeros(mSets.nInput*2);

    for mi=1:length(mss{si})
      fprintf('%d ', mi);

      m = de_LoadProps(mss{si}(mi), 'ac', 'Weights');
      w_in2hid  = m.ac.Weights( (nPix+2):(nPix+1+m.nHidden), 1:nPix);
      w_hid2out = m.ac.Weights( (end-nPix+1):end, (nPix+2):(nPix+1+m.nHidden))';

      for hpli=1:mSets.hpl
          for hi=1:size(mupos,1)
              hui = (hpli - 1) * size(mupos,1) + hi; % hidden unit index
              stats.weights_in{si}( [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.weights_in{si}( [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) + reshape(w_in2hid(hui,:),     mSets.nInput)/nall;
              stats.cxns_in{si}(    [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.cxns_in{si}(    [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) + reshape(w_in2hid(hui,:)~=0,  mSets.nInput)/nall;

              stats.weights_out{si}([midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.weights_out{si}([midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) + reshape(w_hid2out(hui,:),    mSets.nInput)/nall;
              stats.cxns_out{si}(   [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.cxns_out{si}(   [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2))  + reshape(w_hid2out(hui,:)~=0, mSets.nInput)/nall;
          end;
      end;
    end;
    fprintf('done.\n');
    %fprintf('Total connection weight (%d %d %d): %f\n', mSets.nHidden, mSets.hpl, mSets.nConns, sum(abs(stats.cxns_out{si}(:))));
  end;
