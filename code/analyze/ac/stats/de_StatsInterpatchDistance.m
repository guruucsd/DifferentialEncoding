function [ipd] = de_StatsInterpatchDistance(models)
%function [ti] = de_StatsTrainIters(models)
%
% Calculates stats that we care about
%
% Input:
% LS            :
% errAutoEnc    :
% 
% Output:
% ti : # of training iterations

  % Only makes sense for 2D
  if (length(models{1}(1).nInput)~=2)
      warning('Inter-Patch distance only implemented for 2D models.');
      ipd = [];
  end;
  
  % Normalize the structure that we get (this is not the best place to do this...)  
  if (isstruct(models))
    models = mat2cell(models, size(models,1), ones(size(models,2),1));
  end;
  
  
  
  ipd.mean = zeros(length(models),1);
  ipd.std  = zeros(length(models),1);
  for ss=1:length(models)
      ms = de_LoadProps(models{ss}, 'ac', 'Weights');
      
      inPix = prod(ms(1).nInput);

      [~,mupos] = de_connector_positions(ms(1).nInput, ms(1).nHidden/ms(1).hpl);
      clear('j1','j2');

      dists = zeros(length(ms), ms(1).nHidden, ms(1).nConns);
      d2    = zeros( size(dists) );

      for mm=1:length(ms)
          m = ms(mm);
          
          % Grab the connections to this hidden unit
          cc= full(m.ac.Weights~=0);
          cc=reshape( cc(inPix+1+[1:m.nHidden], 1:inPix), [m.nHidden m.nInput]);

          % For each hidden POSITION
          for hh=1:m.nHidden/m.hpl
          
            % Find the position in the image of each 
            %   connected unit
            [cy,cx] = find(squeeze(cc(hh,:,:)));
            if (length(cy)~=m.nConns)
                %guru_assert(length(cy)==m.nConns);
                fprintf('%d-%d-%d: length(cy)==%d\n', ss, mm, hh, length(cy));
                continue;
            end;
            if (isempty(cx))
                dist = zeros(length(cx));
            else
                dist = inf(length(cx));
            end;
            
            %  For each connected unit
            for ci=1:length(cx)
            
              % Average distance from center
              d2(mm,hh,ci) = sqrt( (cx(ci)-mupos(hh,1)).^2 + (cy(ci)-mupos(hh,2)).^2);
              % keyboard

              % Manual search for nearest neighbor
              for di=ci+1:length(cx)
                % Interpatch distance
                dist(ci,di) = sqrt( (cx(ci)-cx(di)).^2 + (cy(ci)-cy(di)).^2);
                dist(di,ci) = dist(ci,di); % avoid double-counting by removing this line
              end;
            end;
            
            if (isempty(dist))
                if (ismember(1, m.debug))
                    fprintf('Couldn''t find a nearest neighbor?');
                    keyboard
                end;
%                dists(mm,hh,1:length(cx)) = 0;
            else
                dists(mm,hh,1:length(cx)) = min(dist);
            end;
          end;
      end;
      
      ipd.mean_nearest_neighbor(ss) = mean(dists(dists(:)>0))'; %inter-patch distance
      ipd.std_nearest_neighbor(ss)  = std(dists(dists(:)>0))';
      ipd.mean_from_center(ss) = mean(d2(d2(:)>0));      %average distance from center
      ipd.std_from_center(ss) = std(d2(d2(:)>0));
  end;
  
%  disp('inter-patch distance:');
%  ipd.mean'    %inter-patch distance
%  disp('average distance from center:');
%  ipd.mean2   %average distance from center
  
