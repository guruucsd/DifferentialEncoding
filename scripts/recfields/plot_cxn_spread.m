%clear all;
sigs = [0.5 1:10];
nconns = 2:3:20;

if ~exist('means','var')
    means      = zeros(length(sigs),length(nconns));
    emp_means  = zeros(length(sigs),length(nconns));
    gam_params = zeros([2 size(means)]);
end;
for si=1:length(sigs)
    for ni=1:length(nconns)
        if ~emp_means(si,ni)
            [gam_params(:,si,ni),emp_means(si,ni)] =  min_nn_dist(sigs(si), nconns(ni), 10000);
        end;
        means(si,ni) = prod(gam_params(:,si,ni));
        fprintf('[%4.1f %2d]: Empirical vs. estimated means: %5.3f vs. %5.3f\n', sigs(si), nconns(ni), emp_means(si,ni), prod(gam_params(:,si,ni)));
    end;
end;

%
figure('Position',[   175   -21   953   705]); 
subplot(2,2,1);
imagesc((means))
ylabel('sigmas');
xlabel('# conns');
set(gca, 'ytick', 1:length(sigs),   'yticklabel', sigs);
set(gca, 'xtick', 1:length(nconns), 'xticklabel', nconns);
colorbar;

subplot(2,2,2);
[Y,X] = meshgrid(nconns,sigs);
x=log(X(:)); y=log(Y(:)); z=log(means(:));
[~,gz]= regress_plane(x,y,z);
surf(log(X),log(Y),log(means));
hold on;
surf(log(X),log(Y),gz(log(X),log(Y)))
axis tight;



subplot(2,2,3);
imagesc((emp_means))
ylabel('sigmas');
xlabel('# conns');
set(gca, 'ytick', 1:length(sigs),   'yticklabel', sigs);
set(gca, 'xtick', 1:length(nconns), 'xticklabel', nconns);
colorbar;

subplot(2,2,4);
[Y,X] = meshgrid(nconns,sigs);
x=log(X(:)); y=log(Y(:)); z=log(emp_means(:));
[~,gz]= regress_plane(x,y,z);
surf(log(X),log(Y),log(emp_means));
hold on;
surf(log(X),log(Y),gz(log(X),log(Y)))
axis tight;

pred_min_nn_dist = @(sig,nconn) exp(gz(log(sig),log(nconn)));
find_nconn       = @(min_nn_dist,sig)   fminsearch(@(nconn) abs(min_nn_dist - pred_min_nn_dist(sig,nconn)), 10);
find_sig         = @(min_nn_dist,nconn) fminsearch(@(sig)   abs(min_nn_dist - pred_min_nn_dist(sig,nconn)), 5);


vary_nn_dist = @(min_nn_dist,nconn,pct_diff) [find_sig(min_nn_dist*(1-pct_diff/2),nconn) find_sig(min_nn_dist*(1+pct_diff/2),nconn)];



