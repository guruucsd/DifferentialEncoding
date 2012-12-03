function r_init_indices(net,pats)
%

    ns = net.sets;


    global backIdx fwdIdx  biIdx  biIncr;
    global upidx outidx;

    backIdx = cell(ns.tsteps+1,1); % each 61x1 column represents the indices into y, to get y(t-delay)_ij to a particular unit i
    fwdIdx  = cell(ns.tsteps+1,1); % each 61x1 column represents the indices into z, to get z(t+delay)_ij to a particular unit i
    biIdx   = zeros(ns.tsteps+1,1);
    biIncr  = zeros(ns.tsteps+1,1);

    ii = repmat(1:net.nunits,[net.nunits 1])'; %index of units connecting to
    for ti=1:ns.tsteps+1;
        bi = ns.tsteps*pats.npat*(ii-1) + max(1,            ti-(net.D-1));
        fi = ns.tsteps*pats.npat*(ii-1) + min(ns.tsteps,ti+(net.D-1));
        
        backIdx{ti} = repmat(reshape(bi, [1 size(bi)]), [pats.npat 1 1]);
        fwdIdx{ti}  = repmat(reshape(fi, [1 size(fi)]), [pats.npat 1 1]);
        
        backIdx{ti} = backIdx{ti} + repmat(ns.tsteps*[0:pats.npat-1]', [1 size(bi)]);
        fwdIdx {ti} = fwdIdx {ti} + repmat(ns.tsteps*[0:pats.npat-1]', [1 size(bi)]);
        
        biIdx(ti)  = min(ti, ns.D_LIM(2));
        biIncr(ti) = max(0, ti-ns.D_LIM(2));
        
        for p=1:pats.npat
            % validate
            if (ti<=pats.tsteps)
                [a,b,c] = ind2sub([pats.tsteps,pats.npat,net.nunits], squeeze(backIdx{ti}(p,:,:)));
                if (any(find(b~=p))), error('backIdx pattern check failed'); end;
                if (any(find(c-ii))), error('backIdx node check failed'); end;
%                if (length(find(a~=ti))>(net.ncc.^2*4)), error('backIdx delay check failed'); end;
            end;
            
            [a,b,c] = ind2sub([pats.tsteps,pats.npat,net.nunits], squeeze(fwdIdx{ti}(p,:,:)));
            if (any(find(b~=p))), error('fwdIdx pattern check failed'); end;
            if (any(find(c-ii))), error('fwdIdx node check failed'); end;
%            if (ti<=pats.tsteps)
%                if (length(find(a~=ti))>(net.ncc.^2*4)), error('fwdIdx delay check failed'); end;
%            else
%                if (length(find(a~=pats.tsteps))>(net.ncc.^2*4)), error('fwdIdx delay check failed'); end;
%            end;
        end;
    end;
    backIdx = backIdx(1:min(ns.tsteps,ns.D_LIM(2)));


    % size(y) = tsteps, pats, nodes
    % tests (non-boundary):
    %    [a,b,c] = ind2sub([pats.tsteps,pats.npat,net.nunits], squeeze(fwdIdx{1}(1,:,:)))
    %    [a,b,c] = ind2sub([pats.tsteps,pats.npat,net.nunits], squeeze(backIdx{pats.tsteps}(1,:,:)))
    % tests (boundary)
    %    [a,b,c] = ind2sub([pats.tsteps,pats.npat,net.nunits], squeeze(fwdIdx{pats.tsteps+1}(1,:,:)))
    %    [a,b,c] = ind2sub([pats.tsteps,pats.npat,net.nunits], squeeze(backIdx{1}(1,:,:)))



    %%%%%%%%%%
        
    %network 
    upidx  = 1+[1:net.nunits-1];  %update input, hidden & output units
    outidx = 1+net.ninput+net.nhidden+[1:net.noutput];

