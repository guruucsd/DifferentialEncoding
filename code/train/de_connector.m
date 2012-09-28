function [Con,Wts] = de_connector(model)
%[Con, mu] = de_connector(model)
%
% Creates a connectivity matrix for the given model
%
% Inputs:
% model : see de_model for details
%
% Outputs:
% Con   : connectivity matrix

  % Train connections
  if (isfield(model.ac,'ct'))
      [Con,Wts] = de_connection_trainer(model, model.ac.ct);
  elseif nargout>1
      [Con,Wts] = de_connection_random(model);
  else
      [Con]     = de_connection_random(model);
  end;


%%%%%%%%%%%%%%%%
function [Con,Wts,model,ws] = de_connection_trainer(mSets, ct)
%
% Uses pruning paradigm to create connectivity profile of network.


    % We'll use recursive calls into the system, to make this quicker.
    %   but we'll make sure NOT to call back into this code.

    %%%%%%%%%%%%%%%%%
    % Set up model parameters & allocate space
    %%%%%%%%%%%%%%%%%

    if (~isfield(ct, 'dataset')),   ct.dataset     = 'uber'; end;
    if (~isfield(ct, 'steps')),     ct.steps     = {[8 8 8 8 8] [1 1 1 1 1]}; end;
    if (~isfield(ct, 'iters_per')), ct.iters_per = {ct.iters_per_step(1)*ones(size(ct.steps{1})) ...
                                                    ct.iters_per_step(2)*ones(size(ct.steps{2}))}; end;

    model.debug                = mSets.debug;

    model.nConnPerHidden_Start = 2*mSets.nConns;
    model.nConnPerHidden_End   = mSets.nConns;
    model.distn                = mSets.distn;
    model.mu                   = mSets.mu;
    model.sigma                = max(mSets.sigma);
    model.nHidden              = mSets.nHidden;
    model.hpl                  = mSets.hpl;

    % stim props
    model.nInput               = mSets.nInput;
    model.nOutput              = prod(model.nInput);
    model.zscore               = isfield(model, 'zscore') && model.zscore;

    ws.sz                      = mSets.nInput;
    ws.dataset                 = ct.dataset;
    ws.iters_per               = ct.iters_per{mSets.hemi};
    ws.steps                   = ct.steps{mSets.hemi};
    ws.npruning_loops          = ct.npruning_loops;
    ws.prune_loc               = ct.ac.prune_loc;
    ws.prune_strategy          = ct.ac.prune_strategy;
    ws.keep_weights            = ct.keep_weights;%true;

    model.ac            = ct.ac;        % get training args from ct
    model.ac.debug      = mSets.ac.debug;
    model.ac.randState  = mSets.ac.randState;
    model.ac.errorType  = 2;
    model.ac.zscore     = mSets.ac.zscore;
    if (isfield(model.ac, 'EtaInitInit'))
        model.ac.EtaInit    = model.ac.EtaInitInit/sqrt(ws.steps(1)); %lol
    end;
    model.ac.useBias    = 1;
    model.ac.continue   = true;
    model.ac.tol        = mSets.ac.tol;
    model.ac.minmax     = [];

%    model.ac.noise_input= ct.ac.noise_input;

    %%%%%%%%%%%%%%%%%
    % Check if this connectivity profile has been cached
    %%%%%%%%%%%%%%%%%

    model.data.opt = mSets.data.opt; % for caching purposes only
    model.ac.MaxIterations  = sum(ws.iters_per);
    model.nConns   = model.nConnPerHidden_End;

    connFile       = de_GetOutFile(model, 'conn', ws);

    if (exist(connFile))
        fprintf('found cached connection');
        load(connFile, 'model');

    else
        if (isfield(model.ac, 'randState'))
            rand('seed', model.ac.randState);
            randn('seed', model.ac.randState);
        end;

        %%%%%%%%%%%%%%%%%
        % Set up model parameters & allocate space
        %%%%%%%%%%%%%%%%%

        for ii=1:length(ws.iters_per)
            ws.filters{ii} = fspecial('gaussian', [ws.steps(min(end,ii)) ws.steps(min(end,ii))], 4);
        end;


        if (ismember(10,model.debug))
            fprintf('\nCreating network...');
        end;

        switch(ws.dataset)
            case {'c' 'cafe'    'young_bion_1981'},     [~, ws.train, ws.test] = de_MakeDataset('young_bion_1981',     '', '', mSets.data.opt);
            case {'n' 'natimg'  'vanhateren'},          [~, ws.train, ws.test] = de_MakeDataset('vanhateren',          '', '', mSets.data.opt);
            case {'s' 'sergent' 'sergent_1982'},        [~, ws.train, ws.test] = de_MakeDataset('sergent_1982',        '', '', mSets.data.opt);
            case {    'sf'      'christman_etal_1991'}, [~, ws.train, ws.test] = de_MakeDataset('christman_etal_1991', '', '', mSets.data.opt);
            case {'u' 'uber'},                          [~, ws.train, ws.test] = de_MakeDataset('uber',                'original', '', mSets.data.opt);
            case {'f' 'gratings'},                      [~, ws.train, ws.test] = de_MakeDataset('gratings',            '', '', mSets.data.opt);
            otherwise,                                  error('dataset %s NYI', ws.dataset);
        end;

        ws.inPix      = prod(model.nInput);
        ws.nunits     = ws.inPix+model.nHidden+model.nOutput+1;      % Total # of units; +1 for bias

        % Create connectivity matrix.
        %   This can be slow, so only do it if we have to.
        if (~isfield(model, 'Conn'))
            tol = model.ac.tol;
            model.ac.tol     = 0;                % "Promote" needed props for the call into the connector

            model.nConns     = model.nConnPerHidden_Start;
            model.ac.Conn    = de_connector(model);

            model.ac.tol     = tol;
            ws.Conn_init     = model.ac.Conn; % to detect changes in connectivity
        end;

        % Add random weights
        %   Only do this if the weights don't exist
        %   So, if we comment out the 'clear' above,
        %   We can re-run the script and continue training
        %   the previous model.
        if (~isfield(model.ac, 'Weights'))
            model.ac.Weights = (model.ac.WeightInitScale)*sprandn(model.ac.Conn);
        end;



        %%%%%%%%%%%%%%%%%
        % Train the model
        %%%%%%%%%%%%%%%%%

        fprintf('\nTraining h=%d k=%d...\n', mSets.hemi, ws.steps(1));


        for ii=1:length(ws.iters_per)
            model.ac.MaxIterations = ws.iters_per(ii);

            in2hu_w  = full(abs(model.ac.Weights(ws.inPix+1+[1:model.nHidden], 1:ws.inPix))); %input->hidden weight matrix
            if (ismember(10, model.debug))
                w_minmax = [min(in2hu_w(:))  max(in2hu_w(:))]
            end;

            if (ismember(10, model.debug))
                fprintf('\nTraining for %d epochs [%d:%d of %d]:\n', ...
                        model.ac.MaxIterations, ...
                        1+sum(ws.iters_per(1:ii-1)), ...
                        sum(ws.iters_per(1:ii)), ...
                        sum(ws.iters_per));
            end;

            % Filter the images
            if (ii==1 || diff(ws.steps(ii+[-1 0]))~=0)
                %fprintf('[making filtered images]');
                f = filt_imgs( ws.train.X, ws.train.nInput, ws.filters{ii} );
            end;

            %if (ii>1)
            %    model.ac.EtaInit    = model.ac.EtaInit*ws.steps(ii)/ws.steps(ii-1);
            %end;%ws.steps(1)*model.ac.EtaInitInit; %lol
            % Create training dataset from blurred images
            if (model.nConnPerHidden_End==model.nConnPerHidden_Start)
                model.ac.lambda = 0;
            end;
    %        model.absmean = 1.26E-2;
    %        model.minmax  = [];
    %        dset.train     = de_NormalizeDataset( ws.train, model);
    %        dset.test      = de_NormalizeDataset( ws.test, model);
            dset          = struct('X', f, 'name',sprintf('k=%d',ws.steps(ii)));
            dset          = de_NormalizeDataset(dset, model);
            X             = dset.X;               % Input vectors;  [pixels examples]
            Y             = dset.X(1:end-1,:);    % everything but the bias
            %clear('dset','f');

    %if (max(abs(Y(:)))>=1), error('X unexpectedly high'); end;
    %keyboard
            [model.ac,o_p]       = guru_nnTrain(model.ac, X, Y);
    %        model.data = dset;
    %        model = de_DE(model);
            model.ac.EtaInit     = model.ac.Eta;   % preserve training info for next time around
    %        model = rmfield(model, 'Eta');

            nConnCurr      = (nnz(model.ac.Conn)-model.nHidden-model.nOutput);
            nConnPerHidden = nConnCurr/model.nHidden/2;   %2 because input&output

            % No pruning requsted (sometimes done for comparison)
            if (model.nConnPerHidden_End==nConnPerHidden), continue; end;

            % Determine how many connections must go
            reductRate     = exp(log(model.nConnPerHidden_End/nConnPerHidden)/(ws.npruning_loops-ii+1));
            nout = round( (1-reductRate) * nConnPerHidden * model.nHidden * 2 );
            nout = nout - mod(nout,2); % must be even, so as we remove hidden->input and hidden->output pairs
            guru_assert( ~isnan(nout), 'Failure to calculate # to prune; probably should have exited pruning loop earlier...' );
            guru_assert( (nConnCurr-nout)>=model.nConnPerHidden_End*model.nHidden*2, 'Don''t remove too many connections!!');

            % Select connections to query
            switch (ws.prune_loc)
                case 'input'
                    in2hu_c  = model.ac.Conn   (ws.inPix+1+[1:model.nHidden], 1:ws.inPix); %input->hidden connection matrix
                    in2hu_w  = model.ac.Weights(ws.inPix+1+[1:model.nHidden], 1:ws.inPix); %input->hidden weight matrix

                case 'output'
                    in2hu_c  = model.ac.Conn   (ws.inPix+1+model.nHidden+[1:ws.inPix], ws.inPix+1+[1:model.nHidden])'; %input->hidden connection matrix
                    in2hu_w  = model.ac.Weights(ws.inPix+1+model.nHidden+[1:ws.inPix], ws.inPix+1+[1:model.nHidden])'; %input->hidden weight matrix
            end;

            % Create some metric for selecting weights
            switch (ws.prune_strategy)
                case 'weights'
                    in2hu_a = in2hu_w;

                case 'weighted_weights' % weight size, relative to total weights
                    total_w  = sum(in2hu_w,1);                                 % Normalize weights by
                    in2hu_a  = in2hu_w ./ repmat(total_w, [model.nHidden 1]);   % total weight to that input position

                case 'activity'
                    avg_inp = mean(abs(squeeze(o_p(end,1:ws.inPix,:))),2);
                    in2hu_a = in2hu_w.*repmat(avg_inp', [model.nHidden 1]);
            end;

            % Now actually select the weights to remove
            nzai     = find(in2hu_a);                                           %find actual connections
            nza      = abs(in2hu_a(nzai));                                      %find actual weights
            [a,aidx] = sort(nza);                                               %get weight values and indices, smallest first.  Indices are into nzwi vector

            nConnPerInput    = sum(in2hu_c);
            nadjust = 0;
            while (nadjust < (nConnCurr-nout/2))
                tv       = a(nout/2);                                               % threshhold value to remove HALF the connections (because the other half are on the output)

                % Indices are sorted, and there may be too many weights at the tv to cut them all.
                %   So, add them back in, then cut.
                tal       = find(a(1:(nout/2))==tv);                                 % threshhold value weights (that are to-be-cut), in "local" indices
                taf       = find(a==tv);                                             % threshhold value weights (both cut and not), in "full" indices
                itot      = randperm(length(taf));                                   %   "sort" sorts indices as well (for equivalent values),

                aidx(taf) = aidx(taf(itot));                                         %   so we're biased to prune weights on earlier hidden units this code re-randomizes, to avoid this.

                % Now we're unbiased for the threshhold value,
                %   so we're good to select

                bcil     = aidx(1:(nout/2));                                        % "bad connections" indices (in "local" vector of non-zero connections)

                % Now check that we haven't eliminated too many
                [huidx,inidx]    = ind2sub(size(in2hu_c), nzai(bcil));   % Get indices of input nodes from original weight matrix
                nConnOutPerInput = histc(inidx,1:length(nConnPerInput)); %this is sorted,so indexing should match up
                guru_assert(~any((nConnPerInput' - nConnOutPerInput)<0), 'Negative number of connections??');

                zero_conns = (nConnPerInput' - nConnOutPerInput)==0;
                if (model.ac.nzc_ok || ~any(zero_conns)), break; end;

                % eliminated too many;
                %   we should push these to the end of the array to remove
                %
                fprintf('[anticipating %d zero-conn inputs; adjusting...]', sum(zero_conns));

                toremove = find(zero_conns); % absolute input index
                rmvidx = [];
                for zi=1:length(toremove)
                    iidx   = toremove(zi);     % index of input node
                    allidx = find(inidx==iidx); % all indices of weights from this input

                    [~,zzz]=ind2sub(size(in2hu_c),nzai(aidx(allidx)));
                    guru_assert(all(zzz==iidx), 'Just checking our indexing'); % make sure we indexed properly

                    rmvidx = [rmvidx allidx(end)]; % allow pruning of all but one by remove largest-weighted one from possible pruning list
                end;

                newidx = setdiff(1:length(a), rmvidx);
                a = a(newidx);
                aidx = aidx(newidx);

                nadjust = nadjust + length(rmvidx);
            end;

            % Remove the weights!
            in2hu_c(nzai(bcil)) = false;                                          %
            clear('in2hu_a','nza','a','aidx');
            clear('itot', 'tal','taf');

            alllyrs = sum(in2hu_c);
            n_zero_conns = length(find(alllyrs==0));
            guru_assert(model.ac.nzc_ok || (n_zero_conns == 0), 'We got non-connected input/outputs (and we said EXPLICITLY that that was not OK!');
            guru_assert(model.ac.tol >= n_zero_conns/prod(model.nInput), sprintf('Not within specified tolerance for non-zero connections %d > %d', n_zero_conns, round(model.ac.tol*ws.inPix)));


            % Push the information back into the original
            %   connection and weight matrices
            model.ac.Conn(ws.inPix+1+[1:model.nHidden], 1:ws.inPix) = in2hu_c;     % apply to models' input->hidden connections
            model.ac.Conn(ws.inPix+1+model.nHidden+[1:model.nOutput], ws.inPix+1+[1:model.nHidden]) = in2hu_c'; %apply to model's hidden->output connections

            model.ac.Weights(ws.inPix+1+[1:model.nHidden], 1:ws.inPix) = in2hu_c .* model.ac.Weights(ws.inPix+1+[1:model.nHidden], 1:ws.inPix);
            model.ac.Weights(ws.inPix+1+model.nHidden+[1:model.nOutput], ws.inPix+1+[1:model.nHidden]) = in2hu_c' .* model.ac.Weights(ws.inPix+1+model.nHidden+[1:model.nOutput], ws.inPix+1+[1:model.nHidden]);
            clear('in2hu_c');

            model.nConns = round( (nConnCurr-nout)/model.nHidden/2 ); 		% Re-estimate the current # of connections per hidden unit


            % Validate that the input & output layers are symmetric
            cc_in  = full(model.ac.Conn(ws.inPix+1              +[1:model.nHidden],          1:ws.inPix));
            cc_out = full(model.ac.Conn(ws.inPix+1+model.nHidden+[1:ws.inPix],   ws.inPix+1+[1:model.nHidden]));
            guru_assert(~any(diff(sum(cc_in,2)' - sum(cc_out,1))), 'Input and output layers are not symmetric??');
            clear('cc_in', 'cc_out');

            % Report threshhold value
            if (ismember(10, model.debug))
                tv
            end;

            % Report the maximum weight size removed
            w_out = in2hu_w(nzai(bcil));
            max_w_out = max(abs(w_out(:)));
            if (strcmp(ws.prune_strategy, 'weights'))
                guru_assert(max_w_out == tv, 'Maximum weight removed should be equal to computed threshhold value.');
            end;
            if (ismember(10, model.debug))
                max_w_out
            end;
            clear('w_out','max_w_out');
            clear('in2hu_w','nzai','bcil');

            % Report on how many non-zero connections have been introduced
            alllyrs = squeeze(sum(reshape(full(model.ac.Conn(ws.inPix+1+[1:model.nHidden], 1:ws.inPix)), [model.nHidden model.nInput])));
            n_zero_conns = length(find(alllyrs==0));
            if (n_zero_conns>0 || ismember(10, model.debug))
                n_zero_conns
            end;
            clear('alllyrs');

            % Report on whether there are no weird biases in where we're pruning
            cc     = model.ac.Conn(ws.inPix+1+[1:model.nHidden], 1:ws.inPix);
            nc     = full(sum(cc,2))'; %# connection per input
            nc_div = round(linspace(1, length(nc), 4));%[round(1:(length(nc)/3):length(nc)) length(nc)];
            fprintf('\t# connections(avg):  [%4.1f %4.1f %4.1f] (expected: %4.1f)\n', ...
                    mean( nc(nc_div(1):(nc_div(2)-1)) ), ...
                    mean( nc(nc_div(2):(nc_div(3)-1)) ), ...
                    mean( nc(nc_div(3):(nc_div(4)  )) ), ...
                    (nConnCurr-nout)/model.nHidden/2 ); %output ordered by input unit #
            clear('cc','nc','nc_div');
        end;

        % too lazy
        guru_assert( n_zero_conns/ws.inPix<=model.ac.tol, 'Within connectivity tolerance' );
    end;

    % Make sure that all pruning has completed, and as expected
    nConnCurr      = (nnz(model.ac.Conn)-model.nHidden-model.nOutput);
	guru_assert( nConnCurr==model.nConnPerHidden_End*model.nHidden*2, 'Remove exactly the right # of connections!!');

    %%%%%%%%%%%%%%%%%
    % Analyze/verify the model
    %%%%%%%%%%%%%%%%%

    % Save here so that we can validate both loaded and trained models,
    %   but also be able to cache.
    if (~exist(connFile))
        if (~exist(guru_fileparts(connFile,'path'),'dir'))
            mkdir(guru_fileparts(connFile,'path'));
        end;
        save(connFile, 'model', 'ws');
    end;

    %keyboard

    ipd = de_StatsInterpatchDistance({model})


    %%%%%%%%%%%%%%%%%
    % Extract connections & weights
    %%%%%%%%%%%%%%%%%

    Con = model.ac.Conn;

    if (ws.keep_weights)
        Wts = model.ac.Weights;
    elseif (nargout > 1)
        Wts = model.ac.WeightInitScale*guru_nnInitWeights(Con, model.ac.WeightInitType);
    end;




%%%%%%%%%%%%%%%%
function [Con,Wts] = de_connection_random(model)

  if (isfield(model.ac, 'randState'))
      rand('seed', model.ac.randState);
      randn('seed', model.ac.randState);
  end;

  switch length(model.nInput)
    case 1, error('1D NYI');
    case 2
      if (isfield(model,'useold_connector') && model.useold_connector)
          fprintf('[Using old connector]\n');
          [Con, mu] = de_connector2D_old(model.nInput, ...
                                          model.nHidden, ...
                                          model.hpl,...
                                          model.nConns,...
                                          model.distn{1}, ...
                                          model.mu,...
                                          model.sigma,...
                                          model.ac.debug, ...
                                          model.ac.tol);
                if (model.ac.debug), fprintf('!'); end;
       else
          [Con, mu] = de_connector2D(model.nInput, ...
                                          model.nHidden, ...
                                          model.hpl,...
                                          model.nConns,...
                                          model.distn{1}, ...
                                          model.mu,...
                                          model.sigma,...
                                          model.ac.debug, ...
                                          model.ac.tol);
                if (model.ac.debug), fprintf('!'); end;
       end;

    otherwise
        nPix         = prod(model.nInput(1:2));
        nInputLayers = prod(model.nInput(3:end));
        nHidPerLayer = model.nHidden/nInputLayers;
        Con = spalloc( 2*prod(model.nInput) + model.nHidden, 2*prod(model.nInput) + model.nHidden, 2*model.nHidden*nConns + 2*prod(model.nInput)+model.nHidden );

        for i=1:nInputLayers

            [C, mu] = de_connector2D(model.nInput(1:2), ...
										  model.nHidden/nInputLayers, ...
										  model.hpl,...
										  model.nConns,...
										  model.distn{1}, ...
										  model.mu,...
										  model.sigma,...
										  model.ac.debug, ...
										  model.ac.tol);

            Con( prod(model.nInput) + (i-1)*nHidPerLayer + [1:nHidPerLayer], (i-1)*nPix+[1:nPix]) = C(nPix+[1:nHidPerLayer],[1:nPix]); %Input->Hidden
            Con( prod(model.nInput) +model.nHidden + (i-1)*nPix + [1:nPix], prod(model.nInput) + (i-1)*nHidPerLayer + [1:nHidPerLayer]) = C(nPix+nHidPerLayer+[1:nPix], nPix+[1:nHidPerLayer]); %Hidden->Output
		end;
	end;


    % Add bias node connections
    nInput = prod(model.nInput);

    Con = [Con(1:nInput,:); ... % add empty row
             false(1, size(Con,2));  ... %it's the last input
             Con(nInput+1:end, :)];
    Con = [Con(:,1:nInput) ... % add empty column: nobody connects TO bias
             false(size(Con,1),1)  ... %it's the last input
             Con(:,nInput+1:end)];

    Con(nInput+1,nInput+2:end) = (model.ac.useBias~=0); %add row for connections from bias to inputs,hidden,output

    % Initialize weights
    if (nargout > 1)
        Wts = model.ac.WeightInitScale*guru_nnInitWeights(Con, model.ac.WeightInitType);
    end;

