clear all variables; clear all globals;

% I want to test spatial frequency processing with different hu/hpl, sigma, and nconn setups

hu_hpl = [850 1; 425 2; 108 8; 425 1; 108 4];
sigma  = [ 2 4; 4 8; 4 12; 6 8; 6 12];
nconn  = [ 8; 10; 15; 20; 40];

stats = {'ipd','connectivity','images','ffts'};
plts = {'ls-bars', stats{:}};

train_data = cell(length(hu_hpl),length(sigma),length(nconn));
test_data  = cell(size(train_data));

for hi=1:length(hu_hpl), for si=1:length(sigma), for ci=1:length(nconn)
    [args,opts]  = uber_sergent_args('nHidden', prod(hu_hpl(hi, :)), 'hpl', hu_hpl(hi,2), ...
                                     'sigma', sigma(si, :), 'nConns', nconn(ci), ...
                                     'plots',plts,'stats',stats,'runs',25);

    % Make sure that this is trainable.
    [trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, {args{:}, 'runs', 2});%, 'plots',{},'stats',{}});

    % If not, skip; leave the data empty
    if numel(trn.models)<2
      warning('parameter combination fails: hu_hpl=[%d %d], sigma=[%f %f], nconn=%d', hu_hpl(hi,:), sigma(si,:), nconn(ci));

    % If so, train all!
    else
        [trn,tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, args);
        
        % Blank out some 'expensive' fields
        trn.stats.rej.ac.images = []; tst.stats.rej.ac.images = [];
        trn.stats.rej.ac.ffts   = []; tst.stats.rej.ac.ffts   = [];

        % Save off the results
        train_data{hi,si,ci} = trn;
        test_data{hi,si,ci}  = tst;
    end;

end; end; end;

