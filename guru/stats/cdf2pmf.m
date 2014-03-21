function d = cdf2pmf(cdf,x,p)
%function d = cdf2pmf(cdf,x,p1,p2)
%
% Takes a cdf and bin edges x, along with cdf parameters.
% Outputs the probability mass function for those bin edges
%
% cdf : function handle to the cdf function
% x : bin edges
% varargin: parameters of the distribution
%
% d : outputs for each of the bin edges.

  pcell = num2cell(p);
  d = (diff([0 cdf([x(1:end-1) inf], pcell{:})]));
