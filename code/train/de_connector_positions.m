  function [mu,mupos] = de_connector_positions(sI,sH,dbg)
  % 
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices

    if (~exist('dbg','var')), dbg = 0; end;

    try
      [mu,mupos] = de_connector_positions_new(sI,sH,dbg);
      return;
    catch
      if isempty(strfind(lasterr, 'can''t fit'))
        error(lasterr);
      elseif ismember(11, dbg)
        fprintf('Failed to connect with new system; trying old!');
      end;
    end;

    [mu,mupos] = de_connector_positions_classic(sI,sH,dbg);
    

function [mu,mupos] = de_connector_positions_new(sI,sH,dbg)
% This allows 2D size of hidden unit layer to be specified.
% Also allows real (vs integer) hidden unit positions.sizeof
%
% Determine sH by dividing sI by some number, then taking the floor product:]
%   sH = prod(floor(sI/num));

  % Determine the scaling
  scalefactor = prod(sI)/sH;
  guru_assert(scalefactor>=1, sprintf('sH or hpl is off; %d units requested in %d locations/pixels!', sH, prod(sI)));
  newgrid = round(sI/sqrt(scalefactor));
  guru_assert(prod(newgrid)==sH, 'can''t fit');

  % Set up the hidden unit positions in the smaller grid
  [X,Y] = meshgrid(1:newgrid(2),1:newgrid(1));
  X = X - 1 - (newgrid(2)-1)/2;
  Y = Y - 1 - (newgrid(1)-1)/2;
  X = X*sqrt(scalefactor);
  Y = Y*sqrt(scalefactor);

  % Expand the smaller grid back out to the larger grid
  X = X+1 + (sI(2)-1)/2;
  Y = Y+1 + (sI(1)-1)/2;

  % Create the outputs from the grids
  mupos = [Y(:) X(:)];
  mu = zeros(sI);
  mu(round(Y(:)), round(X(:))) = 1;
  guru_assert(nnz(mu)==sH, '# of requested locations must match the # of provided locations!');
  


function [mu,mupos] = de_connector_positions_classic(sI,sH,dbg)
    ny = sI(1);
    nx = sI(2);

    % All positions
    if     (sH == prod(sI)),          mu = ones(sI);
    
    % Single position
    elseif (sH == 1), 
        mu(round(sI(1)/2), round(sI(2)/2)) = 1;
        
    %
    elseif (sH == length(1:2:ny)*length(1:2:nx) ...
            + length(2:2:ny)*length(2:2:nx))
        mu = zeros(sI); 
        mu(1:2:ny,1:2:nx) = 1;
        mu(2:2:ny,2:2:nx) = 1;

    elseif (sH == length(2:4:ny)*length(2:4:nx) ...
            + length(4:4:ny)*length(4:4:nx))
        mu = zeros(sI); 
        mu(2:4:ny,2:4:nx) = 1;
        mu(4:4:ny,4:4:nx) = 1;

    elseif (sH == length(3:6:ny)*length(3:6:nx) ...
            + length(6:6:ny)*length(6:6:nx))
        mu = zeros(sI); 
        mu(3:6:ny,3:6:nx) = 1;
        mu(6:6:ny,6:6:nx) = 1;

    elseif (sH == length(2:4:ny)*length(1:2:nx) ...
            + length(4:4:ny)*length(2:2:nx))
        mu = zeros(sI); 
        mu(2:4:ny,1:2:nx) = 1;
        mu(4:4:ny,2:2:nx) = 1;

    %
    elseif (sH == floor(sI(1)/2-0.5)*floor(sI(2)/2-0.5)), mu = zeros(sI); mu(2:2:end-1,2:2:end-1)=1;
    elseif (sH == floor(sI(1)/3-0.5)*floor(sI(2)/3-0.5)), mu = zeros(sI); mu(2:3:end-1,2:3:end-1)=1;
    elseif (sH == floor(sI(1)/4-0.5)*floor(sI(2)/4-0.5)), mu = zeros(sI); mu(2:4:end-1,2:4:end-1)=1;
    
    %
    elseif (sH == ceil(sI(1)/2+0.5)*ceil(sI(2)/2+0.5)), mu = zeros(sI); mu(1:2:end,1:2:end)=1;
    elseif (sH == ceil(sI(1)/3+0.5)*ceil(sI(2)/3+0.5)), mu = zeros(sI); mu(1:3:end,1:3:end)=1;
    elseif (sH == ceil(sI(1)/4+0.5)*ceil(sI(2)/4+0.5)), mu = zeros(sI); mu(1:4:end,1:4:end)=1;
    
    % Interleaved grid
    elseif (sH == ceil(sI(1)/2)*ceil(sI(2)/2) ...
                + floor(sI(1)/2)*floor(sI(2)/2)), mu = zeros(sI); mu(1:2:end,1:2:end)=1; mu(2:2:end, 2:2:end)=1;
    elseif (sH == ceil(sI(1)/3)*ceil(sI(2)/3) ...
                + floor(sI(1)/3)*floor(sI(2)/3)), mu = zeros(sI); mu(1:3:end,1:3:end)=1; mu(2:3:end, 2:3:end)=1;
    elseif (sH == ceil(sI(1)/4)*ceil(sI(2)/4) ...
                + floor(sI(1)/4)*floor(sI(2)/4)), mu = zeros(sI); mu(1:4:end,1:4:end)=1; mu(2:4:end, 2:4:end)=1;
    
    % Straightforward grid
    elseif (sH == ceil(prod(sI)/2)), mu = zeros(sI); mu(1:2:end) = 1;
    elseif (sH == ceil(prod(sI)/3)), mu = zeros(sI); mu(1:3:end) = 1;
    elseif (sH == ceil(prod(sI)/4)), mu = zeros(sI); mu(1:4:end) = 1;
    elseif (sH == ceil(prod(sI)/5)), mu = zeros(sI); mu(1:5:end) = 1;
    
    % Specific sizes / cases
    elseif (sI(1)==sI(2)), 
        [mu] = de_connector2D_positions_square(sI(1), sH, dbg);

    elseif (~any(sI-[31 13]))
        [mu] = de_connector2D_positions_31x13(sH, dbg);
        
    elseif (~any(sI-[34 25]))
        [mu] = de_connector2D_positions_34x25(sH, dbg);

    elseif (~any(sI-[34 13]))
        [mu] = de_connector2D_positions_34x13(sH, dbg);

    elseif (~any(sI-[68 50]))
        [mu] = de_connector2D_positions_68x50(sH, dbg);
    % Try this one, hope for the best!
    else
        warning(sprintf('Unrecognized size: [ %s]',sprintf('%d ',sI)));
        [mu] = de_connector2D_positions_31x13(sH, dbg);
    
        guru_assert( nnz(mu) == sH );

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
    
    if (ismember(12,dbg))
        %pcolor(mu);
        %mu
        nRows = ceil(sqrt((sH+1)*4/3));
        nCols = ceil((sH+1)/nRows);
        
        %figure;
        subplot(nRows,nCols,1);
        imagesc(mu); title('Hidden node locations');
    end;
    

    guru_assert(length(find(mu))==sH,'Incorrect # of hidden unit positions assigned');
    
    % Now randomize; nothing should be counting on the order here
    %mupos = mupos(randperm(size(mupos,1)),:);
    
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
  function [mu] = de_connector2D_positions_68x50(sH,dbg)
  %the topological configuration of the hidden nodes is hand coded here,
  %based on the number of Hidden nodes
  %
  % output:
  %
  % mu     - 2D bitmap with a 1 at the locations of the sH hidden nodes
  % m       - locations of hidden nodes in 2D bitmap; 
  %             m(:,1) = row indices
  %             m(:,2) = column indices
  
    sI = [68 50];
    mu = zeros(sI);
    
    switch (sH)
      case 3400, mu(1:1:end)=1;
      case 1700, mu(1:2:end)=1;
      case 1134, mu(1:3:end)=1;
      case 850,  mu(1:4:end)=1;

      case 3168, mu(2:1:end-1,2:1:end-1)=1;
      case 792,  mu(2:2:end-1,2:2:end-1)=1;
      case 425,  mu(2:4:end,2:4:end) = 1; mu(4:4:end,4:4:end) = 1;
      case 352,  mu(2:3:end-1,2:3:end-1)=1;
      case 88,   mu(3:6:end-1,3:6:end-1)=1;
      case 1,    mu( round(size(mu,1)/2), round(size(mu,2)/2) ) = 1;

      case 450,         img(1:4:end,1:4:end)=1;
                        img(3:4:end,3:4:end)=1;
                        
      otherwise
        error('# hidden units NYI');

    end; %switch
    
      
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
      case 102, mu(2:4:end,2:4:end) = 1; mu(4:4:end,4:4:end) = 1;
      case 88,  mu(2:3:end-1,2:3:end-1)=1;
      case 24,  mu(3:6:end-1,3:6:end-1)=1;
      case 1,   mu( round(size(mu,1)/2), round(size(mu,2)/2) ) = 1;
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
    
 

     
