  function de_SaveSummaryInfo(fn, mSets, stats)
  %
  %
    [fh, fmsg] = fopen(fn, 'w');
    fprintf(fh, 'Differential Encoder: %dD\n', length(mSets.nInput));
    
    fprintf(fh, '\tRuns:       %-4d\n',   mSets.runs);
    fprintf(fh, '\tSigma:      %-4.1f\n', mSets.sigma);
    fprintf(fh, '\tnConns:     %-4d\n',   mSets.nConns);
    fprintf(fh, '\tnHidden:    %-4d\n',   mSets.nHidden);
    fprintf(fh, '\n');
    fprintf(fh, '\tError Type: %d\n',     mSets.errorType);
    fprintf(fh, '\tData File:  %s\n',     mSets.dataFile);
    fprintf(fh, '\n\n');
    
    fprintf(fh, 'AutoEncoder:\n');
    fprintf(fh, '\tRandState:      %-5d\n',   mSets.ac.randState);
    fprintf(fh, '\tAvgError:       %-5.4f\n', mSets.ac.AvgError);
    fprintf(fh, '\tMaxIterations:  %-5d\n',   mSets.ac.MaxIterations);
    fprintf(fh, '\tAcc:            %-5.4f\n', mSets.ac.Acc);
    fprintf(fh, '\tDec:            %-5.4f\n', mSets.ac.Dec);
    fprintf(fh, '\tEtaInit:        %-5.4f\n', mSets.ac.EtaInit);
    fprintf(fh, '\tWeightInitType: %s\n',     mSets.ac.WeightInitType);
    fprintf(fh, '\n\n');
    
    if (isfield(mSets, 'p'))
        fprintf(fh, 'Perceptron:\n');
        fprintf(fh, '\tRandState:      %-5d\n',   mSets.p.randState);
        fprintf(fh, '\tAvgError:       %-5.4f\n', mSets.p.AvgError);
        fprintf(fh, '\tMaxIterations:  %-5d\n',   mSets.p.MaxIterations);
        fprintf(fh, '\tAcc:            %-5.4f\n', mSets.p.Acc);
        fprintf(fh, '\tDec:            %-5.4f\n', mSets.p.Dec);
        fprintf(fh, '\tEtaInit:        %-5.4f\n', mSets.p.EtaInit);
        fprintf(fh, '\tWeightInitType: %s\n',     mSets.p.WeightInitType);
        fprintf(fh, '\n\n');
    end;

    fprintf(fh, 'Analysis:\n');
    fprintf(fh, '\tRejection Width: %5.4f\n', mSets.rej.width(:));
    fprintf(fh, '\tRejection Type:  %s\n',    mSets.rej.type{:});
    fprintf(fh, '\n\n');
    
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
    