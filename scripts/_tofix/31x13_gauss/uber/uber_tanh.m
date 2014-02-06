% Train the autoencoder
n_ac = 68;
tasks = {'sergent', 'kitterle', 'christman'};

%%%%%%%%%%%%%%%%
% Run the autoencoder & gather output
%%%%%%%%%%%%%%%%%


[args,c_freqs,k_freqs]  = uber_args( 'runs', n_ac, ...
                                     'plots', {'images'}, ...
                                     'stats', {'images'} ... 
                          );
[mSets, models, stats] = de_Simulator('uber', 'all', '', {'c_freqs', c_freqs, 'k_freqs', k_freqs}, args{:});


% Get the autoencoder directories
ac = [models(1,:).ac];
dirs = cell(size(ac));
for i=1:length(ac)
   dirs{i} = guru_fileparts(ac(i).fn, 'path');
end;
clear('ac');


%%%%%%%%%%%%%%%%
% Run each task
%%%%%%%%%%%%%%%%%

p_args = { args{:}, ...
          'uberpath', dirs, ...
          'plots', {}, 'stats', {}, ...
          'p.XferFn', 4,               'p.useBias', 1, ...
          'p.AvgError',  0,            ...
          'p.TrainMode','batch',       'p.Pow',  1 ...
          'p.lambda', 0 ...
         };

if (ismember('sergent',tasks))

    
    % Sergent
    s_args = { p_args{:}, 'runs', min(n_ac, 68), ...
              'plots', {'ls_bars'},  ...
              'p.nHidden', 1, ...
              'p.MaxIterations', 250, ...
              'p.EtaInit',   0.01,    ...
              'p.Acc',  1.0025,  'p.Dec'  1.25 ... %sig,bias=0
             };
    de_Simulator('sergent_1982', 'de', 'sergent', {}, s_args{:});
    de_Simulator('sergent_1982', 'de', 'sergent', {'D1#T1'}, s_args{:});
    de_Simulator('sergent_1982', 'de', 'sergent', {'D1#T2'}, s_args{:});
    de_Simulator('sergent_1982', 'de', 'sergent', {'D2#T1'}, s_args{:}); %rezad
    de_Simulator('sergent_1982', 'de', 'sergent', {'D2#T2'}, s_args{:});
    de_Simulator('sergent_1982', 'de', 'sergent', {'swapped'}, s_args{:});
end;

% Kitterle
if (ismember('kitterle', tasks))
    kf_args  = { p_args{:}, 'runs', min(n_ac, 50), ...
                 'p.nHidden', 10, ...
                 'p.MaxIterations', 500, ...
                 'p.EtaInit',   1E-2,         'p.Acc',  1.01,  'p.Dec',  1.25, ... %sig,bias=0
               };
    de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {'freqs', k_freqs}, kf_args{:});
    
    
    kt_args  = { p_args{:}, 'runs', min(n_ac, 68), ...
                 'p.nHidden', 5, ...
                 'p.MaxIterations', 1000, ...
                 'p.EtaInit',   5E-3,         'p.Acc',  1.001,  'p.Dec',  1.25 ... %sig,bias=0
               };
    de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_type', {'freqs', k_freqs}, kt_args{:});
end;

% Christman
if (ismember('christman', tasks))
    c_args  = { p_args{:}, 'runs', min(n_ac, 50), ...
                'p.nHidden', 15, ...
                'p.MaxIterations', 2500, ...
                'p.EtaInit',   1E-3,         'p.Acc',  1.001,  'p.Dec',  1.15, ... %sig,bias=0
               };
    de_Simulator('christman_etal_1991', 'low_freq',  'recog', {'freqs', c_freqs}, c_args{:});
    de_Simulator('christman_etal_1991', 'high_freq', 'recog', {'freqs', c_freqs}, c_args{:});
end;
