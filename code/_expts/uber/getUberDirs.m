function d = getUberDirs( nRuns )

    [args,c_freqs,k_freqs] = uber_args( 'runs', nRuns, 'plots', {}, 'stats', {}, 'debug', [] );
    [mSets, models, stats] = de_Simulator('uber', 'all', '', {'c_freqs', c_freqs, 'k_freqs', k_freqs, 'nInput', [34 25]}, args{:});

    ac = [models(1,:).ac];
    fn = {ac.fn};
    d  = cell(size(fn));
    for i=1:length(fn)
        d{i} = fileparts(fn{i});
    end;


