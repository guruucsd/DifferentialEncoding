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
  
  
    case {'data'},
    error('who is calling me like this?');
    outdir = de_GetOutPath(model, 'runs');
    
    % Top-level output directory for trained models and analysis stats.
    %   sub-directories will be more specific
    case {'runs','stats'},
      if (~guru_findstr(model.out.dirstem, model.out.runspath))
        outdir = fullfile(model.out.runspath, model.out.dirstem);
      else
        outdir = model.out.runspath;
      end;
      
    % Main output directory for analysis summaries and plots (i.e. human-readable!)
    case {'results', 'plot', 'summary', 'settings-map'}
      if (~guru_findstr(model.out.dirstem, model.out.resultspath))
        outdir = fullfile(model.out.resultspath, model.out.dirstem);
      else
        outdir = model.out.resultspath;
      end;

    case {'acn','pn'}
       error('who is calling me like this?');
%      origString = '';
%      origString = [ origString ...
%                     sprintf('DN=%s', sprintf('%s-', model.distn{:})), ...
%                     sprintf('MU=%s', sprintf('%f-', model.mu(:))), ...
%                     sprintf('SG=%s', sprintf('%f-', model.sigma(:))), ...
%                     sprintf('AE=%f', model.ac.AvgError), ...
%                     sprintf('MI=%d', model.ac.MaxIterations), ...
%                     sprintf('AC=%f', model.ac.Acc), ...
%                     sprintf('DC=%f', model.ac.Dec), ...
%                     sprintf('EI=%f', model.ac.EtaInit), ...
%                     sprintf('XF=%d', model.ac.XferFn), ...
%                     sprintf('WT=%s', model.ac.WeightInitType) ];
%      %hash = mfe_md5(origString);
%      hash = sprintf('%d', sum(origString.*[1:10:10*length(origString)]));
%      outdir = fullfile(de_GetOutPath(model, 'data'), hash); %saving under data directory
    
    % Directory containing all trained models.
    %   should contain ALL [overall] AND [ac] model settings.
    case {'ac'}
        if (isfield(model,'uberpath'))
            outdir = model.uberpath;
            %fprintf('[uber-path]');
        else
            % Ridiculous internal directory name needs to be unique, but shortened.
            %   That's what hashes are for!
            %hash = mfe_md5(origString);
            origString = de_GetOutPath(model, 'ac_p_base');
            hash = sprintf('%d', round( sum(origString.*[1:5:5*length(origString)]) ));
    
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
          hash = sprintf('%d', round( sum(origString.*[1:5:5*length(origString)]) ));
    
          % That was just the directory name; now prepend the base directory!
          outdir = fullfile(de_GetOutPath(model, 'runs'), hash); %saving under data directory


    % The shared part of ac and p paths
    case {'ac_p_base'}
          origString = [ '' ... % add on base model settings
                         sprintf('DN=%s', sprintf('%s-', model.distn{:})), ... %if we call in based on a "full" mSets,
                         sprintf('MU=%s', sprintf('%f-', model.mu(:))), ...    %  this will be DIFFERENT than if we
                         sprintf('SG=%s', sprintf('%f-', model.sigma(:))), ... %  call in on a trained model (with one sigma)
                         sprintf('NH=%d', model.nHidden), ... % These are stamped elsewhere,
                         sprintf('HP=%d', model.hpl), ...     %   but just to be safe,
                         sprintf('NC=%d', model.nConns), ...  %   stamp them here too.
                         sprintf('TL=%d', model.ac.tol) ...  %   stamp them here too.
                         ];
                         
          origString = [ origString ... % add on AC model settings
                     ...%sprintf('RS=%f', model.ac.randState), ... %this is marked on the file
                         sprintf('WT=%d', model.ac.WeightInitType), ...
                         sprintf('TM=%d', model.ac.TrainMode), ...
                         sprintf('AE=%f', model.ac.AvgError), ...
                         sprintf('MI=%d', model.ac.MaxIterations), ...
                         sprintf('ET=%d', model.ac.errorType), ...
                         sprintf('XF=%d', model.ac.XferFn), ...
                         sprintf('UB=%d', model.ac.useBias), ...
                         sprintf('AC=%f', model.ac.Acc), ...
                         sprintf('DC=%f', model.ac.Dec), ...
                         sprintf('EI=%f', model.ac.EtaInit), ...
                         sprintf('PW=%f', model.ac.Pow), ...
                         sprintf('LB=%d', model.ac.lambda) ...
                        ];
          outdir = origString; % bubble this back up as clear-text

      
      otherwise
            error('Unknown type: %s', dirType);
  end;

  if (~guru_findstr(de_GetBaseDir(), outdir))
    outdir = fullfile(de_GetBaseDir(), outdir);
  end;