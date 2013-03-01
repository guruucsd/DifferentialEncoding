function [stats] = de_StatsDistributions(mss)
%
% Returns the distribution of weights and connections over all models within each sigma

  stats.weights_in  = cell(length(mss),1);
  stats.weights_out = cell(length(mss),1);
  stats.cxns_in     = cell(length(mss),1);
  stats.cxns_out    = cell(length(mss),1);

  for si=1:length(mss)
    if isempty(mss{si}), 
      continue;
    elseif ~exist('mSets','var')
      mSets = mss{si}(end);
      [~,mupos] = de_connector_positions(mSets.nInput, mSets.nHidden/mSets.hpl);
      mupos = round(mupos);
      midpt = mSets.nInput+1;
    end;

    nconn = mSets.nConns;
    nall = length(mss{si})*size(mupos,1)*nconn;
    nPix = prod(mSets.nInput);
    
    stats.weights_in{si}  = zeros(mSets.nInput*2);
    stats.weights_out{si} = zeros(mSets.nInput*2);
    stats.cxns_in{si}     = zeros(mSets.nInput*2);
    stats.cxns_out{si}    = zeros(mSets.nInput*2);

    for mi=1:length(mss{si})
      m = de_LoadProps(mss{si}(mi), 'ac', 'Weights');
      m.ac.Conn = (m.ac.Weights ~= 0);
      w_in2hid  = m.ac.Weights( (nPix+2):(nPix+1+m.nHidden), 1:nPix);
      w_hid2out = m.ac.Weights( (end-nPix+1):end, (nPix+2):(nPix+1+m.nHidden))';

      for hi=1:size(mupos,1)
        stats.weights_in{si}( [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.weights_in{si}( [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) + reshape(w_in2hid(hi,:),     mSets.nInput)/nall;

        stats.cxns_in{si}(    [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.cxns_in{si}(    [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) + reshape(w_in2hid(hi,:)~=0,  mSets.nInput)/nall;

        stats.weights_out{si}([midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.weights_out{si}([midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) + reshape(w_hid2out(hi,:),    mSets.nInput)/nall;
        stats.cxns_out{si}(   [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2)) = stats.cxns_out{si}(   [midpt(1):end]-mupos(hi,1), [midpt(2):end]-mupos(hi,2))  + reshape(w_hid2out(hi,:)~=0, mSets.nInput)/nall;
      end;
    end;
  end;
