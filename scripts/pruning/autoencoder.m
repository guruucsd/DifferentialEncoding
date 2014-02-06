function [model,ws,s,fs] = autoencoder(model, ws)
       
  if (~exist('model','var')), model = struct(); end;
  if (~exist('ws',   'var')), ws    = struct(); end;
  
  if (~isfield(model, 'lrrev')), model.lrrev = false; end;
  if (~isfield(model, 'randSeed')), model.randSeed = rand; end;

  if exist('rng','file')
    rng(model.randSeed);    %this allows exact same randomization to prune from, for lsf,msf,hsf
  else
    rand('seed',model.randSeed);
    randn('seed',model.randSeed);
  end;


  %%%%%%%%%%%%%%%%%
  % Set up model parameters & allocate space
  %%%%%%%%%%%%%%%%%
  
  fprintf('\nCreating network... [blurring=%s]', guru_cell2str({ws.kernels}));

  ws.fullfidel = create_dataset(ws);
  ws.nInput = ws.fullfidel.nInput;
  ws.inPix = prod(ws.fullfidel.nInput);
  model.nInput = ws.fullfidel.nInput;
  model.nOutput = prod(model.nInput);
  
  % These parameters are large resources
  if (~isfield(model, 'distn')),                model.distn                = {'normem2'}; end;
  if (~isfield(model, 'mu')),                   model.mu                   = 0; end;
  if (~isfield(model, 'nHidden')),              model.nHidden              = 2*680; end;%425;                         % # hidden units in autoencoder  
  if (~isfield(model, 'hpl')),                  model.hpl                  = 2;     end;
  if (~isfield(model, 'sigma')),                model.sigma                = 20; end;
  if (~isfield(model, 'nConnPerHidden_Start')), model.nConnPerHidden_Start = 30; end; % reduce this and below, tomorrow
  if (~isfield(model, 'nConnPerHidden_End')),   model.nConnPerHidden_End   = 15; end;
  if (~isfield(model, 'nConns')),               model.nConns               = model.nConnPerHidden_Start; end;
  %if (~isfield(model, 'linout')),              model.linout               = true; end;
  if (~isfield(model, 'debug')),                model.debug                = 1:10; end;
  if (~isfield(model, 'useBias')),              model.useBias              = 1; end;
  
  
  % Create connectivity matrix.
  %   This can be slow, so only do it if we have to.
  if (~isfield(model, 'Conn'))
      model.ac.tol     = 0;                % "Promote" needed props for the call into the connector
      model.ac.debug   = model.debug;
      model.ac.useBias = model.useBias;
      %model.useold_connector = true;
      model.Conn     = de_connector(model);
      ws.Conn_init   = model.Conn; % to detect changes in connectivity
  end;
  
  % Add random weights
  %   Only do this if the weights don't exist
  %   So, if we comment out the 'clear' above,
  %   We can re-run the script and continue training
  %   the previous model.
  if (~isfield(model, 'Weights'))
      model.Weights = (1/model.nConns/model.nHidden)*sprandn(model.Conn);
  end;
  
  % Set up model training parameters
  if (~isfield(ws, 'iters_per')), ws.iters_per     = 10*ones(5,1); end;%[15 10 8 8 5 4]; end    %floor(TotIterations/nloops);

  if (~isfield(model, 'TrainMode')),     model.TrainMode     = 'resilient'; end;       % 'batch' or 'resilient'
%  if (~isfield(model, 'MaxIterations')), model.MaxIterations = 50;          end;    % # iterations through the training set
  if (~isfield(model, 'AvgError')),      model.AvgError      = 0;           end;    % Stopping criterion (0 means train to max # of iterations)
  if (~isfield(model, 'errorType')),     model.errorType     = 2;           end;    % 1=sum(abs(err)), 2=sum(err.^2)
  if (~isfield(model, 'debug')),         model.debug         = 1:10;        end;    % Some debug flags, for printing information during training
  
  switch model.TrainMode
    case 'batch'
      model.Pow     = 1;              % gradient power; Err = (y-y_hat).^(Pow+1)
      model.EtaInit = 1;              % Learning rate (to start)
      model.Acc     = 1.005;          % Multiplicative increase to eta (when training good)
      model.Dec     = 1.2;            % Divisive decrease to eta (when training goes bad)
      model.XferFn  = [6 1];              % 1.73 * tanh
      model.useBias = 1;
    case 'resilient'
      model.Pow     = 3;              % gradient power; Err = (y-y_hat).^(Pow+1)
      model.EtaInit = 1E-3;          % Learning rate (to start)
      model.Acc     = 5E-5;          % (1+Acc) Multiplicative increase to eta (when training good)
      model.Dec     = 0.25;            % (1-Dec) Multiplicative decrease to eta (when training goes bad)
      model.XferFn  = [6 1];              % 1.73 * tanh
      model.useBias = 1;
  end;
  

  %%%%%%%%%%%%%%%%%
  % Train the model
  %%%%%%%%%%%%%%%%%
  
  fprintf('\nTraining...');
  
  ws.nloops      = length(ws.iters_per);

  % last iteration is training without pruning
  AvgError = model.AvgError;
  for ii=1:ws.nloops
    model.MaxIterations = ws.iters_per(ii);
    model.AvgError = (ii==ws.nloops)*AvgError; %only train to an error criterion on the last loop
    model = guru_rmfield(model, 'Error');

    %% First, create the stimuli for this training run
    fprintf('\nCreating stims...');
    [train,~] = create_dataset(ws, model, ii);
    X = train.X;
    Y = train.X(1:end-1,:);

    %% Next, train the model
    fprintf('\nTraining for %d epochs [%d:%d of %d]:\n', ...
            model.MaxIterations, ...
            1+sum(ws.iters_per(1:ii-1)), ...
            sum(ws.iters_per(1:ii)), ...
            sum(ws.iters_per));
    [model,o_p]       = guru_nnTrain(model, X, Y);
    if (true) % preserve training info for next time around
      model.EtaInit     = model.Eta;   
    else      % restart training parameters
      model = rmfield(model, 'Eta');
    end;


    %% Finally, do the pruning, but ONLY when:
    %   * these values are not equal (no pruning requsted; sometimes done for comparison)
    %   * in the last iteration of the loop (train a bit without pruning)
    if (ii<ws.nloops && model.nConnPerHidden_End~=model.nConnPerHidden_Start)
      model = do_pruning(model, ws, X, o_p, ii);
    end;

  end; % for nloops (of pruning)


  % Make sure that all pruning has completed, and as expected
  nConnCurr      = (nnz(model.Conn)-model.nHidden-model.nOutput);
  guru_assert( nConnCurr==model.nConnPerHidden_End*model.nHidden*2, 'Remove exactly the right # of connections!!');


  %% Do analyses
  [s,fs] = do_analysis(model, ws);



function model = do_pruning(model, ws, X, o_p, ii)

    % Determine how many connections must go
    nConnCurr      = (nnz(model.Conn)-model.nHidden-model.nOutput);
    nConnPerHidden = nConnCurr/model.nHidden/2;   %2 because input&output  
    reductRate     = exp(log(model.nConnPerHidden_End/nConnPerHidden)/(ws.nloops-ii));
    
                nout = round( (1-reductRate) * nConnPerHidden * model.nHidden * 2 );
    nout = nout - mod(nout,2); % must be even, so as we remove hidden->input and hidden->output pairs
    if ismember(11,model.debug), fprintf('\n (nout=%d, reductRate=%f, nConnPerHidden=%f,nConnCurr=%d)', nout, 1-reductRate, nConnPerHidden, nConnCurr); end;
    guru_assert( (nConnCurr-nout)>=model.nConnPerHidden_End*model.nHidden*2, 'Don''t remove too many connections!!');
            
    % Select connections to query
    switch (ws.prune_loc)
      case 'input'
        pix2hu_c  = model.Conn   (ws.inPix+1+[1:model.nHidden], 1:ws.inPix); %input->hidden connection matrix
        pix2hu_w  = model.Weights(ws.inPix+1+[1:model.nHidden], 1:ws.inPix); %input->hidden weight matrix
      
      case 'output'
        pix2hu_c  = model.Conn   (ws.inPix+1+model.nHidden+[1:ws.inPix], ws.inPix+1+[1:model.nHidden])'; %hidden->output connection matrix
        pix2hu_w  = model.Weights(ws.inPix+1+model.nHidden+[1:ws.inPix], ws.inPix+1+[1:model.nHidden])'; %hidden->output weight matrix

      otherwise, error('unknown pruning location: %s', prune_loc);
    end;
  
    % Create some metric for selecting weights
    switch (ws.prune_strategy)
      case 'weights' %raw weight
        pix2hu_a = pix2hu_w;

      case 'weighted_weights' % weight size, relative to total weights at that hidden unit
        total_w   = sum(pix2hu_w,1);                                 % Normalize weights by
        pix2hu_a  = pix2hu_w ./ repmat(total_w, [model.nHidden 1]);  % total weight to that pixel

      case 'activity' %most active connections (input*weight)
        avg_inp = mean(abs(squeeze(o_p(end,1:ws.inPix,:))),2);

        pix2hu_a = pix2hu_w.*repmat(avg_inp', [model.nHidden 1]);

      case 'pctactivation' %[hu act]*[hu wt]/[sum[hu_act]*[hu_wt]] : % output activity from this connection
        huacts = mean(squeeze(o_p(end,(ws.inPix+1)+[1:model.nHidden],:)),2);
        cxnacts = repmat(huacts,[1 ws.inPix]).*pix2hu_w;
        wtd_sum = sum(cxnacts,1);
        %outacts = mean(squeeze(o_p(end,ws.inPix+1+model.nHidden+[1:ws.inPix],:)),2);

        pctact= abs(cxnacts ./ repmat(wtd_sum, [model.nHidden 1]));
        %pctact(1,:) %all outputs activated by hidden unit 1
        pix2hu_a = pctact;

      case 'ltd' % remove connections least similar to the output activation
        huacts = squeeze(o_p(end,(ws.inPix+1)+[1:model.nHidden],:));
        cxnacts = repmat(full(huacts)',[1 1 ws.inPix]).*permute(repmat(full(pix2hu_w), [1 1 100]),[3 1 2]);
        %outacts = squeeze(o_p(end,ws.inPix+1+model.nHidden+[1:ws.inPix],:));
        inacts = X(1:ws.inPix,:);%squeeze(o_p(end,1:ws.inPix,:)); % input activations; we want to prune based on DESIRED outputs (which are the inputs!)

        diff_per_img = (emo_trnsfr(model.XferFn(end),cxnacts)-permute(repmat(inacts,[1 1 model.nHidden]), [2 3 1])); % must be abs; we care about magnitude of difference only.  And we need 1/#, because small difference is desirable, and we remove smallest things
        pix2hu_a = squeeze(1./sum(abs(diff_per_img),1)) .* in2hu_c; %we'll get answers for all connections (even ones that don't exist, but 'should' be contributing)

      otherwise, error('unknown pruning strategy: %s', prune_strategy);
    end;
    
    % Now actually select the weights to remove
    nzai     = find(pix2hu_a);                                          %find actual connections
    nza      = pix2hu_a(nzai);                                          %find actual weights
    [a,aidx] = sort(abs(nza));                                          %get weight values and indices, smallest first.  Indices are into nzwi vector
    bcil     = aidx(1:(nout/2));                                        % "bad connections" indices (in "local" vector of non-zero connections)
    tv       = a(nout/2);                                               % threshhold value to remove HALF the connections (because the other half are on the output)

    tal      = find(abs(a(1:(nout/2)))==tv);                            % threshhold value weights that are cut, in "local" indices
    taf      = find(abs(nza)==tv);                                      % threshhold value weights, both cut and not, in "full" indices
    if ( length(tal) < length(taf) )                                    % Are any weights NOT cut, but at the same threshhold?  Because,
      itot = randperm(length(taf));                                   %   "sort" sorts indices as well (for equivalent values), 
      bcil((end-length(tal)+1):end) = taf(itot(1:length(tal)));       %   so we're biased to prune weights on earlier hidden units this code re-randomizes, to avoid this.
    end;
    clear('pix2hu_a','nza','a','aidx');
    clear('itot','tal','taf');
    
    % Remove the weights!
    pix2hu_c(nzai(bcil)) = false;                                          %
    

    % Push the information back into the original
    %   connection and weight matrices
    model.Conn(ws.inPix+1+[1:model.nHidden], 1:ws.inPix) = pix2hu_c;     % apply to models' input->hidden connections
    model.Conn(ws.inPix+1+model.nHidden+[1:model.nOutput], ws.inPix+1+[1:model.nHidden]) = pix2hu_c'; %apply to model's hidden->output connections

    model.Weights(ws.inPix+1+[1:model.nHidden], 1:ws.inPix) = pix2hu_c .* pix2hu_w;%model.Weights(ws.inPix+1+[1:model.nHidden], 1:ws.inPix);
    model.Weights(ws.inPix+1+model.nHidden+[1:model.nOutput], ws.inPix+1+[1:model.nHidden]) = pix2hu_c' .* pix2hu_w';%model.Weights(ws.inPix+1+model.nHidden+[1:model.nOutput], ws.inPix+1+[1:model.nHidden]);
    clear('pix2hu_c');
  
    model.nConns = round( (nConnCurr-nout)/model.nHidden/2 ); 		% Re-estimate the current # of connections per hidden unit


    % Validate that the input & output layers are symmetric
    cc_in  = full(model.Conn(ws.inPix+1              +[1:model.nHidden],          1:ws.inPix));
    cc_out = full(model.Conn(ws.inPix+1+model.nHidden+[1:ws.inPix],   ws.inPix+1+[1:model.nHidden]));
    guru_assert(~any(any(cc_in-cc_out')));
    clear('cc_in');


    % Report the maximum weight size removed
    w_out = pix2hu_w(nzai(bcil));
    max_w_out = max(abs(w_out(:)));
    clear('w_out');
    clear('pix2hu_w','nzai','bcil');
      
    % Report on how many non-zero connections have been introduced
    n_zero_c2p = sum(sum(cc_out,2)==0); % # output pixels with no connections
    n_zero_c2h = sum(sum(cc_out,1)==0); % # hidden units with no connections %length(find(alllyrs==0));
      
    % Report on all at once
    fprintf('\ntv=%5.4e, max_w_out=%5.4e, orphaned_pixels=%5d, orphaned_hus=%5d', full(tv), full(max_w_out), n_zero_c2p, n_zero_c2h);
    clear('tv','max_w_out','n_zero_c2p', 'n_zero_c2h')
    
    
    % Report on whether there are no weird biases in where we're pruning
    %cc     = model.Conn(ws.inPix+1+[1:model.nHidden], 1:ws.inPix);
    %nc     = full(sum(cc,2))'; %# connection per input
    %nc_div = round(linspace(1, length(nc), 4));%[round(1:(length(nc)/3):length(nc)) length(nc)];
    %fprintf('\t# connections(avg):  [%4.1f %4.1f %4.1f] (expected: %4.1f)\n', ...
    %		mean( nc(nc_div(1):(nc_div(2)-1)) ), ...
    %		mean( nc(nc_div(2):(nc_div(3)-1)) ), ...
    %		mean( nc(nc_div(3):(nc_div(4)  )) ), ...
    %		(nConnCurr-nout)/model.nHidden/2 ); %output ordered by input unit #
    %clear('cc','nc','nc_div');
    
    
    
    
function [s,fs] = do_analysis(model, ws)

  %%%%%%%%%%%%%%%%%
  % Analyze the model
  %%%%%%%%%%%%%%%%%
  
  fprintf('\nComparing...');
  
    
  % 1. Train & test set errors for final iteration
  [train,test] = create_dataset(ws, model, ws.nloops);
  X_train = train.X;
  Y_train = train.X(1:ws.inPix,:);
	X_test  = test.X;                % Input vectors;  [pixels examples]
	Y_test  = test.X(1:ws.inPix,:);   % everything but the bias
  clear('train','test');
  
  [o_p]      = guru_nnExec(model, X_train, Y_train);
  s.rimgs.train = o_p;%(1+ws.inPix+model.nHidden+[1:model.nOutput], :);  % Reconstructed images
  [o_p]      = guru_nnExec(model, X_test, Y_test);
  s.rimgs.test  = o_p;%(1+ws.inPix+model.nHidden+[1:model.nOutput], :);  % Reconstructed images
  
  % Test set error
  fprintf('\nTest set error: %7.3e [vs. training error %7.3e]\n', ...
      sum(sum(emo_nnError(model.errorType, Y_test  - s.rimgs.test)))/numel(Y_train), ...
      sum(sum(emo_nnError(model.errorType, Y_train - s.rimgs.train)))/numel(Y_train));
  clear('o_p');

  
  % 2.Reconstructed images
  
  % Plot two sample images; original and reconstructed
  
  rcf = figure;
  cb_orig = [min(Y_train(:)) max(Y_train(:))];
  cb_rcon = cb_orig; %[min(f(:))          max(f(:))];

  % Original train images    
  subplot(4,3,1); colormap(gray(256)); axis image; imagesc(reshape(Y_train(:,1), ws.nInput),   cb_orig); colorbar; set(gca,'xtick', [], 'ytick', []);
  subplot(4,3,2); colormap(gray(256)); axis image; imagesc(reshape(Y_train(:,round(end/2)), ws.nInput),   cb_orig); colorbar; set(gca,'xtick', [], 'ytick', []);
  subplot(4,3,3); colormap(gray(256)); axis image; imagesc(reshape(Y_train(:,end), ws.nInput), cb_orig); colorbar; set(gca,'xtick', [], 'ytick', []);

  % Recon train images
  subplot(4,3,4); colormap(gray(256)); axis image; imagesc(reshape(s.rimgs.train(:,1), ws.nInput),   cb_rcon); colorbar; set(gca,'xtick', [], 'ytick', []); 
  subplot(4,3,5); colormap(gray(256)); axis image; imagesc(reshape(s.rimgs.train(:,round(end/2)), ws.nInput),  cb_rcon); colorbar; set(gca,'xtick', [], 'ytick', []); 
  subplot(4,3,6); colormap(gray(256)); axis image; imagesc(reshape(s.rimgs.train(:,end), ws.nInput), cb_rcon); colorbar; set(gca,'xtick', [], 'ytick', []); 
  
  % Original test images
  subplot(4,3,7); colormap(gray(256)); axis image; imagesc(reshape(Y_test(:,1), ws.nInput),   cb_orig); colorbar; set(gca,'xtick', [], 'ytick', []);
  subplot(4,3,8); colormap(gray(256)); axis image; imagesc(reshape(Y_test(:,round(end/2)), ws.nInput),  cb_orig); colorbar; set(gca,'xtick', [], 'ytick', []);
  subplot(4,3,9); colormap(gray(256)); axis image; imagesc(reshape(Y_test(:,end), ws.nInput), cb_orig); colorbar; set(gca,'xtick', [], 'ytick', []);
  
  % Recon test images
  subplot(4,3,10); colormap(gray(256)); axis image; imagesc(reshape(s.rimgs.test(:,1), ws.nInput),   cb_rcon); colorbar; set(gca,'xtick', [], 'ytick', []); 
  subplot(4,3,11); colormap(gray(256)); axis image; imagesc(reshape(s.rimgs.test(:,round(end/2)), ws.nInput),  cb_rcon); colorbar; set(gca,'xtick', [], 'ytick', []); 
  subplot(4,3,12); colormap(gray(256)); axis image; imagesc(reshape(s.rimgs.test(:,end), ws.nInput), cb_rcon); colorbar; set(gca,'xtick', [], 'ytick', []); 
  
 % s.model = de_StatsFFTs( s.rimgs.train, ws.nInput );
  
  
  % 3. Connectivity plot
  cnf = figure;
  hu1 = round(model.nHidden/model.hpl / 4);
  hu2 = round(model.nHidden/model.hpl / 3);
  
  [~,ws.mupos] = de_connector_positions(model.nInput, model.nHidden/model.hpl);
  
  subplot(2,2,1); hold on;
  conn_img = reshape(ws.Conn_init (ws.inPix+1+hu1, 1:ws.inPix), model.nInput);
  imagesc(conn_img); axis image; set(gca,'xtick',[],'ytick',[]); 
  plot(ws.mupos(hu1,2), ws.mupos(hu1,1), 'g*');
  
  title(sprintf('orig #1 (%d conns)', nnz(conn_img)));
  
  subplot(2,2,2); hold on;
  conn_img = reshape(model.Conn(ws.inPix+1+hu1, 1:ws.inPix), model.nInput);
  imagesc(conn_img); axis image; set(gca,'xtick',[],'ytick',[]); 
  plot(ws.mupos(hu1,2), ws.mupos(hu1,1), 'g*');
  title(sprintf('end #1 (%d conns)', nnz(conn_img)));
  
  subplot(2,2,3); hold on;
  conn_img = reshape(ws.Conn_init (ws.inPix+1+hu2, 1:ws.inPix), model.nInput);
  imagesc(conn_img);  axis image; set(gca,'xtick',[],'ytick',[]); 
  plot(ws.mupos(hu2,2), ws.mupos(hu2,1), 'g*');
  title(sprintf('orig #2 (%d conns)', nnz(conn_img)));
  
  subplot(2,2,4); hold on;
  conn_img = reshape(model.Conn(ws.inPix+1+hu2, 1:ws.inPix), model.nInput);
  imagesc(conn_img);  axis image; set(gca,'xtick',[],'ytick',[]); 
  plot(ws.mupos(hu2,2), ws.mupos(hu2,1), 'g*');
  title(sprintf('end #2 (%d conns)', nnz(conn_img)));
    
  
  % 4. Connectivity stats
  s.dist_orig = cell(model.nHidden,1);
  s.dist_end  = cell(model.nHidden,1);
  [~,ws.mupos] = de_connector_positions(model.nInput, model.nHidden/model.hpl);
  
  s.dist_avg_o = zeros(model.nHidden,1);
  s.dist_avg_e = zeros(model.nHidden,1);
  
  
  for hi=1:model.hpl
      for ii=1:(model.nHidden/model.hpl)
          hui = (hi-1)*model.nHidden/model.hpl + ii;
          
          conns_orig = reshape(ws.Conn_init(ws.inPix+1+hui, 1:ws.inPix), model.nInput);
          conns_end  = reshape(model.Conn  (ws.inPix+1+hui, 1:ws.inPix), model.nInput);
      
          [y_o,x_o] = find(conns_orig);
          [y_e,x_e] = find(conns_end);
  
          s.dist_orig{hui} = zeros(length(y_o),1);
          s.dist_end {hui} = zeros(length(y_e),1);
  
          s.dist_orig{hui} = sqrt(sum( ([y_o x_o] - repmat(ws.mupos(ii,:), [length(y_o) 1])).^2, 2));
          s.dist_end {hui} = sqrt(sum( ([y_e x_e] - repmat(ws.mupos(ii,:), [length(y_e) 1])).^2, 2));
          
          s.dist_avg_o(hui) = mean(s.dist_orig{ii});
          s.dist_avg_e(hui) = mean(s.dist_end {ii});
      end;
  end;
  
%    fprintf('Mean:   %6.4e => %6.4e\n', mean  (s.dist_avg_o),   mean(s.dist_avg_e));
%    fprintf('Median: %6.4e => %6.4e\n', median(s.dist_avg_o), median(s.dist_avg_e));
%    fprintf('Std:    %6.4e => %6.4e\n', std   (s.dist_avg_o),    std(s.dist_avg_e));
  
  
  % Plot them
  hsf = figure;
  subplot(3,1,1);
  s.d_o = hist(vertcat(s.dist_orig{:}), 25);
  s.d_o = s.d_o ./ sum(s.d_o);
  bar(s.d_o);
  title('Orig: Histogram of distances from center');
  
  subplot(3,1,2);
  s.d_e = hist(vertcat(s.dist_end{:}), 25);
  s.d_e = s.d_e ./ sum(s.d_e);
  bar(s.d_e);
  title('End: Histogram of distances from center');
  
  subplot(3,1,3);
  bar( s.d_e - s.d_o );
  title('Histogram difference (pos means more AFTER)');
  


  % Wait to do all saving until the end, for parallel purposes
	fs = cell(4,1);
  if (nargout == 1)
      fs{1} = 'z_recon.png';
      fs{2} = 'z_conn.png';
      fs{3} = 'z_hist.png';
      fs{4} = 'model.mat';
  else
      fs{1} = [tempname() '.png'];
      fs{2} = [tempname() '.png'];
      fs{3} = [tempname() '.png'];
      fs{4} = [tempname() '.mat'];
  end;
  
  saveas(rcf,fs{1},'png');
  saveas(cnf,fs{2},'png');
  saveas(hsf,fs{3}, 'png');

  save(fs{4}, 'model', 'ws', 's', 'fs');

