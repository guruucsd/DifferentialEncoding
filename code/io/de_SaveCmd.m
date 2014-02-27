  function de_SaveCmd(fn, mSets)
  %
  %
    [fh, fmsg] = fopen(fn, 'w');

    fprintf(fh, 'de_Simulator(');

    % Required arguments
    fprintf(fh, '%d',            mSets.data.dim);
    fprintf(fh, ', ''%s''',      mSets.data.stimSet);
    fprintf(fh, ', ''%s''',      mSets.data.taskType);
    fprintf(fh, ', %s',          guru_cell2str(mSets.data.opt));

    % Optional arguments: model
    fprintf(fh, ', ...\n\t''runs'',               %d',     mSets.runs);
    fprintf(fh, ', ...\n\t''sigma'',             [%s]',   sprintf(' %d', mSets.sigma(:)));
    fprintf(fh, ', ...\n\t''deType'',            ''%s''', mSets.deType);
    fprintf(fh, ', ...\n\t''nHidden'',           %d', mSets.nHidden);
    fprintf(fh, ', ...\n\t''nConns'',            %d', mSets.nConns);
    fprintf(fh, ', ...\n\t''debug'',             %d', mSets.debug);

    fprintf(fh, ', ...\n\t''dataFile'',          ''%s''', mSets.dataFile);
    fprintf(fh, ', ...\n\t''randState'',         %d',     mSets.randState);


    % Optional arguments: ac
    fprintf(fh, ', ...\n\t''ac.AvgError'',       %f',     mSets.ac.AvgError);
    fprintf(fh, ', ...\n\t''ac.MaxIterations'',  %d',     mSets.ac.MaxIterations);
    fprintf(fh, ', ...\n\t''ac.Acc'',            %f',     mSets.ac.Acc);
    fprintf(fh, ', ...\n\t''ac.Dec'',            %f',     mSets.ac.Dec);
    fprintf(fh, ', ...\n\t''ac.EtaInit'',        %f',     mSets.ac.EtaInit);
    fprintf(fh, ', ...\n\t''ac.errorType'',      %d',     mSets.ac.errorType);
    fprintf(fh, ', ...\n\t''ac.XferFn'',         %d',     mSets.ac.XferFn);
    fprintf(fh, ', ...\n\t''ac.WeightInitType'', ''%s''', mSets.ac.WeightInitType);
    fprintf(fh, ', ...\n\t''ac.debug'',          [%s]',   sprintf(' %d', mSets.ac.debug(:)));

    % Optional arguments: p
    fprintf(fh, ', ...\n\t''p.AvgError'',       %f',     mSets.p.AvgError);
    fprintf(fh, ', ...\n\t''p.MaxIterations'',  %d',     mSets.p.MaxIterations);
    fprintf(fh, ', ...\n\t''p.Acc'',            %f',     mSets.p.Acc);
    fprintf(fh, ', ...\n\t''p.Dec'',            %f',     mSets.p.Dec);
    fprintf(fh, ', ...\n\t''p.EtaInit'',        %f',     mSets.p.EtaInit);
    fprintf(fh, ', ...\n\t''p.errorType'',      %d',     mSets.p.errorType);
    fprintf(fh, ', ...\n\t''p.XferFn'',         %d',     mSets.p.XferFn);
    fprintf(fh, ', ...\n\t''p.WeightInitType'', ''%s''', mSets.p.WeightInitType);
    fprintf(fh, ', ...\n\t''p.debug'',          [%s]',   sprintf(' %d', mSets.p.debug(:)));

    % Analysis parameters
    fprintf(fh, ', ...\n\t''errorType'',        %d',     mSets.errorType);
    fprintf(fh, ', ...\n\t''rej.type'',         %s',     guru_cell2str(mSets.rej.types));
    fprintf(fh, ', ...\n\t''rej.width'',        [%s]',   sprintf(' %d', mSets.rej.width(:)));

    fprintf(fh, ', ...\n\t''plots'',            %s',     guru_cell2str(mSets.plots));
    fprintf(fh, ', ...\n\t''stats'',            %s',     guru_cell2str(mSets.stats));

    % Reporting results
    fprintf(fh, ', ...\n\t''out.data'',         %s',     guru_cell2str(mSets.out.data));
    fprintf(fh, ', ...\n\t''out.stem'',         ''%s''', mSets.out.stem);


    fprintf(fh, ' ...\n);');
    fclose(fh);