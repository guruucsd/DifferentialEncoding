function w = guru_nnInitWeights(c,type,params)
%
%
%
  sz = size(c);
  switch (type)
    case 'rand',        w = rand(sz);

    case 'rand-normd',  if (~exist('params','var')), params=[0 1]; end;
                        w = guru_nnInitWeights(c,'rand');
                        w = (w - params(1))/(params(2));

    case 'randn',       w = randn(sz);

    case 'randn-normd', w = guru_nnInitWeights(c,'randn');
                        w = w / (max(max(w)));

    case 'sprand',      w = sprand(c);

    case 'sprand-normd',if (~exist('param','var')), params=[0 1]; end;
                        w = guru_nnInitWeights(c, 'sprand');
                        w = (w - params(1))/params(2);

    case 'sprandn',     w = sprandn(c);

    case 'sprandn-normd',w = guru_nnInitWeights(c,'sprandn');
                        w = w / (max(max(w)));

    otherwise
      error('Unknown weight init type: %s', type);
  end;

  w = c.*w;

  % Now divide by fan-in
  ninputs = sum(c,2);
  fan_in  = repmat(1./ninputs,[1 size(c,2)]);

  w(~isinf(fan_in)) = w(~isinf(fan_in)).*fan_in(~isinf(fan_in));
