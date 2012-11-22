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

    case {'conn'}
            origString = de_GetOutPath(model, 'ac_p_base');
            hash       = hash_path(origString);
            
            outdir = fullfile(de_GetOutPath(model, 'cache'), 'conn', hash);


    % Top-level output directory for trained models and analysis stats.
    %   sub-directories will be more specific
    case {'runs','stats'},
      if (isempty(model))
          outdir = fullfile(de_GetOutPath(model, 'cache'), 'runs');
      elseif (~guru_findstr(model.out.dirstem, model.out.runspath))
        outdir = fullfile(model.out.runspath, model.out.dirstem);
      else
        outdir = model.out.runspath;
      end;


    % Main output directory for analysis summaries and plots (i.e. human-readable!)
    case {'results', 'plot', 'summary', 'settings-map'}
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
                         sprintf('WL=[ %d %d ]', model.ac.wlim(1), model.ac.wlim(2)) ...
                        ];

          % Pruning: the original model
          if isfield(model.ac,'ct') % pruning study
              origString = [origString ...
                            sprintf('CT=%s', de_GetOutFile(model.ac.ct, 'conn')) ...
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
