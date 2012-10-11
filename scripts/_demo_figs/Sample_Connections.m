% Show sample distributions of wide vs narrow connections

clear all; close all;


addpath(genpath('../../code');
de_SetupExptPaths('young_bion_1981');


nConns    = 25;              % # connections from hidden->input/output
sigmas    = [3 16];
imageSize = [34 25];      % input/output size
gshape    = [2.5 0;0 1];      % multivariate gaussian sigma shape
huloc     = imageSize/2;    % position of hidden unit in center of image
gridfreq  = 0.5;
nSamples  = 1000;

%a = de_connector2D([34 25],1,1,25,'norme',0,3,0,1); %
%a(:,851)==input=>hidden

% Sample the connections
allcxns = zeros([nSamples length(sigmas) nConns 2]);
allsamps = zeros([length(sigmas) imageSize]);

for n=1:nSamples
    for i=1:length(sigmas)
        cxns = zeros(0,2);
        
        theta=2*pi*rand;
        rmat = [cos(theta) sin(theta);-sin(theta) cos(theta)];
        mvsig = sigmas(i)*(rmat*gshape);
        while (size(cxns,1)<nConns)
          newcxns   = round(mvnrnd(imageSize/2, sigmas(i)*gshape, nConns)); %connection points

          badcxns   = (newcxns(:,1)<1            | newcxns(:,2)<1 ...
                    | newcxns(:,1)>imageSize(1) | newcxns(:,2)>imageSize(2));
          newcxns   = setdiff(newcxns(~badcxns,:), cxns, 'rows');

          cxns      = [cxns;newcxns];
          %fprintf(' %d', length(cxns));
        end;
        cxns = cxns(randperm(size(cxns,1)), :); % Gotta cut back, 
        cxns = cxns(1:nConns,:);                % but the conns were sorted
        
        %
        allcxns(n,i,:,:) = cxns;
        
        % put the samples into bins by 
        allsamps(i, cxns(:,1), cxns(:,2)) = allsamps(i, cxns(:,1), cxns(:,2)) + 1;
        %allsamps(i, cxns) = allsamps(i, cxns) + 1;
    end;
end;
allsamps = allsamps/nSamples/nConns;


%%%%%%%%%%%%%%%
% 3D average plot of connectivity
%%%%%%%%%%%%%%%
zl = [0 max(allsamps(:))]*2/3;
figure;
set(gcf, 'Position', [78          71        1098         606])
for i=1:length(sigmas)
    subplot(1,length(sigmas),i); hold on;
    daspect(gca, [1 1 1/50])
    
    grd = squeeze(allsamps(i,:,:));
    
    view(-32,44);
    caxis(zl);
    set(gca, 'xlim', [1 imageSize(1)], 'ylim', [1 imageSize(2)], 'zlim', zl);
    %set(gca, 'ztick', [0 1 2], 'zticklabel', {'Input', 'Hidden', 'Output'});
    set(gca, 'xtick', [], 'ytick', []);

    %Plot input/output layers
    %[X,Y] = meshgrid(1:imageSize(1), 1:imageSize(2)); % all inputs
    surf(grd');
    plot3(huloc(1), huloc(2), grd(round(huloc(1)), round(huloc(2))), 'go','MarkerSize', 5, 'LineWidth', 5);
end;



%%%%%%%%%%%%%%%
% 3D instance plot of connectivity
%%%%%%%%%%%%%%%
figure;
set(gcf, 'Position', [78          71        1098         606])

for i=1:length(sigmas)
    subplot(1,length(sigmas),i); hold on;
    daspect(gca, [1 1 1/10])
    
    cxns = squeeze(allcxns(1,i,:,:));
    
    view(-28,43);
    set(gca, 'xlim', [1 imageSize(1)], 'ylim', [1 imageSize(2)], 'zlim', [0 2]);
    set(gca, 'xtick', [], 'ytick', []);
    set(gca, 'ztick', [0 1 2], 'zticklabel', {'Input', 'Hidden', 'Output'});

    %Plot input/output layers
    [X,Y] = meshgrid(1:gridfreq:imageSize(1), 1:gridfreq:imageSize(2)); % all inputs
    plot3(X,Y, zeros(size(X)),  'k.', 'MarkerSize', 0.5);  % input layer: 
    plot3(X,Y, 2*ones(size(X)), 'k.', 'MarkerSize', 0.5);

    %inputs
    plot3(cxns(:,1), cxns(:,2), 0*ones(size(cxns(:,2))), 'bo','MarkerSize', 5, 'LineWidth', 5);

    % outputs
    plot3(cxns(:,1), cxns(:,2), 2*ones(size(cxns(:,2))), 'bo','MarkerSize', 5, 'LineWidth', 5);

    % connect them
    for j=1:size(cxns,1), plot3([cxns(j,1) huloc(1)], [cxns(j,2), huloc(2)], [0 1]); end;
    for j=1:size(cxns,1), plot3([cxns(j,1) huloc(1)], [cxns(j,2), huloc(2)], [2 1]); end;

    % hidden unit
    plot3(huloc(1), huloc(2), 1,  'ro','MarkerSize', 10, 'LineWidth', 10)
    
%    zoom(2);
end;

