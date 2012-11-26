function rtcoeff = guru_img2polmat(imgsz)
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

ts = linspace(min(TH(:)),max(TH(:)),imgsz(1)); nt=length(ts);
rs = linspace(min(R(:)), max(R(:)), imgsz(2)); nr=length(rs);


 % get all relevant points in this 'bin', then linearly interpolate end; end;
imgidx = cell(nt,nr);
prev_ts = ts(1)-1/(2*npix);
for ti=1:nt
    prev_rs = rs(1)-1/(2*npix);
    for ri=1:nr
        curidx = find(prev_rs<R & R<=rs(ri) & prev_ts<TH & TH<=ts(ti))';
        imgidx{ti,ri} = curidx;
        prev_rs = rs(ri);
    end;
    prev_ts = ts(ti);
end;
if length([imgidx{:}]) ~= npix, error('failed to find some pixels'); end;

% Map values directly
rtcoeff = zeros(npix,npix);
for ti=1:nt
    for ri=1:nr
        if ~isempty(imgidx{ti,ri})
            rtcoeff(sub2ind(imgsz,ti,ri), imgidx{ti,ri}) = 1/length(imgidx{ti,ri});
        end;
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
        cnb  = neighbors{cpix}(touched(neighbors{cpix}));
        rtcoeff(cpix, :) = mean(rtcoeff(cnb,:),1); % weighted coefficients of previous dude's pixels
        touched(cpix) = true;
    end;
    
    % Reduce the number of untouched
    allpix = setdiff(allpix, allpix(surrounded));
    if any(touched(allpix)), error('?'); end;
end;
