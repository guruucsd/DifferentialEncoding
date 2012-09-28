function [Con,mu] = de_connector2D_Old(sI,sH,hpl,numCon,distn,rds,sig,dbg,tol)
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
  %  Con
    MAX_TRIES = 2500;
    
    if (~exist('dbg','var')), dbg=0; end;
    if (~exist('tol','var')), tol=0.01; end;
    
    % First, try to load from a cache
%    if (exist('de_GetOutFile')==2)
%        ccd = fullfile(de_GetOutPath([], 'cache', 'connector');
%        ccf = fullfile(ccd, sprintf('%d
%    end;
    
    
    %
    parts      = mfe_split('-',distn);
    distn_name = parts{1}; opts = parts(2:end); clear('parts');
    
    %  sO= output layer size; for an autoenc. it is the same as sI
    sO = sI;

    %s=[sI(1)/sI(2) 1]*s; %use this line for a non-circular Gaussian surface...
   % sig=sig;  %or this line for a circular one
    inPix=prod(sI);              %total number of nodes in the input layer
    Con = logical(spalloc(2*inPix+sH, 2*inPix+sH, 2*numCon*sH)); %
    halfCon = logical(spalloc(sH,inPix, numCon*sH)); %autoencoders have summetric connections, so you
    %only need to set connections for half of the connectivity matric: the half corresponding
    %to connections between Input to Hidden layers


    [mu, mupos] = de_connector_positions(sI, sH/hpl, dbg);

 
    nLoc = size(mupos,1);
   
    switch (distn_name)
        case {'gam','gamma','game','gammae'}
          k = rds^2/sig;
          theta = sig/rds;
        case {'norm','norme','norme2','normn','normeh'}
          if (rds ~= 0.0), warning('Ignoring non-zero rds=%4.1f', rds); end;
        case {'normr', 'normre'}
        case {'full','fulle'}, opts={'nofill'};
                      
        otherwise, error('Unknown distribution: %s', distn_name);
    end;
    

    % Could batch-generate these points
    
    for h=1:hpl %loop over # of units per locust
      loc = randperm(nLoc); % randomly choose a location
      
      for li=1:nLoc %loop over all loci
          mi = loc(li);
          
          for tryi=1:MAX_TRIES
              % Trick by oversampling
              nc=numCon;
              numCon = numCon*10;
              
              % Sample based on given distribution and parameters
              switch (distn_name)

                  case {'gam','gamma'}
                     r = gamrnd(k,theta,numCon,1); %shape, x.  As shape goes high and x goes low, interpatch distance decreases (less spread in points)
 %                     d = 2*pi*rand + (pi/2/theta)*randn(size(r));
                     d = 2*pi*rand(size(r));
%                     d = 2*pi*rand + d/2
                     pts = repmat(mupos(mi,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                      
                  case {'game','gammae'} % Theta_max = d_max/r
                     r = gamrnd(k,theta,numCon,1); %shape, x.  As shape goes high and x goes low, interpatch distance decreases (less spread in points)
 %                     d = 2*pi*rand + (pi/2/theta)*randn(size(r));
                     d = 2*pi*rand(size(r));
                     d = 2*pi*rand + sign(d).*mod(d,pi/4);
                     pts = repmat(mupos(mi,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                      
                  case {'norm'}
                      pts = round(mvnrnd(mupos(mi,:),[sig 0;0 sig],numCon));
                      
                  
                  case {'normeh'}
                      theta = randn*(pi/2/hpl) + (pi/hpl*(h-1));  % divide half-circle (we-re symmetric) into (hpl) parts; allow jitter within that slide (according to pi/hpl)
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      pts = mvnrnd([0,0],[1.5*sig 0;0 sig/1.5],numCon);
                      pts = round( (rm*pts')' + repmat(mupos(mi,:),[numCon 1]) );
                      
                  case {'norme'}
                      theta = 2*pi*rand; %really just need pi (half circle is enough; distn's are symmetric), but ...
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      pts = mvnrnd([0,0],[1.5*sig 0;0 sig/1.5],numCon);
                      pts = round( (rm*pts')' + repmat(mupos(mi,:),[numCon 1]) );
                      
                  case {'norme2'} %some different oblong shape
                      theta = 2*pi*rand;
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      pts = mvnrnd([0,0],[sig/2 0;0 sig/15 + 1/2],numCon);
                      pts = round(rm*pts')' + repmat(mupos(mi,:),[numCon 1]);
                      
                  case {'normn'} %norme, but always the same orientation
                      theta = pi/2;
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      pts = mvnrnd([0,0],[sig/2 0;0 sig/15 + 1/2],numCon);
                      pts = round(rm*pts')' + repmat(mupos(mi,:),[numCon 1]);
                      
              
                  case {'normr'}
                     r = rds + sig*randn(numCon,1);
                     d = 2*pi*rand(size(r));
                     pts = repmat(mupos(mi,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                     
                  case {'normre'}
                     theta = 2*pi*rand;                                      % angle of gaussian
                     rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)]; % rotation matrix for gaussian

                     phi   = 2*pi*rand(numCon,1); %position on circle
                     [cx,cy] = pol2cart(phi,rds);
                     
                     r     = mvnrnd([0 0],[1.5*sig 0;0 sig/1.5],numCon);      % cxn points in unrotated gaussian
                     pts   = (rm*r')' + [cx cy];

                     pts = round( (pts')' + repmat(mupos(mi,:),[numCon 1]));
                     
                     
                 % Square
                  case {'full'}
                     halflen=floor(sqrt(numCon)/2);
                     [x,y] = meshgrid( (mupos(mi,1)-(halflen):mupos(mi,1)+halflen), ...
                                       (mupos(mi,2)-(halflen):mupos(mi,2)+halflen));
                     pts = [x(:) y(:)];
                     
                  case {'fulle'}
                      error('NYI');
                  
                  otherwise, error('%s NYI', distn_name);
              end;
              
              % Revert # connections trick
              numCon = nc;
              

              % Process options
              pix = zeros(0,2);
              
              for j=1:length(opts)
                  switch opts{j}
                      case 'center'
                          pix(end+1,:) = mupos(mi,:); 
                      case 'surround'
                          pix(end+[1:8],:) = 0; % add 8
                          pix(end+1-[1:3],1) = mupos(mi,1)-1; pix(end+1-[1 4 6],2) = mupos(mi,2)-1;
                          pix(end+1-[4:5],1) = mupos(mi,1);   pix(end+1-[2 7],  2) = mupos(mi,2);
                          pix(end+1-[6:8],1) = mupos(mi,1)+1; pix(end+1-[3 5 8],2) = mupos(mi,2)+1;
                  end;
              end;

              pix(end+[1:size(pts,1)],:) = pts;
              pts = pix; clear('pix');  

              % Eliminate bad guys
              goodidx     =  (1<=pts(:,1) & pts(:,1)<=sI(1) ... %x-axis
                            & 1<=pts(:,2) & pts(:,2)<=sI(2));
              [~,o1]      = unique(pts(goodidx,:), 'rows', 'first');

              if (length(o1)<numCon), continue; end;

              pts         = pts(goodidx,:);
              orig_idx    = sort(o1);
              pix         = pts( orig_idx(1:numCon), :);


              % Success; exit loop!
              break;
          end; %while

%          guru_assert(tryi<MAX_TRIES,      sprintf('Failed to sample %d connections after %d tries.', MAX_TRIES));
          guru_assert(exist('pix','var') && size(pix,1)==numCon, sprintf('Failed to sample %d connections after %d tries.', numCon, tryi));
         
          layer = logical(spalloc(sI(1),sI(2),numCon));
          idx = sub2ind(size(layer), pix(:,1), pix(:,2));
          layer(idx) = true;

          hi = (h-1)*(sH/hpl)+mi; % unit # in sH, from 1:sH
          halfCon(hi,:)=reshape(layer,1,inPix);
      end; %per loc
    end

    Con(inPix+1:inPix+sH,1:inPix)=halfCon; %input -> hidden connections
    Con(inPix+sH+1:end,inPix+1:inPix+sH)=halfCon'; %hidden->output connections

	  % Then reshape to make use of them later
        

        
    % See if any inputs/outputs are NOT connected
    nNotCon = sum(~sum(halfCon,1)>0);

    if (nNotCon/prod(sI) > tol)
        clear('halfCon', 'Con');
        
        x      = dbstack();
        nCalls = sum(strcmp(x(1).name, {x.name}));
        if (nCalls >= 200)
            error('Failed to connect network to ALL inputs/outputs after %d calls; quitting...', nCalls);
        end;
        
        if (dbg), fprintf('.'); end;
        
        % Recursive call if we're above some tolerance (here, 1%)
        Con = de_connector2D(sI,sH,hpl,numCon,distn,rds,sig,dbg,tol);
    end;
    