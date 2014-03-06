function [minmax] = guru_minmax(data, opt)
%[minmax] = guru_minmax(data)
%  outputs [min max] of data matrix
%
% guru_minmax(data,opt)
%   opt:
%     'none'--(default) get actual min & max
%     'equal'--make min and max symmetric around zero

    if (any(imag(data(:)))), error('This function does not work for complex/imaginary data!'); end;

    if (~exist('opt','var')), opt = 'none'; end;

    switch (opt)
        case 'none',  minmax = [min(data);max(data)];
        case 'equal', minmax = [-max(abs(data));max(abs(data))];
        otherwise, error('Unrecognized option: %s', opt);
    end;

    % Turn into row vector
    if (nnz(size(minmax)-1)==1)
        minmax = reshape(minmax, [1 numel(minmax)]);
    end;