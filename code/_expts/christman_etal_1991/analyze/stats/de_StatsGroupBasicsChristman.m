function stats = de_StatsGroupBasicsKit( mSets, ms, ss )

  dss = {'train','test'};
  for dsi=1:length(dss)
      ds = dss{dsi};

      %%%%%%%%
      % Must match # of instances across both experiments
      %%%%%%%%

      % Find # instances to use
      nInstL = [ size(ss.low_freq.rej.sf.rej.basics.perf.(ds){1},1), ...
                 size(ss.low_freq.rej.sf.rej.basics.perf.(ds){2},1) ];
      nInstH = [ size(ss.high_freq.rej.sf.rej.basics.perf.(ds){1},1), ...
                 size(ss.high_freq.rej.sf.rej.basics.perf.(ds){2},1) ];
      nInst  = min([nInstL nInstH]);

      % Extract indices of data for expt 1
      idxL_old = mod(ss.low_freq.rej.sf.rej.basics.anova.(ds).S_n-1, max(nInstL))+1;
      idxL_cur = (idxL_old <= nInst);

      % Extract indices of data for expt 2
      idxH_old = mod(ss.high_freq.rej.sf.rej.basics.anova.(ds).S_n-1, max(nInstH))+1;
      idxH_cur = (idxH_old <= nInst);

      %%%%%%%%
      % Select out data and construct data table
      %
      % Rows: hemisphere
      % Columns: stim set
      % Repeats: model instances
      %
      % So this means that if each hemisphere has N instances,
      %   rows 1:N    = RH
      %   rows N+1:2N = LH
      %
      % Col 1: low freq
      % Col 2: high freq
      %%%%%%%%

      % Get indices of hemispheres
      hemiL = ss.low_freq.rej.sf.rej.basics.anova.(ds).F1_n(idxL_cur);
      hemiH = ss.high_freq.rej.sf.rej.basics.anova.(ds).F1_n(idxH_cur);

      % Sort into LH and RH
      [hemi_srtL, srtidxL] = sort(hemiL);
      [hemi_srtH, srtidxH] = sort(hemiH);

      % Select data
      XL = ss.low_freq.rej.sf.rej.basics.anova.(ds).Y(idxL_cur);
      XH = ss.high_freq.rej.sf.rej.basics.anova.(ds).Y(idxH_cur);

      % Sort by hemispheres
      XL_srt = XL(srtidxL);
      XH_srt = XH(srtidxH);

      % Cobble together data matrix
      nRepeats = nInst*2; % factor of 2 is because there are 2 conditions per expt
      X = [ XL_srt(1:nRepeats)       XH_srt(1:nRepeats);
            XL_srt((nRepeats+1):end) XH_srt((nRepeats+1):end) ];


      % Run the stats
      stats.anova.(ds).X = X;
      stats.anova.(ds).nRepeats = nRepeats;
      [p,t,s] = anova2(stats.anova.(ds).X, stats.anova.(ds).nRepeats);

      % Add labels
      t{2,1} = 'hemi'; % rows label
      t{3,1} = 'stimset'; % cols label
      t{4,1} = [t{2,1} ' x ' t{3,1}]; % interaction label

      % Save off the results
      stats.anova.(ds).table = t;
      stats.anova.(ds).stats = s;

      % Print the table of results
      fprintf('\n\nGroup analysis [%s]:\n', ds);
      stats.anova.(ds).table
  end;