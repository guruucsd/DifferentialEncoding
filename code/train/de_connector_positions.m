  function [mu,mupos] = de_connector_positions(sI,sH,dbg)
  % Assumes image size 31x13
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices

    if (~exist('dbg','var')), dbg = 0; end;

    if (sI(1)==sI(2)), 
        [mu] = de_connector2D_positions_square(sI(1), sH, dbg);

    elseif (~any(sI-[34 25]))
        [mu] = de_connector2D_positions_34x25(sH, dbg);

    elseif (~any(sI-[34 13]))
        [mu] = de_connector2D_positions_34x13(sH, dbg);

    % Try this one, hope for the best!
    else
        [mu] = de_connector2D_positions_31x13(sH, dbg);
    
        guru_assert( length(find(mu)) == sH );

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
    
    [col,row] = find(mu==1);
    [mupos] = [col,row];
    
    if (ismember(2,dbg))
        %pcolor(mu);
        %mu
        nRows = ceil(sqrt((sH+1)*4/3));
        nCols = ceil((sH+1)/nRows);
        
        subplot(nRows,nCols,1);
        imagesc(mu); title('Hidden node locations');
    end;
    
    guru_assert(length(find(mu))==sH,'Incorrect # of hidden unit positions assigned');
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [mu] = de_connector2D_positions_square(sI, sH, dbg)
      mu = zeros(sI,sI);
      
      % All input positions
      if (mod(sH, sI^2)==0)
          mu = ones(sI,sI);
          
      % All input positions not on the edge
      elseif (mod(sH, (sI-1)^2)==0)
          mu(2:end-1,2:end-1)=1;
          
      % Every other input position
      elseif (mod(sH, sI^2/2)==0)
          mu(1:2:end) = 1;
          
      else, 
          error('Unknown configuration.');
      end;
      
       

      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [mu] = de_connector2D_positions_34x25(sH,dbg)
  %the topological configuration of the hidden nodes is hand coded here,
  %based on the number of Hidden nodes
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices

    sI = [34 25];
    mu = zeros(sI);
    
    % Assumes image size [34 25]
    switch (sH)
      case 850, mu(1:1:end)=1;
      case 425, mu(1:2:end)=1;
      case 284, mu(1:3:end)=1;
      case 213, mu(1:4:end)=1;

      case 793, mu(2:1:end-1,2:1:end-1)=1;
      case 192, mu(2:2:end-1,2:2:end-1)=1;
      case 88,  mu(2:3:end-1,2:3:end-1)=1;

      otherwise
        error('# Hidden Units NYI');
    end;
    

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [mu] = de_connector2D_positions_34x13(sH,dbg)
  %the topological configuration of the hidden nodes is hand coded here,
  %based on the number of Hidden nodes
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices

    sI = [34 13];
    mu = zeros(sI);
    
    % Assumes image size [34 25]
    switch (sH)
      case 442, mu(1:1:end)=1;
      case 221, mu(1:2:end)=1;
      case 148, mu(1:3:end)=1;
      case 111, mu(1:4:end)=1;

      case 352, mu(2:1:end-1,2:1:end-1)=1;
      case 96,  mu(2:2:end-1,2:2:end-1)=1;
      case 44,  mu(2:3:end-1,2:3:end-1)=1;

      otherwise
        error('# Hidden Units NYI');
    end;
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function [mu] = de_connector2D_positions_31x13(sH,dbg)
  %the topological configuration of the hidden nodes is hand coded here,
  %based on the number of Hidden nodes
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices
  
    sI = [31 13];
    mu = zeros(sI);
    
    % Assumes image size [31 13]
    switch (sH)
      case 403,         mu = ones(sI);      
      case 319,         mu(2:end-1,2:end-1) = 1;
      case 202,         mu(1:2:numel(mu))=1;
      case 90,          mu(2:2:end,2:2:end)=1;
      case 60,        mu(2:3:end,2:2:end)=1;
      case 30,        mu(4:6:end,3:2:end)=1;
      case 22
        interval=floor(sI(1)*sI(2)/21);
        mu(2:interval:numel)=1;
        
      case 20,        mu(4:6:end,2:3:end)=1;
      case 16,        mu(3:4:end,4:6:end)=1;
      case 14,        mu(4:4:end,4:6:end)=1;
      case 13
        mu(6:10:end,3:4:end)=1;
        mu(11:10:21,5:4:9)=1;
        
      case 12,        mu(2:9:end,2:5:end)=1;
      case 11
        mu(2:7:end,4:6:end)=1;
        mu(16,7)=1;
        
      case 10,        mu(2:7:end,4:6:end)=1;
        

      otherwise
        error('# hidden units NYI');

    end; %switch
    
 
