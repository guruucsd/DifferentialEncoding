freqs = [ 0.0001 0.01 * [ 1.5 3 6 12 18 24 30 36] 0.5];
args  = { 'freqs',  freqs, ...
         'nin',    7, ...
         'nsamps', 10 ...
       };

std_mean = zeros(0, length(freqs));
std_std  = zeros(size(std_mean));

% Circular
[~,b]=nn_2layer(args{:}, 'Sigma', [20 0; 0 20]*4); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
[~,b]=nn_2layer(args{:}, 'Sigma', [20 0; 0 20]*2); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
[~,b]=nn_2layer(args{:}, 'Sigma', [20 0; 0 20]/1); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
[~,b]=nn_2layer(args{:}, 'Sigma', [20 0; 0 20]/2); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
ncirc = size(std_mean,1);

% Elongated, same orientation
[~,b]=nn_2layer(args{:}, 'Sigma', [40 0; 0 10]*4); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
[~,b]=nn_2layer(args{:}, 'Sigma', [40 0; 0 10]*2); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
[~,b]=nn_2layer(args{:}, 'Sigma', [40 0; 0 10]/1); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
[~,b]=nn_2layer(args{:}, 'Sigma', [40 0; 0 10]/2); std_mean(end+1,:) = mean(b,1); std_std(end+1,:) = std(b,[],1);
nelong = size(std_mean,1)-ncirc;

% Plot Circular
figure;
plot(freqs, std_mean(1:ncirc,:)');
legend(guru_csprintf('c%d', mat2cell(1:ncirc)));

% plot Elongated
figure;
plot(freqs, std_mean(ncirc+[1:nelong],:)');
legend(guru_csprintf('c%d', mat2cell(1:nelong)));

% plot circular vs Elongated

