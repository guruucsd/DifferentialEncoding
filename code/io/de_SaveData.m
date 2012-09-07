function out = de_SaveData(modelSettings, models, stats)
%
%
  out = modelSettings.out;

  % Stamp the output files & paths 
  for i=1:length(out.data)
    switch(out.data{i})
    
      % Save all data to .mat 
      case 'mat'
        fprintf('Skipping saving of mat summary\n');
        continue;
        
        out.files{end+1} = de_getOutFile(modelSettings, 'data', '.mat', modelSettings.runs);%fullfile(out.datapath, [out.stem '.mat']);
        %out.files{end}   = guru_smartfn( out.files{end} );
        
        if (~exist(out.files{end}, 'file'))
          if (ismember(1,modelSettings.debug))
            fprintf('Saving all results to .mat: %s\n', out.files{end});
          end;
          
          de_SaveMat( out.files{end}, modelSettings, models, stats );
        end;
        
      % Save LS to csv for Janet
      case 'csv'
        out.files{end+1} = de_getOutFile(modelSettings, 'summary', '.csv', modelSettings.runs);%fullfile(out.datapath, [out.stem '.csv']);
        %out.files{end}   = guru_smartfn( out.files{end} );
         
        %if (~exist(out.files{end}, 'file'))
          if (ismember(1,modelSettings.debug))
            fprintf('Saving LS results to .csv: %s\n', out.files{end});
          end;

          sTitle = sprintf('%dD Network settings: o=%s nConns=%d nHidden=%d trials=%d\n', ...
                           length(modelSettings.nInput), ['[' sprintf('%4.1f ',modelSettings.sigma) ']'], ...
                           modelSettings.nConns, modelSettings.nHidden, modelSettings.runs);
          
          de_saveCSV2(out.files{end}, stats, ',', sTitle, modelSettings);
        %end;
        
      % Save run results to .txt
      case 'info'
        out.files{end+1} = de_getOutFile(modelSettings, 'summary', '.summary.txt', modelSettings.runs);%fullfile(out.datapath, [out.stem '.mat']);
        %out.files{end+1} = fullfile(out.resultspath, [out.stem '.summary.txt']);
        %out.files{end}   = guru_smartfn( out.files{end} );

        %if (~exist(out.files{end}, 'file'))
          if (ismember(1,modelSettings.debug))
            fprintf('Saving settings summary to .txt: %s\n', out.files{end});
          end;

          de_SaveSummaryInfo(out.files{end}, modelSettings, stats);
        %end;
        
      % Save run results to .txt
      case 'cmd'
        out.files{end+1} = de_getOutFile(modelSettings, 'data', 'summary', '-replicate.m', modelSettings.runs);%out.data{i});%fullfile(out.datapath, [out.stem '.mat']);
        %out.files{end+1} = fullfile(out.resultspath, [out.stem '-replicate.m']);
        %out.files{end}   = guru_smartfn( out.files{end} );

        %if (~exist(out.files{end}, 'file'))
          if (ismember(1,modelSettings.debug))
            fprintf('Saving re-run command to .m: %s\n', out.files{end});
          end;

          de_SaveCmd(out.files{end}, modelSettings);
        %end;
        
      end; %switch
    end; % for
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_SaveMat(fn, modelSettings, models, stats)
  %
  %  
    models = de_DECompress(models);
    save( fn, 'modelSettings', 'models', 'stats' );

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_SaveSummaryInfo(fn, modelSettings, stats)
  %
  %
    [fh, fmsg] = fopen(fn, 'w');
    fprintf(fh, 'Differential Encoder: %dD\n', length(modelSettings.nInput));
    
    fprintf(fh, '\tRuns:       %-4d\n',   modelSettings.runs);
    fprintf(fh, '\tSigma:      %-4.1f\n', modelSettings.sigma);
    fprintf(fh, '\tnConns:     %-4d\n',   modelSettings.nConns);
    fprintf(fh, '\tnHidden:    %-4d\n',   modelSettings.nHidden);
    fprintf(fh, '\n');
    fprintf(fh, '\tError Type: %d\n',     modelSettings.errorType);          
    fprintf(fh, '\tRandState:  %d\n',     modelSettings.randState);
    fprintf(fh, '\tData File:  %s\n',     modelSettings.dataFile);
    fprintf(fh, '\n\n');
    
    fprintf(fh, 'AutoEncoder:\n');
    fprintf(fh, '\tAvgError:       %-5.4f\n', modelSettings.ac.AvgError);
    fprintf(fh, '\tMaxIterations:  %-5d\n',   modelSettings.ac.MaxIterations);
    fprintf(fh, '\tAcc:            %-5.4f\n', modelSettings.ac.Acc);
    fprintf(fh, '\tDec:            %-5.4f\n', modelSettings.ac.Dec);
    fprintf(fh, '\tEtaInit:        %-5.4f\n', modelSettings.ac.EtaInit);
    fprintf(fh, '\tWeightInitType: %s\n',     modelSettings.ac.WeightInitType);
    fprintf(fh, '\n\n');
    
    fprintf(fh, 'Perceptron:\n');
    fprintf(fh, '\tAvgError:       %-5.4f\n', modelSettings.p.AvgError);
    fprintf(fh, '\tMaxIterations:  %-5d\n',   modelSettings.p.MaxIterations);
    fprintf(fh, '\tAcc:            %-5.4f\n', modelSettings.p.Acc);
    fprintf(fh, '\tDec:            %-5.4f\n', modelSettings.p.Dec);
    fprintf(fh, '\tEtaInit:        %-5.4f\n', modelSettings.p.EtaInit);
    fprintf(fh, '\tWeightInitType: %s\n',     modelSettings.p.WeightInitType);
    fprintf(fh, '\n\n');
    
    fprintf(fh, 'Analysis:\n');
    fprintf(fh, '\tRejection Width: %5.4f\n', modelSettings.rej.width);
    fprintf(fh, '\tRejection Type:  %s\n',    modelSettings.rej.types{:});
    fprintf(fh, '\n\n');
    
    % count rejections
    rcounts = [];
    for i=1:length(stats.raw.r), rcounts(end+1) = length(find(stats.raw.r{i})); end;
  
    fprintf(fh, 'Summary:\n');
    fprintf(fh, '\tRejections (ordered by Sigma): %d\n', rcounts(:));
    fprintf(fh, '\n');
    for i=1:length(modelSettings.data.TLBL)
      fprintf(fh, '\tRAW %s: %s\n', modelSettings.data.TLBL{i}, sprintf('%5.4e\t', stats.raw.basics.bars(i,:)));
    end;
    fprintf(fh, '\n');
    for i=1:length(modelSettings.data.TLBL)
      fprintf(fh, '\tREJ %s: %s\n', modelSettings.data.TLBL{i}, sprintf('%5.4e\t', stats.rej.basics.bars(i,:)));
    end;
    fprintf(fh, '\n\n');

    fclose(fh);
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_SaveCmd(fn, modelSettings)
  %
  %
    [fh, fmsg] = fopen(fn, 'w');
    
    fprintf(fh, 'DESimulator(');

    % Required arguments
    fprintf(fh, '%d',            modelSettings.data.dim);
    fprintf(fh, ', ''%s''',      modelSettings.data.stimSet);
    fprintf(fh, ', ''%s''',      modelSettings.data.taskType);
    fprintf(fh, ', %s',          guru_cell2str(modelSettings.data.opt));
    
    % Optional arguments: model
    fprintf(fh, ', ...\n\t''runs'',               %d',     modelSettings.runs);
    fprintf(fh, ', ...\n\t''sigma'',             [%s]',   sprintf(' %d', modelSettings.sigma(:)));
    fprintf(fh, ', ...\n\t''deType'',            ''%s''', modelSettings.deType);
    fprintf(fh, ', ...\n\t''nHidden'',           %d', modelSettings.nHidden);
    fprintf(fh, ', ...\n\t''nConns'',            %d', modelSettings.nConns);
    fprintf(fh, ', ...\n\t''debug'',             %d', modelSettings.debug);

    fprintf(fh, ', ...\n\t''dataFile'',          ''%s''', modelSettings.dataFile);
    fprintf(fh, ', ...\n\t''randState'',         %d',     modelSettings.randState);
 
    
    % Optional arguments: ac
    fprintf(fh, ', ...\n\t''ac.AvgError'',       %f',     modelSettings.ac.AvgError);
    fprintf(fh, ', ...\n\t''ac.MaxIterations'',  %d',     modelSettings.ac.MaxIterations);
    fprintf(fh, ', ...\n\t''ac.Acc'',            %f',     modelSettings.ac.Acc);
    fprintf(fh, ', ...\n\t''ac.Dec'',            %f',     modelSettings.ac.Dec);
    fprintf(fh, ', ...\n\t''ac.EtaInit'',        %f',     modelSettings.ac.EtaInit);
    fprintf(fh, ', ...\n\t''ac.errorType'',      %d',     modelSettings.ac.errorType);
    fprintf(fh, ', ...\n\t''ac.XferFn'',         %d',     modelSettings.ac.XferFn);
    fprintf(fh, ', ...\n\t''ac.WeightInitType'', ''%s''', modelSettings.ac.WeightInitType);
    fprintf(fh, ', ...\n\t''ac.debug'',          [%s]',   sprintf(' %d', modelSettings.ac.debug(:)));
    
    % Optional arguments: p
    fprintf(fh, ', ...\n\t''p.AvgError'',       %f',     modelSettings.p.AvgError);
    fprintf(fh, ', ...\n\t''p.MaxIterations'',  %d',     modelSettings.p.MaxIterations);
    fprintf(fh, ', ...\n\t''p.Acc'',            %f',     modelSettings.p.Acc);
    fprintf(fh, ', ...\n\t''p.Dec'',            %f',     modelSettings.p.Dec);
    fprintf(fh, ', ...\n\t''p.EtaInit'',        %f',     modelSettings.p.EtaInit);
    fprintf(fh, ', ...\n\t''p.errorType'',      %d',     modelSettings.p.errorType);
    fprintf(fh, ', ...\n\t''p.XferFn'',         %d',     modelSettings.p.XferFn);
    fprintf(fh, ', ...\n\t''p.WeightInitType'', ''%s''', modelSettings.p.WeightInitType);
    fprintf(fh, ', ...\n\t''p.debug'',          [%s]',   sprintf(' %d', modelSettings.p.debug(:)));
    
    % Analysis parameters
    fprintf(fh, ', ...\n\t''errorType'',        %d',     modelSettings.errorType);
    fprintf(fh, ', ...\n\t''rej.types'',        %s',     guru_cell2str(modelSettings.rej.types));
    fprintf(fh, ', ...\n\t''rej.width'',        %d',     modelSettings.rej.width);

    fprintf(fh, ', ...\n\t''plots'',            %s',     guru_cell2str(modelSettings.plots));
    fprintf(fh, ', ...\n\t''stats'',            %s',     guru_cell2str(modelSettings.stats));
    
    % Reporting results
    fprintf(fh, ', ...\n\t''out.data'',         %s',     guru_cell2str(modelSettings.out.data));
    fprintf(fh, ', ...\n\t''out.stem'',         ''%s''', modelSettings.out.stem);


    fprintf(fh, ' ...\n);');
    fclose(fh);
