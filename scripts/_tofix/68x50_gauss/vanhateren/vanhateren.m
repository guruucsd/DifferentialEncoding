% Train the autoencoder
n_ac = 40;

%%%%%%%%%%%%%%%%
% Run the autoencoder & gather output
%%%%%%%%%%%%%%%%%


[args,sz]  = vanhateren_args( 'runs', n_ac );

[mSets, models, stats] = de_Simulator('vanhateren', 'all', '', {'nInput',sz, 'dnw', true}, args{:});
