clear all variables; clear all globals;

% Train the autoencoder
n_ac = 10;
tasks = {'sergent', 'kitterle'};

%%%%%%%%%%%%%%%%
% Run the autoencoder & gather output
%%%%%%%%%%%%%%%%%

[args,opts,c_cycles,k_cycles]  = uber_args( 'runs', n_ac );
c_thetas = [pi/2];

[mSets, models, stats] = de_Simulator('uber', 'simple', '', {opts{:},'c_cycles', c_cycles, 'k_cycles', k_cycles, 'c_thetas', c_thetas}, args{:});


% Get the autoencoder directories
ac = [models(1,:).ac];
dirs = cell(size(ac));
for i=1:length(ac)
   dirs{i} = guru_fileparts(ac(i).fn, 'path');
end;
clear('ac');

%keyboard

%%%%%%%%%%%%%%%%
% Run each task
%   ** in the order requested **
%%%%%%%%%%%%%%%%%
p_args = { args{:}, ...
          'uberpath', dirs, ...
          'plots', {}, 'stats', {}, ...
          'p.XferFn', 6,               'p.useBias', 1, ...
          'p.AvgError',  0,            ...
          'p.TrainMode','resilient',       'p.Pow',  1 ...
          'p.lambda', 0 ...
          'p.wmax', inf, ...
          'p.WeightInitScale', 0.01 ...
         };

for ti=1:length(tasks)


    if (strcmp('sergent',tasks{ti}))


        % Sergent
        s_args = { p_args{:}, 'runs', min(n_ac, 68), ...
                  'plots', {'ls_bars'},  ...
                  'p.nHidden', 1, ...
                  'p.MaxIterations', 200, ...
                  'p.EtaInit',   0.01,    ...
                  'p.Acc',  1.01,  'p.Dec'  1.25, ... %sig,bias=0
                 };
        de_Simulator('sergent_1982', 'de', 'sergent',         {opts{:}}, s_args{:}, 'plots',{'ls-bars', 'ffts', 'images'}, 'stats', {'ffts','images'} );
        de_Simulator('sergent_1982', 'de', 'sergent-D1#T1',   {opts{:}}, s_args{:}, 'plots',{'ls-bars'});
        de_Simulator('sergent_1982', 'de', 'sergent-D1#T2',   {opts{:}}, s_args{:}, 'plots',{'ls-bars'});
        de_Simulator('sergent_1982', 'de', 'sergent-D2#T1',   {opts{:}}, s_args{:}, 'plots',{'ls-bars'}); %rezad
        de_Simulator('sergent_1982', 'de', 'sergent-D2#T2',   {opts{:}}, s_args{:}, 'plots',{'ls-bars'});
        de_Simulator('sergent_1982', 'de', 'sergent-swapped', {opts{:}}, s_args{:}, 'plots',{'ls-bars'});
    end;


    % Kitterle
    if (strcmp('kitterle', tasks{ti}))
        k_args  = { p_args{:}, 'runs', min(n_ac, 1), ...
        'parallel', false, ...
                     'p.nHidden', 50, ...
                     'p.MaxIterations', 1000, ...
                     'p.EtaInit',   1E-1,         'p.Acc',  5E-6,  'p.Dec',  0.15, ... %sig,bias=0
                     'p.debug', 1:10, ...
                   };
        de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {opts{:},'cycles', k_cycles}, k_args{:}, 'plots', {'ffts', 'images'}, 'stats', {'ffts', 'images'});
        de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_type', {opts{:},'cycles', k_cycles}, k_args{:});
    end;


    % Christman
    if (strcmp('christman', tasks{ti}))
        c_args  = { p_args{:}, 'runs', min(n_ac, 64), ...
                    'p.nHidden', 15, ...
                    'p.MaxIterations', 2500, ...
                    'p.EtaInit',   1E-3,         'p.Acc',  1.001,  'p.Dec',  1.15, ... %sig,bias=0
                    'plots', {'ffts', 'images'}, 'stats', {'ffts', 'images'}, ...
                  };
        de_Simulator('christman_etal_1991', 'low_freq',  'recog', {opts{:},'cycles', c_cycles, 'thetas', c_thetas}, c_args{:});
        de_Simulator('christman_etal_1991', 'high_freq', 'recog', {opts{:},'cycles', c_cycles, 'thetas', c_thetas}, c_args{:});
    end;


    % Young
    if (strcmp('young', tasks{ti}))
        y_args  = { p_args{:}, 'runs', min(n_ac, 50), ...
                    'p.nHidden', 25, ...
                    'p.MaxIterations', 5000, ...
                    'p.EtaInit',   1E-3,         'p.Acc',  1.001,  'p.Dec',  1.15, ... %sig,bias=0
                    'plots', {'ffts'}, 'stats', {'ffts'}, ...
                   };
        de_Simulator('young_bion_1981', 'orig',  'recog', {opts{:}}, y_args{:});
    end;
end;
