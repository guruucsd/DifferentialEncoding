function [testdata] = r_forwardpass(net,pats,data)
    ns = net.sets;
    
    %%%%%%%%%%%%%%
    
    % Error
    testdata.E    = zeros(pats.tsteps,pats.npat,net.noutput, 'single');
    testdata.ypat = zeros(pats.tsteps,pats.npat,net.noutput,'single');


    global backIdx fwdIdx  biIdx  biIncr;
    global upidx   outidx;

    r_init_indices(net,pats);

    %%%%%%%%%%%%%%

    % Forward pass
    I     = zeros(pats.tsteps,pats.npat,net.nunits);
    x     = zeros(pats.tsteps,pats.npat,net.nunits);
    fx    = zeros(size(x));
    fpx   = zeros(size(x));
    y     = zeros(pats.tsteps,pats.npat,net.nunits);
    dy    = zeros(size(y));
    
    I(:,:,1:1+net.ninput) = pats.P;  %patterns defined for input nodes; I is for all nodes
    dy(:) = 0;

    T_repd      = repmat(reshape(net.T, [1 size(net.T')]),[1 pats.npat 1]);
    w_repd      = repmat(reshape(net.w, [1 size(net.w)]), [pats.npat 1 1]);
    D_repd      = repmat(reshape(net.D, [1 size(net.D)]), [pats.npat 1 1]);

    dt_div_T    = ns.dt./T_repd;       % pre-calculate commonly used value

    for ti=1:pats.tsteps
        bi = (backIdx{biIdx(ti)}+biIncr(ti));

        % Calculate dy and y
        if (ti==1)
            dy(1,:,:)     = 0;
            y (1,:,:)     = I(1,:,:) + net.fn.f(0);
        else
            dy(ti,:,:)     = 0;
            dy(ti,:,upidx) = dt_div_T(:,:,upidx) .* (-y(ti-1,:,upidx) + fx(ti-1,:,upidx) + I(ti,:,upidx)); %p88, eqn4
            y (ti,:,:)     = y(ti-1,:,:) + dy(ti,:,:);
        end;
            
        % Calculate x and fx SECOND.  Y precedes x; so y(ti) should ref
        % x(ti-1) and x(ti) should ref y(ti)
        % Use most efficient time-indexing function to compute x(t)
        
        x(ti,:,:)   = sum(w_repd .* (y(bi).*(D_repd<=ti)), 2);
        fx(ti,:,:)  = net.fn.f(x(ti,:,:));
        fpx(ti,:,:) = net.fn.fp(x(ti,:,:), fx(ti,:,:));
        
        fx(ti,:,outidx) = net.fn.fo(x(ti,:,outidx));
        fpx(ti,:,outidx) = net.fn.fpo(x(ti,:,outidx),fx(ti,:,outidx));
    end;

    testdata.E    = pats.s .* net.fn.Err(y(:,:,outidx), pats.d);

    % Save some stats
    testdata.ypat = y(:,:,outidx);
    testdata.y    = y;

    lerr             = net.fn.sse(testdata.ypat, pats.d);
    testdata.avgerr  = reshape(mean(lerr,2),  [size(lerr,1)   size(lerr,3)]);
