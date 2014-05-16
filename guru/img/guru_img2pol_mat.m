function rtcoeff = guru_img2pol_mat(imgsz)
%
% rt = A * xy;
% where xy and rt are [npix 1] sized vectors
%
% row of a are coefficients of xy
%  i.e. A(1,:) are coeffs for pix 1
%

% passed in image, not the size; that's fine, be smart :)
if numel(imgsz) ~= 2 && ndims(imgsz)==2, imgsz = size(imgsz); end;


npix = prod(imgsz);
midpt = imgsz/2;

[X,Y] = meshgrid(1:imgsz(2), 1:imgsz(1));
[TH,R] = cart2pol((X - midpt(2) - .5)/2,(Y - midpt(1) - .5)/2);

tsb = linspace(min(TH(:)),max(TH(:)),imgsz(1)); tsb=[tsb-diff(tsb(1:2))/2 tsb(end)+diff(tsb(1:2))]; nt=length(tsb)-1;
rsb = linspace(min(R(:)), max(R(:)), imgsz(2)); rsb=[rsb-diff(rsb(1:2))/2 rsb(end)+diff(rsb(1:2))]; nr=length(rsb)-1;

 % get all relevant points in this 'bin', then linearly interpolate end; end;
imgidx = cell(nt,nr);
for ti=1:nt
    for ri=1:nr
        curidx = find(rsb(ri)<R & R<=rsb(ri+1) & tsb(ti)<TH & TH<=tsb(ti+1))';
        imgidx{ti,ri} = curidx;
    end;
end;
if length([imgidx{:}]) ~= npix, error('failed to find some pixels'); end;

% Map values directly
rtcoeff = spalloc(npix,npix,round(npix*npix)*0.01);
for ti=1:nt
    for ri=1:nr

        %tsb(ti+1)-tsb(ti)
        error_vector  = sqrt( (R(imgidx{ti,ri})-rsb(ri+1)).^2 + (TH(imgidx{ti,ri})-tsb(ti+1)).^2 );
        maxerr_vector = sqrt( (rsb(ri+1)-rsb(ri)).^2        + (tsb(ti+1)-tsb(ti)).^2 );
        qt            = error_vector./maxerr_vector;
        coeff         = 1.01 - qt./sum(qt);
        coeff2        = coeff./sum(coeff);

        guru_assert(~any(isnan(coeff2)));
        if sum(coeff2) ==0, coeff2=inf; end;
        rtcoeff(sub2ind(imgsz,ti,ri), imgidx{ti,ri}) = 1/length(imgidx{ti,ri});
    end;
end;

% Now, interpolate values
neighbors  = cell(nt,nr);
nneighbors = zeros(nt,nr);
touched    = false(nt,nr);
for ti=1:nt
    for ri=1:nr
        if (ti>1), neighbors{ti,ri} = [neighbors{ti,ri} sub2ind([nt nr], ti-1,ri)]; end;
        if (ti<nt),neighbors{ti,ri} = [neighbors{ti,ri} sub2ind([nt nr], ti+1,ri)]; end;
        if (ri>1), neighbors{ti,ri} = [neighbors{ti,ri} sub2ind([nt nr], ti,  ri-1)]; end;
        if (ri<nr),neighbors{ti,ri} = [neighbors{ti,ri} sub2ind([nt nr], ti,  ri+1)]; end;
        nneighbors(ti,ri) = length(neighbors{ti,ri});

        touched(ti,ri) = ~isempty(imgidx{ti,ri});
    end;
end;

allpix = find(~touched(:));
while ~isempty(allpix)
    % Determine how many neighbors are on
    pct_neighbors_on = zeros(length(allpix),1);
    for pi=1:length(allpix)
        cpix = allpix(pi);
        pct_neighbors_on(pi) = mean(touched(neighbors{cpix}));
    end;

    % For those with 4 neighbors, spread
    surrounded = find(pct_neighbors_on==max(pct_neighbors_on));
    for si=1:length(surrounded)
        cpix = allpix(surrounded(si));
        [ti,ri] = ind2sub(imgsz, cpix);
        cnb  = neighbors{cpix}(touched(neighbors{cpix}));

        error_vector  = sqrt( (R(cnb)-rsb(ri)).^2    + (TH(cnb)-tsb(ti)).^2 );
        maxerr_vector = sqrt( (rsb(ri+1)-rsb(ri)).^2 + (tsb(ti+1)-tsb(ti)).^2 );
        coeff = exp(1*error_vector./maxerr_vector);
        norm_coeff = coeff/sum(coeff);

        rtcoeff(cpix, :) = norm_coeff * rtcoeff(cnb,:);%mean(rtcoeff(cnb,:),1); % weighted coefficients of previous dude's pixels
        %rtcoeff(cpix, :) = mean(rtcoeff(cnb,:),1); % weighted coefficients of previous dude's pixels
        touched(cpix) = true;
    end;

    % Reduce the number of untouched
    allpix = setdiff(allpix, allpix(surrounded));
    if any(touched(allpix)), error('?'); end;
end;
