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
  
  
  
  ipd.nn_dists = cell(length(models), 1);
  ipd.fc_dists = cell(length(models), 1);
  
  for ss=1:length(models)
      ms = models{ss};
      if (~isfield(ms(1), 'ac')...              % Load weights 
       || ~isfield(ms(1).ac, 'Conn') ...
       || isempty(ms(1).ac.Conn))
          if (~isfield(ms(1).ac, 'Weights'))
              ms = de_LoadProps(ms, 'ac', 'Weights');
          end;
          
          for ii=1:length(ms)
            ms(ii).ac.Conn = logical(ms(ii).ac.Weights ~= 0);
          end;
      end;
      
      inPix = prod(ms(1).nInput);

      [~,mupos] = de_connector_positions(ms(1).nInput, ms(1).nHidden/ms(1).hpl);

      nn_dists = cell(length(ms), ms(1).nHidden);
      fc_dists = cell(length(ms), ms(1).nHidden);

      for mm=1:length(ms)
          m = ms(mm);

          if (ismember(1,m.debug))
              inPix   = prod(m.nInput);
              alllyrs = squeeze(sum(reshape(full(m.ac.Conn(inPix+1+[1:m.nHidden], 1:inPix)), [m.nHidden m.nInput])));
              noconn  = length(find(alllyrs==0));
              if (noconn>0)
                  fprintf('Missing connections (%3d/%4d of ''em) for model{%d,%d}\n', noconn, inPix, ss, mm);
              end;
          end;
          
          % Grab the connections to this hidden unit
          if (~isfield(m.ac,'Conn'))
              m.ac.Conn = (m.ac.Weights ~= 0);
          end;
          cc=reshape( full(m.ac.Conn(inPix+1+[1:m.nHidden], 1:inPix)), [m.nHidden m.nInput]);

          % For each hidden POSITION
          for hui=1:m.nHidden
            hh = 1+mod((hui-1), m.nHidden/m.hpl);
          
            % Find the position in the image of each 
            %   connected unit
            [cy,cx] = find(squeeze(cc(hui,:,:)));
            
            if (isempty(cx))
                nn_dist = zeros(0, 0);
            else
                nn_dist = inf(length(cx),length(cx));
            end;
            
            %  For each connected unit
            for ci=1:length(cx)
            
              % Average distance from center
              fc_dists{mm,hui}(ci) = sqrt( (cx(ci)-mupos(hh,2)).^2 + (cy(ci)-mupos(hh,1)).^2);
              % keyboard

              % Manual search for nearest neighbor
              for di=ci+1:length(cx)
                % Interpatch distance
                nn_dist(ci,di) = sqrt( (cx(ci)-cx(di)).^2 + (cy(ci)-cy(di)).^2);
                nn_dist(di,ci) = nn_dist(ci,di); % must include this, for the min below to work.
              end;
            end;
                
            % 0 connections for this hu
            if (isempty(nn_dist))
                if (nnz(cy)>0)
                    error('Couldn''t find a nearest neighbor?');
                elseif (ismember(11, m.debug))
                    fprintf('No connections for model{%d,%d} to hu # %d?\n', ss, mm, hui);
                end;
                nn_dists{mm,hui} = []; %these will be removed
                
            % 1 connection--only at center
            elseif ~any(~isinf(nn_dist(:)))
                if (numel(nn_dist)~=1)
                    error('All distances = inf?');
                end;
                nn_dists{mm,hui} = []; %these will be removed
                
            elseif any(nn_dist(:)<1)
                keyboard
                
            else
                %nn_dist = nn_dist(1:end-1,2:end); % dist is upper triangular; only off-diagonal elements
                %                            % make sense.  Select only the comparisons that make sense.
                nn_dists{mm,hui} = min(nn_dist);
                
            end;
          end;
      end;
      
      ipd.nn_dists{ss} = nn_dists;
      ipd.fc_dists{ss} = fc_dists;
      ipd.nearest_neighbor_mean(ss)  = mean(horzcat(nn_dists{:})); %inter-patch distance
      ipd.nearest_neighbor_std (ss)  = std (horzcat(nn_dists{:}));
      ipd.from_center_mean(ss)       = mean(horzcat(fc_dists{:}));     %average distance from center
      ipd.from_center_std (ss)       = std (horzcat(fc_dists{:}));
      if (ismember(10, models{1}(1).debug)) % show mean, per model
          for ii=1:size(nn_dists,1), abc(ii) = mean(horzcat(nn_dists{ii,:})); end;
          abc
      end;
      
      % 
      dfc = sqrt( sum((mupos - repmat(m.nInput/2, [size(mupos,1) 1])).^2, 2) );
      [~,closest_idx] = sort(dfc); %distance of each hu pos from center
      
      % Repeat analyses, but for closest to center (i.e. least edge effects)
      nn_dists_closest = nn_dists(:,closest_idx(1:round(0.10*length(closest_idx))));
      fc_dists_closest = fc_dists(:,closest_idx(1:round(0.10*length(closest_idx))));
      ipd.top10.nearest_neighbor_mean(ss)  = mean(horzcat(nn_dists_closest{:})); %inter-patch distance
      ipd.top10.nearest_neighbor_std (ss)  = std (horzcat(nn_dists_closest{:}));
      ipd.top10.from_center_mean(ss)       = mean(horzcat(fc_dists_closest{:}));      %average distance from center
      ipd.top10.from_center_std (ss)       = std (horzcat(fc_dists_closest{:}));
      
      nn_dists_closest = nn_dists(:,closest_idx(1:round(0.05*length(closest_idx))));
      fc_dists_closest = fc_dists(:,closest_idx(1:round(0.05*length(closest_idx))));
      ipd.top5.nearest_neighbor_mean(ss)  = mean(horzcat(nn_dists_closest{:})); %inter-patch distance
      ipd.top5.nearest_neighbor_std (ss)  = std (horzcat(nn_dists_closest{:}));
      ipd.top5.from_center_mean(ss)       = mean(horzcat(fc_dists_closest{:}));      %average distance from center
      ipd.top5.from_center_std (ss)       = std (horzcat(fc_dists_closest{:}));

      nn_dists_closest = nn_dists(:,closest_idx(1:round(0.25*length(closest_idx))));
      fc_dists_closest = fc_dists(:,closest_idx(1:round(0.25*length(closest_idx))));
      ipd.top25.nearest_neighbor_mean(ss)  = mean(horzcat(nn_dists_closest{:})); %inter-patch distance
      ipd.top25.nearest_neighbor_std (ss)  = std (horzcat(nn_dists_closest{:}));
      ipd.top25.from_center_mean(ss)       = mean(horzcat(fc_dists_closest{:}));      %average distance from center
      ipd.top25.from_center_std (ss)       = std (horzcat(fc_dists_closest{:}));
  end;
  
  fprintf('[Total  ]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
          100*diff(ipd.nearest_neighbor_mean)      /mean(ipd.nearest_neighbor_mean), ...
          100*diff(ipd.from_center_mean)           /mean(ipd.from_center_mean));
  fprintf('[Top  5%%]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
          100*diff(ipd.top5.nearest_neighbor_mean) /mean(ipd.top5.nearest_neighbor_mean), ...
          100*diff(ipd.top5.from_center_mean)      /mean(ipd.top5.from_center_mean));
  fprintf('[Top 10%%]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
          100*diff(ipd.top10.nearest_neighbor_mean)/mean(ipd.top10.nearest_neighbor_mean), ...
          100*diff(ipd.top10.from_center_mean)     /mean(ipd.top10.from_center_mean));
  fprintf('[Top 25%%]\t%5.2f%% diff to nearest neighbor;\t%5.2f%% diff from center\n', ...
          100*diff(ipd.top25.nearest_neighbor_mean)/mean(ipd.top25.nearest_neighbor_mean), ...
          100*diff(ipd.top25.from_center_mean)     /mean(ipd.top25.from_center_mean));
  
%  disp('inter-patch distance:');
%  ipd.mean'    %inter-patch distance
%  disp('average distance from center:');
%  ipd.mean2   %average distance from center
  
