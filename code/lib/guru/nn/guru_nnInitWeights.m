function w = guru_nnInitWeights(sz,type,params)
%
%
%

  switch (type)
    case 'rand',        w = rand(sz);
      
    case 'rand-normd',  if (~exist('params','var')), params=[0.5 1]; end;
                        w = guru_nnInitWeights(sz,'rand');
                        w = (w - params(1))/(params(2));
                        
    case 'randn',       w = randn(sz);
      
    case 'randn-normd', w = guru_nnInitWeights(sz,'randn');
                        w = w / (max(max(w)));
                        
    otherwise
      error('Unknown weight init type: %s', type);
  end;
