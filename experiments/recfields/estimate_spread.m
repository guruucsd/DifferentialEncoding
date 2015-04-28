function [mean_mean_neighbor_dist,mean_neighbor_dist,neighbor_dist] = estimate_spread(model,npts)
if ~exist('npts','var'), npts = 33; end;

mean_neighbor_dist = zeros(npts,1);
neighbor_dist = zeros(npts,sum(1:(model.nConns-1)));
for ii=1:npts
    if false % discrete case
        all_conns = de_connect_random(model);
        hu_conns = reshape(all_conns(prod(model.nInput)+2, 1:prod(model.nInput)), model.nInput);%de_connector2D([35 35],1,1,5,'norme',nan,5,1:10,1);%,weight_factor, want_fully
        [mean_neighbor_dist(ii),~,neighbor_dist(ii,:)] = calc_neighbor_dist(hu_conns);
        %figure; imshow(full(reshape(hu_conns, nInput)));

    else % continuous case
        all_samps = mvnrnd([0 0], [1.5 0.75]*model.sigma, model.nConns);
        [mean_neighbor_dist(ii),~,neighbor_dist(ii,:)] = calc_neighbor_dist(all_samps(:,1), all_samps(:,2));
    end;
end;

mean_mean_neighbor_dist = mean(mean_neighbor_dist);