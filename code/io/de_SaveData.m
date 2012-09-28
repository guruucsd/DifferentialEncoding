function out = de_SaveData(mSets, models, stats)
%
%
  out = mSets.out;

  % Stamp the output files & paths 
  for i=1:length(out.data)
    switch(out.data{i})
    
      % Save all data to .mat 
      case 'mat'
        fprintf('Skipping saving of mat summary\n');
        continue;
        
        out.files{end+1} = de_GetOutFile(mSets, 'data', '.mat', mSets.runs);%fullfile(out.runspath, [out.stem '.mat']);
        %out.files{end}   = guru_smartfn( out.files{end} );
        
        if (~exist(out.files{end}, 'file'))
          if (ismember(1,mSets.debug))
            fprintf('Saving all results to .mat: %s\n', out.files{end});
          end;
          
          de_SaveMat( out.files{end}, mSets, models, stats );
        end;
        
      % Save LS to csv for Janet
      case 'csv'
        out.files{end+1} = de_GetOutFile(mSets, 'summary', '.csv', mSets.runs);%fullfile(out.runspath, [out.stem '.csv']);
        %out.files{end}   = guru_smartfn( out.files{end} );
         
        %if (~exist(out.files{end}, 'file'))
          if (ismember(1,mSets.debug))
            fprintf('Saving LS results to .csv: %s\n', out.files{end});
          end;

          sTitle = sprintf('%dD Network settings: o=%s nConns=%d nHidden=%d trials=%d\n', ...
                           length(mSets.nInput), ['[' sprintf('%4.1f ',mSets.sigma) ']'], ...
                           mSets.nConns, mSets.nHidden, mSets.runs);
          
          de_SaveCSV2(out.files{end}, stats, ',', sTitle, mSets);
        %end;
        
      % Save run results to .txt
      case 'info'
        out.files{end+1} = de_GetOutFile(mSets, 'summary', '.summary.txt', mSets.runs);%fullfile(out.runspath, [out.stem '.mat']);
        %out.files{end+1} = fullfile(out.resultspath, [out.stem '.summary.txt']);
        %out.files{end}   = guru_smartfn( out.files{end} );

        %if (~exist(out.files{end}, 'file'))
          if (ismember(1,mSets.debug))
            fprintf('Saving settings summary to .txt: %s\n', out.files{end});
          end;

          de_SaveSummaryInfo(out.files{end}, mSets, stats);
        %end;
        
      % Save run results to .txt
      case 'cmd'
        out.files{end+1} = de_GetOutFile(mSets, 'data', 'summary', '-replicate.m', mSets.runs);%out.data{i});%fullfile(out.runspath, [out.stem '.mat']);
        %out.files{end+1} = fullfile(out.resultspath, [out.stem '-replicate.m']);
        %out.files{end}   = guru_smartfn( out.files{end} );

        %if (~exist(out.files{end}, 'file'))
          if (ismember(1,mSets.debug))
            fprintf('Saving re-run command to .m: %s\n', out.files{end});
          end;

          de_SaveCmd(out.files{end}, mSets);
        %end;
        
      end; %switch
    end; % for
  

