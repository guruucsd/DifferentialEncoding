  function de_SaveSummaryInfo(fn, mSets, stats)
  %
  %
    [fh, fmsg] = fopen(fn, 'w');
    fprintf(fh, 'Differential Encoder: %dD\n', length(mSets.nInput));

    fprintf(fh, '\tRuns:       %-4d\n',   mSets.runs);
    fprintf(fh, '\tDist''n: %10s\n',      guru_cell2str(mSets.distn));
    fprintf(fh, '\tMu:         %-4.1f\n', mSets.mu);
    fprintf(fh, '\tSigma:      %-4.1f\n', mSets.sigma);
    fprintf(fh, '\tnConns:     %-4d\n',   mSets.nConns);
    fprintf(fh, '\tnHidden:    %-4d\n',   mSets.nHidden);
    fprintf(fh, '\tnHd-Per-Lyr:%-4d\n',   mSets.hpl);
    fprintf(fh, '\n');
    fprintf(fh, '\tError Type: %d\n',     mSets.errorType);
    fprintf(fh, '\tData File:  %s\n',     mSets.dataFile);
    fprintf(fh, '\n\n');

    fprintf(fh, 'AutoEncoder:\n');
    fprintf(fh, '\tRandState:      %-5d\n',   mSets.ac.randState);
    fprintf(fh, '\tTolerance:      %-5.4f\n', mSets.ac.tol);
    fprintf(fh, '\tAvgError:       %-5.4f\n', mSets.ac.AvgError);
    fprintf(fh, '\tMaxIterations:  %-5d\n',   mSets.ac.MaxIterations);
    fprintf(fh, '\tTrainMode:      %s\n',     mSets.ac.TrainMode);
    fprintf(fh, '\tEtaInit:        %-5.4f\n', mSets.ac.EtaInit);
    fprintf(fh, '\tAcc:            %-5.4f\n', mSets.ac.Acc);
    fprintf(fh, '\tDec:            %-5.4f\n', mSets.ac.Dec);
    fprintf(fh, '\tXferFn          %-5d\n',   mSets.ac.XferFn);
    fprintf(fh, '\tUseBias:        %-5d\n',   mSets.ac.useBias);
    fprintf(fh, '\tGrad Power:     %-5d\n',   mSets.ac.Pow);
    fprintf(fh, '\tLambda (wt dcy):%-5d\n',   mSets.ac.lambda);
    fprintf(fh, '\tWeightInitType: %s\n',     mSets.ac.WeightInitType);
    fprintf(fh, '\tNoise_input:    %f\n',     mSets.ac.noise_input);
    fprintf(fh, '\n\n');

    if (isfield(mSets, 'p'))
        fprintf(fh, 'Perceptron:\n');
        fprintf(fh, '\tnHidden:        %-5d\n',   mSets.p.nHidden);
        fprintf(fh, '\tRandState:      %-5d\n',   mSets.p.randState);
        fprintf(fh, '\tAvgError:       %-5.4f\n', mSets.p.AvgError);
        fprintf(fh, '\tMaxIterations:  %-5d\n',   mSets.p.MaxIterations);
        fprintf(fh, '\tTrainMode:      %s\n',     mSets.p.TrainMode);
        fprintf(fh, '\tEtaInit:        %-5.4f\n', mSets.p.EtaInit);
        fprintf(fh, '\tAcc:            %-5.4f\n', mSets.p.Acc);
        fprintf(fh, '\tDec:            %-5.4f\n', mSets.p.Dec);
        fprintf(fh, '\tXferFn          %-5d\n',   mSets.p.XferFn);
        fprintf(fh, '\tUseBias:        %-5d\n',   mSets.p.useBias);
        fprintf(fh, '\tGrad Power:     %-5d\n',   mSets.p.Pow);
        fprintf(fh, '\tLambda (wt dcy):%-5d\n',   mSets.p.lambda);
        fprintf(fh, '\tWeightInitType: %s\n',     mSets.p.WeightInitType);
        fprintf(fh, '\tNoise_input:    %f\n',     mSets.p.noise_input);
        fprintf(fh, '\n\n');
    end;

    fprintf(fh, 'Analysis:\n');
    fprintf(fh, '\tac Rejection Props: %10s\n', mSets.ac.rej.props{:});
    fprintf(fh, '\tac Rejection Width: %5.4f\n', mSets.ac.rej.width(:));
    fprintf(fh, '\tac Rejection Type:  %s\n',    mSets.ac.rej.type{:});
    if (isfield(mSets, 'p'))
        fprintf(fh, '\tp  Rejection Props: %5.4s\n', mSets.p.rej.props{:});
        fprintf(fh, '\tp  Rejection Width: %5.4f\n', mSets.p.rej.width(:));
        fprintf(fh, '\tp  Rejection Type:  %s\n',    mSets.p.rej.type{:});
        fprintf(fh, '\n\n');
    end;

    % count rejections
    rcounts = [];
    if (isfield(stats.raw, 'r')),
        for i=1:length(stats.raw.r), rcounts(end+1) = length(find(stats.raw.r{i})); end;
    end;

    fprintf(fh, 'Summary:\n');
    fprintf(fh, '\tRejections (ordered by Sigma): %d\n', rcounts(:));
%    if (isfield(mSets.data, 'TLBL'))
%        fprintf(fh, '\n');
%        for i=1:length(mSets.data.TLBL)
%          fprintf(fh, '\tRAW %s: %s\n', mSets.data.TLBL{i}, sprintf('%5.4e\t', stats.raw.basics.bars(i,:)));
%        end;
%        fprintf(fh, '\n');
%        for i=1:length(mSets.data.TLBL)
%          fprintf(fh, '\tREJ %s: %s\n', mSets.data.TLBL{i}, sprintf('%5.4e\t', stats.rej.basics.bars(i,:)));
%        end;
%    end;
    fprintf(fh, '\n\n');

    fclose(fh);

