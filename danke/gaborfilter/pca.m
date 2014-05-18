function [a,ev]=pca(f,N)
% [a,ev]=pca(f,N)
%
% INPUT:
%   f    = matrix of images. (individual images are row vectors)
%   N    = the number of eigenpairs to compute. [default ALL]
%
% OUTPUT:
%   a   = comumn vectors of temporal principal components.
%   ev  = PCA eigenvalues in descending order.

disp('Forming the correlation matrix ...');
cor = f'*f;     % the pixel-correlation matrix.

if nargin < 2       % If N is not specified, compute all eigenpairs.
  N = size(f,2);
end;

disp('Diagonalizing ...')
[a,ev]=eig(cor);           % compute the temporal eigenvectors/values.
[ev,ind]=sort(diag(ev));   % sort in ascending magnitude.
ev=flipud(ev);             % switch from ascending to descending.
a=a(:,flipud(ind));        % order the temporal eigenvectors accordingly.
disp('Calculating PCA eigenvectors ...')
a=a(:,1:N);
