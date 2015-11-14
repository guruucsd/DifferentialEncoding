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
    nInstCate = [ size(cate.perf.(ds){1},1), ...
        size(cate.perf.(ds){end},1) ];
    nInstCoord = [ size(coord.perf.(ds){1},1), ...
        size(coord.perf.(ds){end},1) ];
    nInst  = min([nInstCate nInstCoord]);
    
    % Extract indices of data for expt 1
    idxCat_old = mod(cate.anova.(ds).S_n-1, max(nInstCate))+1;
    idxCat_cur = (idxCat_old <= nInst);
    
    % Extract indices of data for expt 2
    idxCoor_old = mod(coord.anova.(ds).S_n-1, max(nInstCoord))+1;
    idxCoor_cur = (idxCoor_old <= nInst);
    
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
    hemiCat = cate.anova.(ds).F1_n(idxCat_cur);
    hemiCoor = coord.anova.(ds).F1_n(idxCoor_cur);
    
    % Sort into LH and RH
    [~, srtidxCat] = sort(hemiCat);
    [~, srtidxCoor] = sort(hemiCoor);
    
    % Select data
    YCAT = cate.anova.(ds).Y(idxCat_cur);
    YCOOR = coord.anova.(ds).Y(idxCoor_cur);
    
    % Sort by hemispheres
    YCAT_srt = YCAT(srtidxCat);
    YCOOR_srt = YCOOR(srtidxCoor);
    
    % Cobble together data matrix
    nRepeats = nInst*2; % factor of 2 is because there are 2 conditions per expt
    % (nRepeats left in to match the Kitterle base file )
    Y = [ YCAT_srt(1:nRepeats)       YCOOR_srt(1:nRepeats);
          YCAT_srt((nRepeats+1):end) YCOOR_srt((nRepeats+1):end) ];
    
    
    % Run the stats
    stats.anova.(ds).Y = Y;
    stats.anova.(ds).nRepeats = nRepeats;
    [~,t,s] = anova2(stats.anova.(ds).Y, stats.anova.(ds).nRepeats);
    
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
