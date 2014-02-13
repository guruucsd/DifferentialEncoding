function outdir = de_GetOutPath(model, dirType)
% This is a function that will construct the "proper" paths
%   for a given simulation, based on the simulation parameters.
%
% Most of the "work" is in determining the simulation's directory path,
%   which is a hash of the basic simulation settings.
%   From there, ac and p models, after training, are based on THEIR settings.
%
% Full list of dirType supported:
%
%   base    - code base for de
%   expt    - code base for a particular experiment
%
%   runs    - base directory (human-readable) for a subset of simulations
%   ac,p    - hashed directory name for a particular simulation (cache for trained models)
%
  switch (dirType)
    case {'base'},
        outdir = de_GetBaseDir();

    case {'cache'},
        outdir = fullfile('~', '_cache', 'de');

    case {'data'},
        outdir = fullfile(de_GetOutPath(model,'cache'), 'data');

    case {'datasets'}
        outdir = fullfile('~', 'datasets');

    % Connections are stored to a directory based ONLY on its own properties,
    %   NOTHING about how it will be used after the pruned connections are established
    case 'conn_base'
        % Make sure to select one of the settings given
        if isfield(model, 'hemi') && iscell(model.iters_per),
            model.iters_per = model.iters_per{model.hemi};
            model.steps     = model.steps{model.hemi};
            model.sigma = model.sigma(model.hemi);
        end;

        origString = '';

        % Add conn-specific model settings
        origString = [ origString ...
                       sprintf('SG=%f,',   model.sigma), ...
                       sprintf('NS=%d,',   model.nConnPerHidden_Start), ...
                       sprintf('NE=%d,',   model.nConnPerHidden_End), ...
                     ];

        % Add workspace settings
        origString = [ origString ...
                       sprintf('DS=%s,',   model.dataset), ...
                       sprintf('IP=[%s],', sprintf(' %d',model.iters_per)), ...
                       sprintf('ST=[%s],', sprintf(' %d',model.steps)), ...
                       sprintf('NP=%d,',   model.npruning_loops), ...
                       sprintf('PL=%s,',   model.prune_loc), ...
                       sprintf('PS=%s,',   model.prune_strategy), ...
                       sprintf('KW=%d,',   model.keep_weights), ...
                       sprintf('NK=%d,',   model.ac.nzc_ok), ...
                       sprintf('OP=%s',    guru_cell2str(model.data.opt, '.')), ...
                     ];


            hash       = hash_path(origString);
            outdir     = hash;

    case {'conn'}
            outdir = fullfile(de_GetOutPath(model, 'cache'), 'conn', de_GetOutPath(model, 'conn_base'));


    % Top-level output directory for trained models and analysis stats.
    %   sub-directories will be more specific
    case {'runs'}
      % NOTE: this may now break, as dirstem may have
      % multiple values.
      if (isempty(model))
          outdir = fullfile(de_GetOutPath(model, 'cache'), 'runs');
      elseif (~guru_findstr(model.out.dirstem, model.out.runspath))
        outdir = fullfile(model.out.runspath, model.out.dirstem);
      else
        outdir = model.out.runspath;
      end;

    % Main output directory for analysis summaries and plots (i.e. human-readable!)
    case {'results', 'plot', 'summary', 'stats', 'settings-map'}
      % NOTE: this may now break, as dirstem may have
      % multiple values.
      if (isempty(model))
          outdir = fullfile(de_GetBaseDir(), 'results');
      elseif (~guru_findstr(model.out.dirstem, model.out.resultspath))
        outdir = fullfile(model.out.resultspath, model.out.dirstem);
      else
        outdir = model.out.resultspath;
      end;


    % Directory containing all trained models.
    %   should contain ALL [overall] AND [ac] model settings.
    case {'ac'}
        if (isfield(model,'uberpath'))
            outdir = model.uberpath;
        else
            % Ridiculous internal directory name needs to be unique, but shortened.
            %   That's what hashes are for!
            %hash = mfe_md5(origString);
            origString = de_GetOutPath(model, 'ac_p_base');
            hash = hash_path(origString);%sprintf('%d', round( sum(origString.*[1:5:5*length(origString)]) ));

            % That was just the directory name; now prepend the base directory!
            outdir = fullfile(de_GetOutPath(model, 'runs'), hash); %saving under data directory
        end;


    case {'p'}
        origString = de_GetOutPath(model, 'ac_p_base');
        if (isfield(model, 'uberpath')) % don't confuse p for uber and non-uber cases
            origString = [origString model.uberpath];
        end;

          % Ridiculous internal directory name needs to be unique, but shortened.
          %   That's what hashes are for!
          hash = hash_path(origString);%sprintf('%d', round( sum(origString.*[1:5:5*length(origString)]) ));

          % That was just the directory name; now prepend the base directory!
          outdir = fullfile(de_GetOutPath(model, 'runs'), hash); %saving under data directory


    % NOTE: THIS IS WHAT YOU WANT!!!
    %
    % COME EDIT THIS WITH NEW PROPS,
    %   TO GET THEM INTO THE CACHING SCHEME
    %
    % The shared part of ac and p paths
    case {'ac_p_base'}
          %origString = guru_fileparts(model.dataFile, 'filename'); %

          origString = [ 'opt=' guru_cell2str(model.data.opt, '.')];
          %origString = ''; % options should be pasted on

          origString = [ origString ... % add on base model settings
                         sprintf('UBER=%d', isfield(model, 'uberpath')), ...
                         sprintf('DN=%s', sprintf('%s-', model.distn{:})), ... %if we call in based on a "full" mSets,
                         sprintf('MU=%s', sprintf('%f-', model.mu(:))), ...    %  this will be DIFFERENT than if we
                         sprintf('SG=%s', sprintf('%f-', model.sigma(:))), ... %  call in on a trained model (with one sigma)
                         sprintf('NH=%d', model.nHidden), ... % These are stamped elsewhere,
                         sprintf('HP=%d', model.hpl), ...     %   but just to be safe,
                         sprintf('NC=%d', model.nConns), ...  %   stamp them here too.
                         sprintf('DE=%s', model.deType), ...  %   stamp them here too.
                         ];

          origString = [ origString ... % add on AC model settings
                         sprintf('NI=%d', model.ac.noise_input), ...
                         sprintf('WT=%s', model.ac.WeightInitType), ...
                         sprintf('WS=%f', model.ac.WeightInitScale), ...
                         sprintf('TM=%d', model.ac.TrainMode), ...
                         sprintf('AE=%f', model.ac.AvgError), ...
                         sprintf('MI=%d', model.ac.MaxIterations), ...
                         sprintf('ET=%d', model.ac.errorType), ...
                         sprintf('XF=[ %s]', sprintf('%d ',model.ac.XferFn)), ...
                         sprintf('UB=%d', model.ac.useBias), ...
                         sprintf('AC=%f', model.ac.Acc), ...
                         sprintf('DC=%f', model.ac.Dec), ...
                         sprintf('EI=%f', model.ac.EtaInit), ...
                         sprintf('PW=%f', model.ac.Pow), ...
                         sprintf('TL=%d', model.ac.tol), ...  %   stamp them here too.
                         sprintf('LB=%d', model.ac.lambda), ...
                         sprintf('DO=%f', model.ac.dropout), ...
                         sprintf('TS=%d', model.ac.ts), ...
                         sprintf('WL=[ %d %d ]', model.ac.wlim(1), model.ac.wlim(2)) ...
                        ];

          % Pruning: the original model
          if isfield(model.ac,'ct') % pruning study

              % need to select
              if ~isfield(model.ac.ct, 'hemi') && isfield(model, 'hemi')
                  model.ac.ct.hemi = model.hemi;
              end;

              origString = [origString ...
                            sprintf('CT=%s', de_GetOutPath(model.ac.ct, 'conn_base')) ...
                           ];
          end;

          if (isfield(model.ac, 'zscore'))
              origString = sprintf('%s,ZS=%f', origString, model.ac.zscore);
          end;

          outdir = origString; % bubble this back up as clear-text

          if ismember(11, model.debug)
            fprintf('%s\n', outdir)
          end

      otherwise
            error('Unknown type: %s', dirType);
  end;

  if (~guru_findstr(de_GetBaseDir(), outdir) && ~guru_findstr('~', outdir))
    outdir = fullfile(de_GetBaseDir(), outdir);
  end;


function hp = hash_path(p)
  hv = round( sum(p.*[1:5:5*length(p)]) );
  guru_assert(hv<1E10, 'hash cannot be too big')
  hp = sprintf('%d', hv);
