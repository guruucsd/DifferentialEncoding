  function [mu,hpl,mupos] = de_connector_positions(sI,sH,dbg)
  % Assumes image size 31x13
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices
  % hpl  - hidden units per location
    if (~exist('dbg','var')), dbg = 0; end;
    
    if (sI(1)==sI(2)), 
        [mu,hpl] = de_connector2D_positions_square(sI(1), sH, dbg);
    else,              
        [mu,hpl] = de_connector2D_positions_31x13(sH, dbg);
    
        guru_assert( length(find(mu))*hpl == sH );

        % Stretch, thresshold, and cluster
        if (sI(1)~=31 || sI(2) ~= 13)
          tmp2 = imresize(mu,sI);
          tmp2(tmp2<0.5) = 0;
          for i=2:size(tmp2,1)-1
            for j=2:size(tmp2,2)-1
              patch = tmp2(i-1:i+1, j-1:j+1);
              [n,I] = max(patch(:));

              if (tmp2(i,j) ~= n)
                tmp2(i,j) = 0;
              elseif (length(find(patch==n))~=1)
                tmp2(i,j) = 0;
              else
                tmp2(i,j) = 1;
              end;
            end;
          end;
          mu = tmp2;
        end;
    end;
    
    [row,col] = find(mu==1);
    [mupos] = [col,row];
    
    if (ismember(2,dbg))
        %pcolor(mu);
        %mu
        nRows = ceil(sqrt((sH+1)*4/3));
        nCols = ceil((sH+1)/nRows);
        
        subplot(nRows,nCols,1);
        imagesc(mu); title('Hidden node locations');
    end;
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [mu,hpl] = de_connector2D_positions_square(sI, sH, dbg,inloop)
      mu = zeros(sI,sI);
      
      % All input positions
      if (mod(sH, sI^2)==0)
          mu = ones(sI,sI);
          hpl = sH/(sI^2);
          
      % All input positions not on the edge
      elseif (mod(sH, (sI-1)^2)==0)
          mu(2:end-1,2:end-1)=1;
          hpl = sH/(sI^2);
          
      % Every other input position
      elseif (mod(sH, sI^2/2)==0)
          mu(1:2:end) = 1;
          hpl = sH/(sI^2/2);
          
      else, 
          error('Unknown configuration.');
      end;
      
       
      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [mu,hpl] = de_connector2D_positions_31x13(sH,hpl,dbg,inloop)
  %the topological configuration of the hidden nodes is hand coded here,
  %based on the number of Hidden nodes
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices
  % hpl  - hidden units per location
    persistent hplDict;

    if isempty(hplDict), hplDict = struct(); end;
    if (~exist('inloop','var')), inloop = 0; end;

    hpl = 1; %try to place each hidden unit separately, if possible
    
    sI = [31 13];
    
    % Assumes image size [31 13]
    switch (sH)
        
        
      case 403
        mu = ones(sI);
      
      case 319
        mu=zeros(sI);
        mu(2:end-1,2:end-1) = 1;
        
      case 202
        mu=zeros(sI);
        mu=reshape(mu,1,sI(1)*sI(2));
        mu(1:2:end)=1;
        mu=reshape(mu,sI);

      case 90
        mu=zeros(sI);
        mu(2:2:end,2:2:end)=1;
        
      case 60
        mu=zeros(sI);
        mu(2:3:end,2:2:end)=1;
        
      case 30
        mu=zeros(sI);
        mu(4:6:end,3:2:end)=1;
        
      case 22
        interval=floor(sI(1)*sI(2)/21);
        mu=zeros(sI);
        mu=reshape(mu,1,sI(1)*sI(2));
        mu(2:interval:end)=1;
        mu=reshape(mu,sI);
        
      case 20
        mu=zeros(sI);
        mu(4:6:end,2:3:end)=1;
        
      case 16
        mu=zeros(sI);
        mu(3:4:end,4:6:end)=1;
        
%      case 15
%        mu=zeros(sI);
%        mu(4:6:end,3:4:end)=1;

      case 14
        mu=zeros(sI);
        mu(4:4:end,4:6:end)=1;

      case 13
        mu=zeros(sI);
        mu(6:10:end,3:4:end)=1;
        mu(11:10:21,5:4:9)=1;
        
      case 12
        mu=zeros(sI);
        mu(2:9:end,2:5:end)=1;
        
      case 11
        mu=zeros(sI);
        mu(2:7:end,4:6:end)=1;
        mu(16,7)=1;
        
      case 10
        mu=zeros(sI);
        mu(2:7:end,4:6:end)=1;
        

      otherwise
        if (isfield(hplDict, sprintf('x%d', sH)))
            hpl = hplDict.(sprintf('x%d',sH));
            [mu] = de_connector2D_positions_31x13(sH / hpl, dbg, 1);
        else

            % Place 
            sH_factors = sort(factor(sH));
            unique_factors = unique(sH_factors);

            % Try to find some grid, and place multiple hidden units at the given locations
            if (length(sH_factors)>1)
                keyboard % we should never get here anymore.
              hpl = 1;

              for i=1:length(unique_factors)
                %hpl = unique_factors(i);
                try
                  [mu,hpl2] = de_connector2D_positions_31x13(sH / unique_factors(i), dbg, 1);
                  %keyboard
                  if (hpl==1 || (hpl2*unique_factors(i))<hpl)
                      hpl = unique_factors(i)* hpl2;
                  end;
                  break; %effort worked, so exit!
                catch
                  % effort failed, so continue looping
                  if (~isempty(findstr('2D Connector not set up', lasterr)))
                    continue;
                  % unexpected error
                  else
                      keyboard
                      error(lasterr);
                  end;
                end; %catch
              end; %for
            end; %if
        

            if (~exist('mu','var'))
              if (~inloop)
                hpl = 1;
                pix = randperm(prod(sI));
                mu = zeros(sI);
                mu(pix(1:sH)) = 1;
              else
                error('2D Connector not set up to distribute %d nodes.', sH);
              end;
            end;

            if (~inloop)
                if (hpl>1)
                    fprintf('Using hpl=%d\n', hpl);
                end;
                if (exist('pix','var'))
                    fprintf('Using randomized hu positions.\n');
                end;
            end;
            
            hplDict.(sprintf('x%d', sH)) = hpl;
        end;
    end; %switch
    
 
