function stats = de_StatsGroupBasicsKit( mSets, ms, ss )

  dss = {'train','test'};
  for dsi=1:length(dss)
      ds = dss{dsi};


      %%%%%%%%
      % Must match # of instances across both experiments
      %%%%%%%%

      % Find # instances to use
      nInstF = [ size(ss.freq.rej.sf.rej.basics.perf.(ds){1},1), ...
                 size(ss.freq.rej.sf.rej.basics.perf.(ds){2},1) ];
      nInstT = [ size(ss.type.rej.sf.rej.basics.perf.(ds){1},1), ...
                 size(ss.type.rej.sf.rej.basics.perf.(ds){2},1) ];
      nInst  = min([nInstF nInstT]);

      % Extract indices of data for expt 1
      idxF_old = mod(ss.freq.rej.sf.rej.basics.anova.(ds).S_n-1, max(nInstF))+1;
      idxF_cur = (idxF_old <= nInst);

      % Extract indices of data for expt 2
      idxT_old = mod(ss.type.rej.sf.rej.basics.anova.(ds).S_n-1, max(nInstT))+1;
      idxT_cur = (idxT_old <= nInst);

      %%%%%%%%
      % Select out data and construct data table
      %
      % Rows: hemisphere
      % Columns: task
      % Repeats: model instances
      %
      % So this means that if each hemisphere has N instances,
      %   rows 1:N    = RH
      %   rows N+1:2N = LH
      %
      % Col 1: freq task
      % Col 2: type task
      %%%%%%%%

      % Get indices of hemispheres
      hemiF = ss.freq.rej.sf.rej.basics.anova.(ds).F1_n(idxF_cur);
      hemiT = ss.type.rej.sf.rej.basics.anova.(ds).F1_n(idxT_cur);

      % Sort into LH and RH
      [hemi_srtF, srtidxF] = sort(hemiF);
      [hemi_srtT, srtidxT] = sort(hemiT);

      % Select data
      XF = ss.freq.rej.sf.rej.basics.anova.(ds).Y(idxF_cur);
      XT = ss.type.rej.sf.rej.basics.anova.(ds).Y(idxT_cur);

      % Sort by hemispheres
      XF_srt = XF(srtidxF);
      XT_srt = XT(srtidxT);

      % Cobble together data matrix
      nRepeats = nInst*2; % factor of 2 is because there are 2 conditions per expt
      X = [ XF_srt(1:nRepeats)       XT_srt(1:nRepeats);
            XF_srt((nRepeats+1):end) XT_srt((nRepeats+1):end) ];


      % Run the stats
      stats.anova.(ds).X = X;
      stats.anova.(ds).nRepeats = nRepeats;
      [p,t,s] = anova2(stats.anova.(ds).X, stats.anova.(ds).nRepeats);

      % Add labels
      t{2,1} = 'hemi'; % rows label
      t{3,1} = 'task'; % cols label
      t{4,1} = [t{2,1} ' x ' t{3,1}]; % interaction label

      % Save off the results
      stats.anova.(ds).table = t;
      stats.anova.(ds).stats = s;

      % Print the table of results
      fprintf('\n\nGroup analysis [%s]:\n', ds);
      stats.anova.(ds).table
  end;