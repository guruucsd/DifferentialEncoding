function [args, opts] = de_SetupStackedArgs(args, opts)
%function [args, opts] = de_SetupStackedArgs(args, opts)
%

    if iscell(args)
        args(end+1:end+2) = {'deType', 'de-stacked'};

        % Grab the AC hidden unit XferFn
        ac_xferfn = guru_getopt(args, 'ac.XferFn', [6 1]);
        args(end + [1:2]) = {'p.XferFn', [ac_xferfn(1) guru_getopt(args, 'p.XferFn', [6 3])]};

        % Copy some properties from the autoencoder to the perceptron.
        for prop = {'zscore', 'noise_input'}
            prop = prop{1};
            ac_val = guru_getopt(args, ['ac.' prop]);
            args(end + [1:2]) = {['p.' prop], ac_val};
        end;

    elseif isstruct(args)
        mSets = args;
        mSets.deType = 'de-stacked';
        mSets.p.XferFn = [mSets.ac.XferFn(1), mSets.p.XferFn];
        for prop = {'zscore', 'noise_input'}
            prop = prop{1};
            if isfield(mSets.ac, prop)
                mSets.p.(prop) = mSets.ac.(prop);
            end;
        end;
        args = mSets;
    else
        error('Unrecognized type for args');
    end;