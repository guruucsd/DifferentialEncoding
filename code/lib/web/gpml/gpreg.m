function [hyp, inffunc, meanfunc, covfunc, likfunc] = gpreg(x,y,exact)

[npts,nvars] = size(x);

if length(y) ~= npts, error('x and y don''t match size'); end;

%clear all, close all
if ~exist('exact','var'), exact = true; end;
if ~exist('pow','var'), pow = 10; end;

%covfunc = {@covMaterniso, 3}; ell = 1/4; sf = 1; hyp.cov = log([ell; sf]);

%%
%nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y)
%[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);

%set(gca, 'FontSize', 24)
%f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
%fill([z; flipdim(z,1)], f, [7 7 7]/8);
%hold on; plot(z, m, 'LineWidth', 2); plot(x, y, '+', 'MarkerSize', 12)
%axis tight;
%grid on
%xlabel('input, x')
%ylabel('output, y')


%%
meanfunc = {@meanSum, {@meanLinear, @meanConst}}; hyp.mean = [0.25*ones(nvars,1); 1];
covfunc = {@covSEiso}; hyp.cov = [1; 1]; hyp.lik = log(0.1);
%covfunc = {@covPoly, pow}; hyp.cov = [1; 1]; hyp.lik = log(0.1);
likfunc = @likGauss; sn = 0.1; hyp.lik = log(sn);
% Turn into approx
if ~exact
    nu = fix(npts/2); u = repmat(linspace(-1.3,1.3,nu)', [1 nvars]);
    covfunc = {@covFITC, covfunc, u};
    inffunc = @infFITC;
else
    inffunc = @infExact;
end;


% minmize with no mean
hyp = minimize(hyp, @gp, -100, inffunc, meanfunc, covfunc, likfunc, x, y);
exp(hyp.lik)
nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y)


% Do output
switch nvars
    case 1, plot_gp_univariate(x,y,hyp,inffunc,meanfunc,covfunc,likfunc);
    case 2, plot_gp_bivariate(x,y,hyp,inffunc,meanfunc,covfunc,likfunc);
    otherwise, error('not implemented for >2 vars');
end;

function plot_gp_univariate(x,y,hyp,inffunc,meanfunc,covfunc,likfunc)
    xdist = max(x)-min(x);
    zx = linspace(min(x)-xdist*.25, max(x)+xdist*.25, 25)'; % interpolate, and extrapolate by 25%

    [zm zs2 fm fs2] = gp(hyp, inffunc, meanfunc, covfunc, likfunc, x, y, zx);
    figure;
    gpplot(zx,zm,zs2,x,y);
    

function plot_gp_bivariate(x,y,hyp,inffunc,meanfunc,covfunc,likfunc);
    npts = size(x,1);
    
    %% Plot result
    figure; set(gcf,'Position', [151   -11   921   695]);
    uv1 = unique(x(:,1));
    uv2 = unique(x(:,2)); %uv2 = uv2([1 end]);
    luv1 = length(uv1);
    npairs = npts/luv1;

    %zx = zeros(luv1,npairs);
    %zy = zeros(size(zx));
    %zm = zeros(size(zx));
    for vi=1:npairs
        zx = x((vi-1)*luv1+[1:luv1],:);
        zy = y((vi-1)*luv1+[1:luv1],:);

        % Get the results
        [zm(:,vi) zs2(:,vi), fm, fs2] = gp(hyp, inffunc, meanfunc, covfunc, likfunc, x, y, zx);


        subplot(1,npairs,vi);
        gpplot(zx,zm(:,vi),zs2(:,vi),zx(:,1),zy)
    end;

    % Map out a larger space to check generalization
    figure;
    uv2range = uv2(end)-uv2(1);
    bws = linspace(uv2(1)-0.5*uv2range,uv2(end)+0.5*uv2range,50);
    [Y,X] = meshgrid(bws,uv1);
    Z = zeros(size(Y));
    for bwi=1:length(bws)
        Z(:,bwi) = gp(hyp, inffunc, meanfunc, covfunc, likfunc, x, y, [uv1 bws(bwi)*ones(size(uv1))]);
    end;
    surf(X,Y,Z);
    xlabel('axon diameter ( \mu m)');
    ylabel('log_{10}(brain weight)');
    view(47.5, 54)
    axis tight;

