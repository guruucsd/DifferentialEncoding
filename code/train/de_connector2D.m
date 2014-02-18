function [Con,mu] = de_connector2D(sI,sH,hpl,numCon,distn,rds,sig,dbg,tol,weight_factor, want_fully_connected)
  %
  %This function is used to creat the connectivity matrix for the
  %  autoencoders based on a Gaussian distribution.
  %
  % Input:
  %  s=sigma (width of Gaussian)
  %  numCon= number of connection per hidden node
  %  sI is a 1x2 matrix containg [height, width] of the input layer (input
  %    images)
  %  sH= # of hidden nodes
  %
  % Output:
  %  Con : connectivity matrix
  %  mu : positions of the hidden units

    MAX_CALLS = 200; %

    if (~exist('dbg','var')), dbg=0; end;
    if (~exist('tol','var')), tol=0; end;
    if (~exist('weight_factor','var')), weight_factor = []; end;
    if ~exist('want_fully_connected'), want_fully_connected = false; end;

    fake_zero = (sH==0);
    if fake_zero
       guru_assert(hpl==0);
       sH = prod(sI);
       hpl = 1;
    end;

    % Connect input to output directly (zero hidden units)
    %   by pretending there are sI hidden units, then
    %   using those connections (at the bottom) to connect input->output
    fake_zero = (sH==0);
    if fake_zero
       guru_assert(hpl==0);
       sH = prod(sI);
       hpl = 1;
    end;

    %
    parts       = mfe_split('-',distn);
    distn_name  = parts{1}; opts = parts(2:end); clear('parts');
    inPix       = prod(sI);              %total number of nodes in the input layer
    Con         = logical(spalloc(2*inPix+sH, 2*inPix+sH, 2*numCon*sH)); %
    halfCon     = logical(spalloc(sH,inPix, numCon*sH)); %autoencoders have symmetric connections, so you

    [mu, mupos] = de_connector_positions(sI, sH/hpl, dbg);
    nLoc        = size(mupos,1);
    if (hpl>1)
        prbdistn_cache = zeros(nLoc,inPix);
    end;
    if (isempty(weight_factor))
		lg            = @(x) (2/(1+exp(-(x.^2)/8))-1); %logistic, range [-1 1], cross at 0
		weight_factor = eps+lg(numCon*nLoc*sqrt(hpl)/inPix - 1); %sqrt(hpl) because sparse connections per layer => spread out hus => need more "damping" of pdf for nodes we already connected to
    end;
    guru_assert(weight_factor>0, '"weight factor" must be >0');

    switch (distn_name)
        case {'gam','gamma','game','gammae'}
          k = rds^2/sig;
          theta = sig/rds;
        case {'norm','norme','norme2','normem2','normn', 'normeh'}
          if (rds ~= 0.0) && ~isnan(rds), warning('Ignoring non-zero rds=%4.1f', rds); end;
        case {'normr', 'normre'}
        case {'full','fulle'}, opts={'nofill'};
        case {'ipd','ipd-local'}, ipd = rds;
        otherwise, error('Unknown distribution: %s', distn_name);
    end;


    % Could batch-generate these points
    alllyr = zeros(sI);
    w      = ones(inPix,1);
	  [X1,X2] = meshgrid(1:sI(1),1:sI(2));
  	pts     = [X1(:) X2(:)];

    for h=1:hpl %loop over # of units per locust
      if (false && h>1)
        halfCon((h-1)*nLoc+[1:nLoc],:) = halfCon(1:nLoc,:);
      else
        locs   = randperm(nLoc); % randomly choose a location
        for li=1:nLoc %loop over all loci
            mi = locs(li);
            hi = (h-1)*(sH/hpl)+mi; % unit # in sH, from 1:sH
            X  = pts;

            if (h==1 || ~exist('prbdistn_cache','var')) % generate the distribution

                % Sample based on given distribution and parameters
                switch (distn_name)
                    case {'ipd', 'ipd-local'}
                      Xa = round(sort([mupos(mi,2):-ipd:1 mupos(mi,2):ipd:sI(2)]));
                      Ya = round(sort([mupos(mi,1):-ipd:1 mupos(mi,1):ipd:sI(1)]));

                      theta = 2*pi*rand; %really just need pi (half circle is enough; distn's are symmetric), but ...
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      error('ipd distribution NYI');
                      mn    = mupos(mi,:);
                      cv    = rm*[1.5*sig 0;0 sig/1.5]*rm';
                      pdn   = zeros(sI);
                      pdn(Ya,Xa) = 1;
                      pdn   = pdn .* reshape(mvnpdf(X, mn, cv),sI(end:-1:1))';     %transform linear array to 2D
                      pdn   = reshape(transpose(pdn),[numel(pdn) 1])./sum(pdn(:)); %transform back into expected linear array

                    case {'gam','gamma'}
                       r = gamrnd(k,theta,numCon,1); %shape, x.  As shape goes high and x goes low, interpatch distance decreases (less spread in points)
                       d = 2*pi*rand(size(r));
                       pts = repmat(mupos(mi,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                       error('NYI');

                    case {'game','gammae'} % Theta_max = d_max/r
                       r = gamrnd(k,theta,numCon,1); %shape, x.  As shape goes high and x goes low, interpatch distance decreases (less spread in points)
                       d = 2*pi*rand(size(r));
                       d = 2*pi*rand + sign(d).*mod(d,pi/4);
                       pts = repmat(mupos(mi,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                       error('NYI');

                    case {'norm'}
                        mn   = mupos(mi,:);
                        cv   = [sig 0; 0 sig];
                        pdn  = mvnpdf(X, mn, cv);
                        %keyboard

                    case {'normeh'}
                        theta = randn*(pi/2/hpl) + (pi/hpl*(h-1));  % divide half-circle (we-re symmetric) into (hpl) parts; allow jitter within that slide (according to pi/hpl)
                        rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];

                        mn    = mupos(mi,:);
                        cv    = rm*[1.5*sig 0;0 sig/1.5]*rm';
                        pdn   = mvnpdf(X, mn, cv);

                    case {'norme', 'norme2', 'normem2'}
                        theta = 2*pi*rand; %really just need pi (half circle is enough; distn's are symmetric), but ...
                        rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];

                        mn    = mupos(mi,:);
                        cv    = rm*[1.5*sig 0;0 sig/1.5]*rm';
                        pdn   = mvnpdf(X, mn, cv);
                        if strcmp(distn_name, 'norme2')
                          [~,mp] = max(pdn);
                          pdn(mp) = 100; % always connects to its own position
                        elseif strcmp(distn_name, 'normem2')
                          [~,mp] = max(pdn);
                          pdn(mp) = 0; % never connects to its own position
                        end;

                    case {'normn'} %norme, but always the same orientation
                        theta = pi/2;
                        rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                        pts = mvnrnd([0,0],[sig/2 0;0 sig/15 + 1/2],numCon);
                        pts = round(rm*pts')' + repmat(mupos(mi,:),[numCon 1]);
                       error('NYI');

                    case {'normr'}
                       r = rds + sig*randn(numCon,1);
                       d = 2*pi*rand(size(r));
                       pts = repmat(mupos(mi,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                       error('NYI');

                    case {'normre'}
                       theta = 2*pi*rand;                                      % angle of gaussian
                       rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)]; % rotation matrix for gaussian

                       phi   = 2*pi*rand(numCon,1); %position on circle
                       [cx,cy] = pol2cart(phi,rds);

                       r     = mvnrnd([0 0],[1.5*sig 0;0 sig/1.5],numCon);      % cxn points in unrotated gaussian
                       pts   = (rm*r')' + [cx cy];

                       pts = round( (pts')' + repmat(mupos(mi,:),[numCon 1]));
                       error('NYI');


                   % Square
                    case {'full'}
                       halflen=floor(sqrt(numCon)/2);
                       [x,y] = meshgrid( (mupos(mi,1)-(halflen):mupos(mi,1)+halflen), ...
                                         (mupos(mi,2)-(halflen):mupos(mi,2)+halflen));
                       pts = [x(:) y(:)];
                       error('NYI');

                    case {'fulle'}
                        error('NYI');

                    otherwise, error('%s NYI', distn_name);
                end;

                % Cache this item
                if (exist('prbdistn_cache','var'))
                    prbdistn_cache(mi,:) = pdn;
                end;

            else % cache exists, so use it!
              pdn = prbdistn_cache(mi,:)';
            end;


            % The logic is that the cdn starts with zero,
            %   and trails the pdn by 1 (in indexing).
            %   So, random sample on uniform, find the cdn
            %   index where we are still LESS than the sample;
            %   that will correspond to being in the pdn within
            %   that value.
            % The updates depend on understanding that
            %   the cdn trains the pdn by 1, and that
            %   the cdn has an extra element
            %
            cdn    = [0;cumsum(max(0,pdn).*w)];
            layer  = logical(spalloc(sI(1),sI(2),numCon));
            cnn    = zeros(numCon,1);


            for ci=1:numCon
              val     = cdn(end)*rand; % Now select.
              cnn(ci) = find(cdn>=val,1,'first'); % find the first instance above that value
              curidx  = cnn(ci)-1;%idx(cnn(ci));
              guru_assert(curidx<=length(pdn));
              guru_assert(curidx>0);

              % add the connection
              layer (X(curidx,1), X(curidx,2)) = true;
              alllyr(X(curidx,1), X(curidx,2)) = alllyr(X(curidx,1), X(curidx,2))+1;

              % update the distribution
              pdn(curidx) = 0;
              cdn = [0;cumsum(max(0,pdn).*w)];

              % Update this after the above.
              w(curidx) = w(curidx)*weight_factor; % don't need to update cdn now, as we don't connect to the same node in the same layer anyway.
              if (~any(w)), % unless we run out of nodes to connect to!
                w=ones(size(w));
                cdn    = [0;cumsum(max(eps,pdn).*w)];
                %cdn    = cdn(idx);
              end;
              guru_assert(all(cdn>=0 | isnan(cdn)), 'cumulative distribution must have all elements >=0');
              guru_assert(~all(cdn==0) || ci==numCon, 'must have something to select!');
            end;
            if (ismember(10,dbg))
              if (mod(li,100)==0), fprintf(' %d', li); end;
            end;

            halfCon(hi,:) =reshape(layer,1,inPix);
        end; %per location
      end; % if
    end % per hpl

    Con(inPix+1:inPix+sH,1:inPix)=halfCon; %input -> hidden connections
    Con(inPix+sH+1:end,inPix+1:inPix+sH)=halfCon'; %hidden->output connections

	if (ismember(15,dbg))
		weight_factor
		alllyr(alllyr==0) = -100
	end;


    % See if any inputs/outputs are NOT connected
    if want_fully_connected
        nNotCon = sum(~sum(halfCon,1)>0);

        if (nNotCon/prod(sI) > tol)

            x      = dbstack();
            nCalls = sum(strcmp(x(1).name, {x.name}));
            if (nCalls >= MAX_CALLS)
                Con = [];
                return;
            end;

            if (dbg), fprintf('.'); end;

            % Recursive call if we're above some tolerance (here, 1%)
            Con = de_connector2D(sI,sH,hpl,numCon,distn,rds,sig,dbg,tol);
            if (nCalls==1 && isempty(Con))
                error('Failed to connect network to ALL inputs/outputs after %d calls; quitting...', MAX_CALLS);
            end;
        end;
    end;

    if fake_zero
        Con2 = zeros(2*inPix);
        Con2(inPix+[1:inPix],1:inPix) = Con(inPix+[1:inPix],1:inPix);
        Con2 = Con;
        mu = [];
    end;

    if fake_zero
        Con2 = zeros(2*inPix);
        Con2(inPix+[1:inPix],1:inPix) = Con(inPix+[1:inPix],1:inPix);
        Con2 = Con;
        mu = [];
    end;

