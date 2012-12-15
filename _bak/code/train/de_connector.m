function [Con] = de_connector(model)
%[Con, mu] = de_connector(model)
%
% Creates a connectivity matrix for the given model
%
% Inputs:
% model : see de_model for details
%
% Outputs:
% Con   : connectivity matrix
  [Con, hpl, mu] = de_connector2D(model.nInput, ...
                                  model.nHidden, ...
                                  model.hpl,...
                                  model.nConns,...
                                  model.distn{1}, ...
                                  model.mu,...
                                  model.sigma,...
                                  model.ac.debug);
    

function [Con,hpl,mu] = de_connector2D(sI,sH,hpl,numCon,distn,rds,sig,dbg)
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
  
    %
    parts = mfe_split('-',distn);
    distn = parts{1}; opts = parts(2:end); clear('parts');
    
    %  sO= output layer size; for an autoenc. it is the same as sI
    sO = sI;

    %s=[sI(1)/sI(2) 1]*s; %use this line for a non-circular Gaussian surface...
   % sig=sig;  %or this line for a circular one
    inPix=prod(sI);              %total number of nodes in the input layer
    Con = zeros(2*inPix+sH); %
    halfCon = zeros(sH,inPix); %autoencoders have summetric connections, so you
    %only need to set connections for half of the connectivity matric: the half corresponding
    %to connections between Input to Hidden layers


    [mu,hpl2,mupos] = de_connector_positions(sI, sH/hpl, dbg);
    guru_assert(hpl2 == 1); %Make sure new, passed-in hpl, takes over
                            % and that old system doesn't try to divide
                            % things up
 
    nLoc = size(mupos,1);
   
    switch (distn)
        case {'gam','gamma','game','gammae'}
          k = rds^2/sig;
          theta = sig/rds;
        case {'norm'}
          if (rds ~= 0.0), warning('Ignoring non-zero rds=%4.1f', rds); end;
        case {'norme','norme2','normn'}
        case {'normr', 'normre'}
        case {'full','fulle'}, opts={'nofill'};
                      
        otherwise, error('Unknown distribution: %s', distn);
    end;
    

    % Could batch-generate these points
    
    for h=1:hpl %loop over # of units per locust
      for i=1:nLoc %loop over all loci
          
          pix = zeros(0,2);
          
          if (ismember('center',opts)) %must contain the locust
              pix(1,:) = m(i,:); 
          end;
          
          while (size(pix,1) < numCon)
              switch (distn)

                  case {'gam','gamma'}
                     r = gamrnd(k,theta,numCon,1); %shape, x.  As shape goes high and x goes low, interpatch distance decreases (less spread in points)
 %                     d = 2*pi*rand + (pi/2/theta)*randn(size(r));
                     d = 2*pi*rand(size(r));
%                     d = 2*pi*rand + d/2
                     pts = repmat(mupos(i,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                      
                  case {'game','gammae'} % Theta_max = d_max/r
                     r = gamrnd(k,theta,numCon,1); %shape, x.  As shape goes high and x goes low, interpatch distance decreases (less spread in points)
 %                     d = 2*pi*rand + (pi/2/theta)*randn(size(r));
                     d = 2*pi*rand(size(r));
                     d = 2*pi*rand + sign(d).*mod(d,pi/4);
                     pts = repmat(mupos(i,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                      
                  case {'norm'}
                      pts = round(mvnrnd(mupos(i,:),[sig 0;0 sig],numCon));
                      
                  case {'norme'}
                      theta = 2*pi*rand;
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      pts = mvnrnd([0,0],[1.5*sig 0;0 sig/1.5],numCon);
                      pts = round(rm*pts')' + repmat(mupos(i,:),[numCon 1]);
                      
                  case {'norme2'}
                      theta = 2*pi*rand;
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      pts = mvnrnd([0,0],[sig/2 0;0 sig/15 + 1/2],numCon);
                      pts = round(rm*pts')' + repmat(mupos(i,:),[numCon 1]);
                      
                  case {'normn'} %norme, but always the same orientation
                      theta = pi/2;
                      rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)];
                      pts = mvnrnd([0,0],[sig/2 0;0 sig/15 + 1/2],numCon);
                      pts = round(rm*pts')' + repmat(mupos(i,:),[numCon 1]);
                      
              
                  case {'normr'}
                     r = rds + sig*randn(numCon,1);
                     d = 2*pi*rand(size(r));
                     pts = repmat(mupos(i,:), [numCon 1]) + round([r.*cos(d) r.*sin(d)]);
                     
                  case {'normre'}
                     r = rds + sig*randn(numCon,1);
                     
                     theta = 2*pi*rand;                                       % angle of gaussian
                     rm    = [cos(theta) -sin(theta); sin(theta) cos(theta)]; % rotation matrix for gaussian
                     t     = mvnrnd([0,0],[1.5*sig 0;0 sig/1.5],numCon);      % cxn points in unrotated gaussian
                     d     = atan(t(:,2)./t(:,1));                            % angle of each cxn point in unrotated gaussian
                     d     = d + sign(d).*pi.*randi([0 1],size(t(:,1)));      % allow angle to go from 0 to 2pi
                     dr    = (rm*[r.*cos(d) r.*sin(d)]')';              % cxn points in rotated gaussian

                     pts   = round(repmat(mupos(i,:), [numCon 1]) + dr);
                     
                 % Square
                  case {'full'}
                     halflen=floor(sqrt(numCon)/2);
                     [x,y] = meshgrid( (mupos(i,1)-(halflen):mupos(i,1)+halflen), ...
                                       (mupos(i,2)-(halflen):mupos(i,2)+halflen));
                     pts = [x(:) y(:)];
                     
                  case {'fulle'}
                      error('NYI');
                     
              end;
              
              
              % Eliminate bad guys
              goodidx   = find(1<=pts(:,1) & pts(:,1)<=sI(2) ... %x-axis
                             & 1<=pts(:,2) & pts(:,2)<=sI(1));   
              [junk,idx] = unique(pts(goodidx,:), 'rows');
              pts       = pts(goodidx(sort(idx)),:); % put in original order to avoid biasing sample
              
              % Combine with previous pix, see if we have enough
              pix = [pix;pts];
              [junk,idx] = unique(pix, 'rows', 'first');
              pix = pix(sort(idx),:);
              
              if (ismember('nofill', opts)) % don't resample to fill # conns
                  break;
              elseif (size(pix,1)>=numCon)
                  pix = pix(1:numCon,:);
                  break;
              end;
          end;

          %if (any(pix(1,:)-m(i,:)))
          %    error('why???');
         % end;
              

          layer = zeros(sI);
          idx = sub2ind(size(layer), pix(:,2), pix(:,1));
          layer(idx) = 1;

          hi = (h-1)*(sH/hpl)+i; % unit # in sH, from 1:sH
          halfCon(hi,:)=reshape(layer,1,inPix);
      end; %per loc
    end
    Con(inPix+1:inPix+sH,1:inPix)=halfCon; %input -> hidden connections
    Con(inPix+sH+1:end,inPix+1:inPix+sH)=halfCon'; %hidden->output connections
    