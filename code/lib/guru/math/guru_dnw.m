function [dnw_data,axes] = guru_dnw(data, varargin)
%data = dnw(data,varargin)
%  Decorrelates and whitens the data matrix.
%    Decorrelate: use PCA to rotate axes
%    Whiten: normalize eigenvectors
%
%    would be nice to separate these operations,
%    but the operations of one are involved in
%    the calculation of the other, so...
%
%  guru_dnw(data)
%    data: rows = measurements; columns = examples
%    keeps all pcs
%
%  guru_dnw(data,npc)
%    npc:  integer, # of principle components to reconstruct the images with
%
%  guru_dnw(data, axes)
%    axes: matrix of axes, used instead of PCA-based method.  Used so different sets of data can be transformed in the same way (rather than with the same method)
%

  nSamp = size(data,2);
  nDims = size(data,1);

  mn = mean(data,2);
  Z  = data - repmat(mn, [1 nSamp]);

  % Perform simple transform and get out!
  if (length(varargin)==1 && numel(varargin{1})>0)
      axes = varargin{1};
      dnw_data = axes*Z;
      return;
  end;

  switch (length(varargin))
      case 0, npc = min(size(data))-1; %minus one because we remove the mean, leading to a linear dependence in the data
      case 1, npc = varargin{1};
      otherwise, ('Too many inputs into function');
  end;


  %% Decorrelate the data by running PCA and projecting into
  %%   the space of the eigenvectors of the covariance matrix.
  %%  if v is an eigenvector of matrix ZZ'  with eigenvalue lambda
  %%   then    ZZ'v = lambda v
  %%   and multiplying both sides on the left by Z' we get
  %%          Z'ZZ'v = Z' lambda v
  %%          Z'ZZ'v = lambda Z'v (because lambda is a scalar we can move
  %%                                change it's order)
  %%          Z'Z(Z'v) = lambda(Z'v)    just regrouping
  %%    Therefore Z'v is a eigenvector of Z'Z with eigenvalue lambda (the
  %%                                                      same eigenvalue)
  %
  if (nSamp < nDims)
      [Vf, Df]  = eig(Z' * Z);        % Get the eigenvectors and eigenvalues of Z'Z
      [Vf, Df] = eigsort(Vf, Df);    % Sort them


      Vf       = Vf(:,1:end-1);      % Remove meaningless eigenvector
      Df       = Df(1:end-1,1:end-1);


      U        = Z * Vf;             % Use the math trick from part Z to get the eigenvectors of ZZ'
      normU    = normc(U);           % Ensure that the eigenvectors are unit length

  else
      [Vf, Df] = eig(Z * Z');        % Get the eigenvectors and eigenvalues of Z'Z
      [Vf, Df] = eigsort(Vf, Df);    % Sort them

      keyboard % I don't know if this code works.

      Vf       = Vf(:,1:end-1);      % Remove meaningless eigenvector
      Df       = Df(1:end-1,1:end-1);

      U        = Vf;                 % Use the math trick from part Z to get the eigenvectors of ZZ'
      normU    = normc(U);           % Ensure that the eigenvectors are unit length
  end;

  % Remove eigenvectors with too-small eigenvalues
  npc = min(npc, sum(diag(Df)>1E-10));

  %% Now whiten the data by scaling some quantity based on the eigenvalues
  %%
  %% Following code is based on:
  %% http://courses.media.mit.edu/2010fall/mas622j/whiten.pdf
  %%   eqn 3
  %
  %l_half     = Df(1:npc,1:npc)^(0.5);
  l_half_inv = Df(1:npc,1:npc)^(-0.5);

%  pc_data  = normU(:,1:npc)'*Z;
%  dnw_data = normU(:,1:npc)*l_half_inv*pc_data;

  % Here are the axes to do that in one step:
  axes     = normU(:,1:npc)*l_half_inv*normU(:,1:npc)'; % * Z will get you your whitened data

  dnw_data = axes*Z;

  % How to invert:
  %   * go back to PC space
  %   * multiply by sqrt(lambda)
  %   * rotate back to original space
  %   * add back mean


%%%%%%%
function [Vf,Df] = eigsort(Vf,Df)

      [~, ridx] = sort( diag(Df), 1, 'descend' ); % sort the eigenvectors by eigenvalue
      Vf = Vf(:,ridx);
      Df = diag(Df);
      Df = diag(Df(ridx));
