function [an] = collect_data(dirname, resave)
%

  if ~exist('resave','var'), resave = false; end;
  if ~exist(dirname,'file'), error('Could not find directory: %s', dirname); end;
      
  files = dir(fullfile(dirname,'*.mat'))
  an.n = length(files);
  
  % Load all data
  warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
  blobs = cell(an.n,1);
  for fi=1:an.n
      b = load(fullfile(dirname, files(fi).name));

      b.data.E_pat = b.data.E_pat/b.net.sets.dt;
      
      % reconstruct indices, for symmetric/asymmetric experiments
      if ~isfield(b.pats.idx, 'intra')
          b.pats.idx.intra = 1:b.pats.train.npat;
          b.pats.idx.inter = [];
          if resave, 
              net=b.net; pats=b.pats; data=b.data;
              fprintf('%d ', fi);
              save(fullfile(dirname, files(fi).name), 'net','pats','data');
          end;
          clear('net', 'pats', 'data');
      end;
      
      % reconstruct functions
      if false
          try
              b.net.fn.sse(1,1);
          catch
              fprintf('reconstituting...\n');
              b.net.fn.sse  = @(y,d)   (0.5.*(y-d).^2);
              b.net.fn.Err  = @(y,d)   (b.net.fn.sse(y,d));
              b.net.fn.Errp = @(y,d,p) ((y-d).^p);
              b.net.fn.f      = @(x)    ((exp(x)-exp(-x)) ./ (exp(x)+exp(-x)));
              b.net.fn.fp     = @(x,fx) (1-fx.^2);
              b.net.fn.fo     = @(x)    (1.7159*(2 ./ (1 + exp(-2 * 2*x/3)) - 1));
              b.net.fn.fpo    = @(x,fx) (1.7159*2/3*(1 - (fx/1.7159).^2));
          end;

          % Paste on extra info, if not already there
          if true || ~isfield(b.data, 'noise')
              net=b.net; pats=b.pats; data=b.data;
              data.an = r_analyze(net, pats, data);
              net.continue=true;
              net.sets.axon_noise=0;
              keyboard
              [net,pats_new,data_new] = r_main(net);
              data    = r_test(net, pats, data);
              data.an = r_analyze(net, pats, data);
              if resave, 
                  fprintf('%d ', fi);
                  save(fullfile(dirname, files(fi).name), 'net','pats','data');
              end;
              clear('net', 'pats', 'data');
          end;
      end;
      blobs{fi} = b;
  end;
  
  % Useful constants
  an.ts.niters = b.net.sets.niters;
  an.ts.lesion = [100:100:an.ts.niters];
  an.ts.intact = [1 an.ts.lesion];
  
  % Allocate space
  an.intra.intact.err = nan(length(blobs), an.ts.niters);
  an.inter.intact.err = nan(length(blobs), an.ts.niters);
  an.intra.lesion.err = nan(length(blobs), length(an.ts.lesion));
  an.inter.lesion.err = nan(length(blobs), length(an.ts.lesion));
  
  an.intra.intact.clserr = nan(size(an.intra.intact.err));
  an.inter.intact.clserr = nan(size(an.inter.intact.err));
  an.intra.lesion.clserr = nan(size(an.intra.lesion.err));
  an.inter.lesion.clserr = nan(size(an.inter.lesion.err));
  
  % Loop and fill in data
  for bi=1:length(blobs)
    data = blobs{bi}.data; pats = blobs{bi}.pats; net = blobs{bi}.net;
    
    %% Error values
    an.intra.intact.err(bi,1:size(data.E_pat,1)) = squeeze(mean(mean(data.E_pat(:,pats.idx.intra,:),3),2))';
    an.inter.intact.err(bi,1:size(data.E_pat,1)) = squeeze(mean(mean(data.E_pat(:,pats.idx.inter,:),3),2))';
    an.intra.lesion.err(bi,1:size(data.E_lesion,1)) = mean(mean(data.E_lesion(:,pats.idx.intra,:),3),2)';
    an.inter.lesion.err(bi,1:size(data.E_lesion,1)) = mean(mean(data.E_lesion(:,pats.idx.inter,:),3),2)';

    % Propagate values for early stopping
    an.intra.intact.err(bi,size(data.E_pat,1)+1:end)    = an.intra.intact.err(bi,size(data.E_pat,1));
    an.inter.intact.err(bi,size(data.E_pat,1)+1:end)    = an.inter.intact.err(bi,size(data.E_pat,1));
    an.intra.lesion.err(bi,size(data.E_lesion,1)+1:end) = an.intra.lesion.err(bi,size(data.E_lesion,1));
    an.inter.lesion.err(bi,size(data.E_lesion,1)+1:end) = an.inter.lesion.err(bi,size(data.E_lesion,1));
    
    % Some aggregates and differences
    an.all.intact.err = (an.intra.intact.err + an.inter.intact.err)/2; 
    an.all.lesion.err = (an.intra.lesion.err + an.inter.lesion.err)/2;   
    an.intra.lei.err  = -(an.intra.intact.err(:,100:100:end) - an.intra.lesion.err);
    an.inter.lei.err  = -(an.inter.intact.err(:,100:100:end) - an.inter.lesion.err);
    an.all.lei.errmean = mean(an.all.lesion.err,1) - mean(an.all.intact.err(:,an.ts.lesion),1);
    an.all.lei.errstd = std(an.all.lesion.err,[],1) + std(an.all.intact.err(:,an.ts.lesion),[],1);
    
    %% Classification errors
    %gb_intra = find(pats.train.s(:,pats.idx.intra,:));
    %gb_inter = find(pats.train.s(:,pats.idx.inter,:));
    
    diff_intact = sqrt(2*data.E_pat); %reverse SSE to get activation
    diff_lesion = sqrt(2*data.E_lesion);

    an.intra.intact.clserr(bi,1:size(diff_intact,1)) = mean(mean( diff_intact(:,pats.idx.intra,:)>=net.sets.train_criterion, 3),2);
    an.inter.intact.clserr(bi,1:size(diff_intact,1)) = mean(mean( diff_intact(:,pats.idx.inter,:)>=net.sets.train_criterion, 3),2);
    an.intra.lesion.clserr(bi,1:size(diff_lesion,1)) = mean(mean( diff_lesion(:,pats.idx.intra,:)>=net.sets.train_criterion, 3),2);
    an.inter.lesion.clserr(bi,1:size(diff_lesion,1)) = mean(mean( diff_lesion(:,pats.idx.inter,:)>=net.sets.train_criterion, 3),2);

    an.intra.lesion.err(bi,1:size(data.E_lesion,1)) = mean(mean(data.E_lesion(:,pats.idx.intra,:),3),2)';
    an.intra.lesion.clserr(bi,1:size(diff_lesion,1)) = mean(mean( diff_lesion(:,pats.idx.intra,:)>=net.sets.train_criterion, 3),2);
    
    % Propagate values for early stopping
    an.intra.intact.clserr(bi,size(diff_intact,1)+1:end) = an.intra.intact.clserr(bi,size(diff_intact,1));
    an.inter.intact.clserr(bi,size(diff_intact,1)+1:end) = an.inter.intact.clserr(bi,size(diff_intact,1));
    an.intra.lesion.clserr(bi,size(diff_lesion,1)+1:end) = an.intra.lesion.clserr(bi,size(diff_lesion,1));
    an.inter.lesion.clserr(bi,size(diff_lesion,1)+1:end) = an.inter.lesion.clserr(bi,size(diff_lesion,1));

    % Some aggregates and differences
    an.all.intact.clserr = (an.intra.intact.clserr + an.inter.intact.clserr)/2; 
    an.all.lesion.clserr = (an.intra.lesion.clserr + an.inter.lesion.clserr)/2;   
    an.intra.lei.cls = -(an.intra.intact.clserr(:,100:100:end) - an.intra.lesion.clserr);
    an.inter.lei.cls = -(an.inter.intact.clserr(:,100:100:end) - an.inter.lesion.clserr);

    an.all.lei.clsmean = mean(an.all.lesion.clserr,1) - mean(an.all.intact.clserr(:,an.ts.lesion),1);
    an.all.lei.clsstd  = std(an.all.lesion.clserr,[],1) - std(an.all.intact.clserr(:,an.ts.lesion),[],1);
    
    npats = size(b.data.hu_lesion,2);
    nhidden =  size(b.data.hu_lesion,3);
    rh_idx = 1:(nhidden/2); 
    lh_idx = (nhidden/2)+[1:(nhidden/2)];
        
%    sim = @(m) (mean(m,
    an.all.lesion.hu_sim = zeros(length(an.ts.lesion), npats);
    for ti=1:length(an.ts.lesion)  
      rh_act = squeeze(b.data.lesion.y(end,:,rh_idx));
      %rh_act_norm = rh_act-repmat(mean(rh_act,1),[size(rh_act,1) 1]);
      rh_sim = cov(rh_act');%rh_act_norm * rh_act_norm';

      lh_act = squeeze(b.data.hu_lesion(end,:,lh_idx));
      %lh_act_norm = lh_act-repmat(mean(lh_act,1),[size(lh_act,1) 1]);
      lh_sim = cov(lh_act');%rh_act_norm * rh_act_norm';

      an.all.lesion.rh_sim = rh_sim;
      an.all.lesion.lh_sim = lh_sim;
      an.intra.lesion.rh_sim = rh_sim(pats.idx.intra,pats.idx.intra);
      an.intra.lesion.lh_sim = lh_sim(pats.idx.intra,pats.idx.intra);
      an.inter.lesion.rh_sim = rh_sim(pats.idx.inter,pats.idx.inter);
      an.inter.lesion.lh_sim = lh_sim(pats.idx.inter,pats.idx.inter);
      
      vicente = @(x,y) ( trace( (x'*x)'*(y'*y') ) );
      sim = @(x,y) ( vicente(x,y)/(vicente(y,y)*vicente(x,x)) );
      %/ trace( (y'*y)'*(y'*y) ) * trace((x'*x)'*(x'*x))
       
      rh_act = squeeze(b.data.nolesion.y(end,:,rh_idx));
      %rh_act_norm = rh_act-repmat(mean(rh_act,1),[size(rh_act,1) 1]);
      rh_sim = cov(rh_act');%rh_act_norm * rh_act_norm';

      lh_act = squeeze(b.data.nolesion.y(end,:,lh_idx));
      %lh_act_norm = lh_act-repmat(mean(lh_act,1),[size(lh_act,1) 1]);
      lh_sim = cov(lh_act');%rh_act_norm * rh_act_norm';

      an.all.intact.rh_sim = rh_sim;
      an.all.intact.lh_sim = lh_sim;
      an.intra.intact.rh_sim = rh_sim(pats.idx.intra,pats.idx.intra);
      an.intra.intact.lh_sim = lh_sim(pats.idx.intra,pats.idx.intra);
      an.inter.intact.rh_sim = rh_sim(pats.idx.inter,pats.idx.inter);
      an.inter.intact.lh_sim = lh_sim(pats.idx.inter,pats.idx.inter);
      
      %rh_sim =  * squeeze(b.data.hu_lesion(1,:,rh_idx))';
      %lh_sim = squeeze(b.data.hu_lesion(1,:,lh_idx)) * squeeze(b.data.hu_lesion(1,:,lh_idx))';
      %an.all.lesion.hu_sim(ti,:) =  .* squeeze(b.data.hu_lesion(1,:,lh_idx))'; % left-right similarity
      lr_D = net.D(net.idx.lh_cc,net.idx.rh_cc); rl_D = net.D(net.idx.rh_cc,net.idx.lh_cc);
      all_d = [ lr_D(:); rl_D(:) ]; 
      an.D.cc_bins = [min(net.sets.D_CC_INIT(:)):max(net.sets.D_CC_INIT(:))];
      an.D.cc_dist = hist( all_d, an.D.cc_bins );
    end;
  end;
 