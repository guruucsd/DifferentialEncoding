% Model run with targets and distracter sets swapped

args = sergent_args('plots', {}, 'stats', {});

sigmas = guru_getopt(args, 'sigma');
sigma_rh = sigmas(1);
sigma_lh = sigmas(end);

%
[~, models_rh] = de_Simulator('sergent_1982', 'de', 'sergent', {'blurring', 1.5}, args{:}, 'sigma', sigma_rh);
[~, models_lh] = de_Simulator('sergent_1982', 'de', 'sergent', {'blurring', 1.5}, args{:}, 'sigma', sigma_lh, 'ac.AvgError', 0, 'ac.MaxIterations', 1, 'ac.rej.type', {'sample_std-normd'}, 'ac.rej.width',3,'p.MaxIterations',1);
models         = [models_rh models_lh];

% Continue training...
models = de_ContinueModels(models, 'sergent_1982', 'de', 'sergent', {'blurring', 1.0});

% Continue training...
models = de_ContinueModels(models, 'sergent_1982', 'de', 'sergent', {'blurring', 0.5});
