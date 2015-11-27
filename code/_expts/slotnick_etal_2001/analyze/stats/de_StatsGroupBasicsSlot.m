function stats = de_StatsGroupBasicsSlot( mSets, ms, ss )

dss = {'train','test'};
for dsi=1:length(dss)
    ds = dss{dsi};
    
    
    %%%%%%%%
    % Must match # of instances across both experiments
    %%%%%%%%
    cate = ss.cate.rej.cc;
    coord = ss.coor.rej.cc;
    % Find # instances to use
    nInstCate = [ size(cate.perf.(ds){1}{1},1), ...
        size(cate.perf.(ds){end}{1},1) ];
    nInstCoord = [ size(coord.perf.(ds){1}{1},1), ...
        size(coord.perf.(ds){end}{1},1) ];
    nInst  = min([nInstCate nInstCoord]);
    
    % Extract indices of data for expt 1
    index_range_cat = [1:nInst, nInstCate(1)+[1:nInst]]; %range of models #s to keep
    [~,index_cat] = intersect(cate.anova.(ds).S_n, index_range_cat); %get the indices of those models
    
    % Extract indices of data for expt 2
    index_range_coord = [1:nInst, nInstCoord(1)+[1:nInst]];
    [~,index_coor] = intersect(coord.anova.(ds).S_n, index_range_coord);

    
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
    % Col 1: Cat task
    % Col 2: Coor task
    %%%%%%%%
    
    % Get indices of hemispheres
    hemiCat = cate.anova.(ds).F1_n(index_cat);
    hemiCoor = coord.anova.(ds).F1_n(index_coor);
    
    % Sort into LH and RH
    [~, srtidxCat] = sort(hemiCat);
    [~, srtidxCoor] = sort(hemiCoor);
    
    % Select data
    YCAT = cate.anova.(ds).Y(index_cat, :);
    YCAT = mean(YCAT, 2); %average over trial type
    YCOOR = coord.anova.(ds).Y(index_coor, :);
    YCOOR = mean (YCOOR, 2); %average over trial type
    
    % Sort by hemispheres
    YCAT_srt = YCAT(srtidxCat);
    YCOOR_srt = YCOOR(srtidxCoor);
    
    % Cobble together data matrix
    Y = [ YCAT_srt(1:nInst);       YCOOR_srt(1:nInst);
          YCAT_srt((nInst+1):end); YCOOR_srt((nInst+1):end) ];
    
    hemis = [ones(nInst*2, 1); 2*ones(nInst*2, 1)]; 
    trial_types = [ones(nInst, 1); 2*ones(nInst,1); ones(nInst, 1); 2*ones(nInst,1)];
      
    % Run the stats
    stats.anova.(ds).Y = Y;
    stats.anova.(ds).hemis = hemis;
    stats.anova.(ds).trial_types = trial_types;
    [~,t,s,~] = anovan(Y, {hemis, trial_types}, 'display', 'off', 'model', 'full');
    
    % Add labels
    t{2,1} = 'hemi'; % rows label
    t{3,1} = 'task'; % cols label
    t{4,1} = [t{2,1} ' x ' t{3,1}]; % interaction label
    
    t = t(:, [1:3, 5:end]); % remove column for "Singular?"
    % Save off the results
    stats.anova.(ds).table = t;
    stats.anova.(ds).stats = s;
    
    % Print the table of results
    fprintf('\n\nGroup analysis [%s]:\n', ds);
    stats.anova.(ds).table
end;
