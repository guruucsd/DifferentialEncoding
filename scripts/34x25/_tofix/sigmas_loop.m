function sigmas_loop(sigmas)
%for various sigma contrasts, produce fft plots:
%* for single mode and uber mode

  if (matlabpool('size') == 0)
    matlabpool open 'local' 4
  end;
  
  if (~exist('sigmas','var')), sigmas = [1.5 3 6 11 18 25]; end;
  if (~exist('tasks', 'var')), tasks  = {'sergent' 'kitterle' 'christman'}; end;

  for ii=1:length(sigmas)
    for jj=ii+1:length(sigmas)
      cur_contrast = [sigmas(ii) sigmas(jj)];
    
      [~, n_ac] = shared_opts();
      [args, opts] = local_uber_args  ( n_ac, cur_contrast ); % This sets the opts
      
      for ti=1:length(tasks)
      for mi=1:2
        switch (mi)
          % Prep to execute in uber mode
          case 1, [args, opts] = local_uber_args  ( n_ac, cur_contrast, 'stats', {}, 'plots', {} )
          
          % Prep to execute in non-uber mode
          case 2, args = local_single_args( cur_contrast );
          
          otherwise, error('programming error!');
        end;
            
        exec_task( tasks{ti}, n_ac, args, opts );
    
        % Find a way to collect info
      end;
      end;
    end;
  end;

   

%%%%%%%%%%%%%%%%
function [opts, n_ac] = shared_opts()
  opts.nInput = [34 25];
  
  opts.c_freqs = 2*[0.03 0.06 0.12 0.24 0.48];
  opts.c_thetas = [0];
  
  opts.k_freqs = [0.05 0.15];  

  n_ac = 68;
  

%%%%%%%%%%%%%%%%
function [args,opts] = local_single_args( cur_contrast )
  args = common_args( 'sigma', cur_contrast, 'parallel', true );

  opts = shared_opts();



%%%%%%%%%%%%%%%%
function [args,opts] = local_uber_args( n_ac, cur_contrast, varargin )
  addpath('uber');
  
  % Get the encoding args
  [args] = uber_args( 'runs', n_ac, 'sigma', cur_contrast, 'parallel', true, varargin{:});
  [opts] = shared_opts();
  
  % Run the autoencoder
  onm = fieldnames(opts);
  ovl = struct2cell(opts);
  opts= {onm{:};ovl{:}};
  opts= opts(:)';
  [~, models, ~] = de_Simulator('uber', 'all', '', opts, args{:});

  % Get the autoencoder directories
  ac = [models(1,:).ac];
  dirs = cell(size(ac));
  for i=1:length(ac)
     dirs{i} = guru_fileparts(ac(i).fn, 'path');
  end;
  clear('models', 'ac');
    
  args(end+1:end+2) = {'uberpath', dirs};




%%%%%%%%%%%%%%%%
function exec_task( task, n_ac, args, opts )

    %%%%%%%%%%%%%%%%
    % Run each task
    %   ** in the order requested **
    %%%%%%%%%%%%%%%%%
    p_args = { args{:}, ...
              'plots', {}, 'stats', {}, ...
              'p.XferFn', 4,               'p.useBias', 1, ...
              'p.AvgError',  0,            ...
              'p.TrainMode','batch',       'p.Pow',  1 ...
              'p.lambda', 0 ...
             };
        
    opts = struct(opts{:});
    curopts = {};
    if (isfield(opts, 'nInput')), curopts(end+1:end+2) = {'nInput', opts.nInput}; end;
    
    switch (task)
        case 'sergent'
            run_sergent( n_ac, p_args, curopts ); 

        case 'kitterle'
            if (isfield(opts, 'k_freqs')),   curopts(end+1:end+2) = {'freqs',   opts.k_freqs}; end;
            if (isfield(opts, 'k_nThetas')), curopts(end+1:end+2) = {'nThetas', opts.k_nThetas}; end;
            run_kitterle( n_ac, p_args, curopts ); 

        case 'christman'
            if (isfield(opts, 'c_freqs')),  curopts(end+1:end+2) = {'freqs',  opts.c_freqs}; end;
            if (isfield(opts, 'c_thetas')), curopts(end+1:end+2) = {'thetas', opts.c_thetas}; end;
            run_christman( n_ac, p_args, curopts ); 
            
        case 'young', run_young( n_ac, p_args, curopts ); 
    end;

            
%%%%%%%%%%%%%%%%
function run_sergent( n_ac, p_args, s_opts )

    % Sergent
    s_args = { p_args{:}, 'runs', min(n_ac, 68), ...
              'plots', {'ls_bars'},  ...
              'p.nHidden', 1, ...
              'p.MaxIterations', 1000, ...
              'p.EtaInit',   0.01,    ...
              'p.Acc',  1.0025,  'p.Dec'  1.25 ... %sig,bias=0
             };
             
    de_Simulator('sergent_1982', 'de', 'sergent', s_opts, s_args{:}, 'plots', {'ls_bars', 'ffts', 'images'}, 'stats', {'ffts','images'} );
    de_Simulator('sergent_1982', 'de', 'sergent', {'D1#T1' s_opts{:}}, s_args{:});
    de_Simulator('sergent_1982', 'de', 'sergent', {'D1#T2' s_opts{:}}, s_args{:});
    de_Simulator('sergent_1982', 'de', 'sergent', {'D2#T1' s_opts{:}}, s_args{:}); %rezad
    de_Simulator('sergent_1982', 'de', 'sergent', {'D2#T2' s_opts{:}}, s_args{:});
    de_Simulator('sergent_1982', 'de', 'sergent', {'swapped' s_opts{:}}, s_args{:});
        
        
%%%%%%%%%%%%%%%%
function run_kitterle( n_ac, p_args, k_opts )
    k_args  = { p_args{:}, 'runs', min(n_ac, 40), ...
                 'p.nHidden', 10, ...
                 'p.MaxIterations', 500, ...
                 'p.EtaInit',   1E-2,         'p.Acc',  1.01,  'p.Dec',  1.25, ... %sig,bias=0
               };
               
    de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_freq', k_opts, k_args{:}, 'plots', {'ffts', 'images'}, 'stats', {'ffts', 'images'});
    de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_type', k_opts, k_args{:});

        
%%%%%%%%%%%%%%%%
function run_christman( n_ac, p_args, c_opts )
    c_args  = { p_args{:}, 'runs', min(n_ac, 64), ...
                'p.nHidden', 15, ...
                'p.MaxIterations', 2500, ...
                'p.EtaInit',   1E-3,         'p.Acc',  1.001,  'p.Dec',  1.15, ... %sig,bias=0
                'plots', {'ffts', 'images'}, 'stats', {'ffts', 'images'}, ...
              };
    de_Simulator('christman_etal_1991', 'low_freq',  'recog', c_opts, c_args{:});
    de_Simulator('christman_etal_1991', 'high_freq', 'recog', c_opts, c_args{:});
        
        
%%%%%%%%%%%%%%%%
function run_young( n_ac, p_args, y_opts )
%
    y_args  = { p_args{:}, 'runs', min(n_ac, 50), ...
                'p.nHidden', 25, ...
                'p.MaxIterations', 5000, ...
                'p.EtaInit',   1E-3,         'p.Acc',  1.001,  'p.Dec',  1.15, ... %sig,bias=0
                'plots', {'ffts'}, 'stats', {'ffts'}, ...
               };
    de_Simulator('young_bion_1981', 'orig',  'recog', y_opts, y_args{:});

