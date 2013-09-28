function [plo,phi]=decomptest(t11,t12,t21,t22,rule,dep)
% DECOMPTEST Test for decomposition rule "rule" given unordered
% RTs from four conditions (T11,T12,T21,T22) and presumed dependency
% "dep" (0=s.-independence or 1=p.p.s.-interdependence) between the 
% components of Tij.  The function returns the lowest (plo) and highest 
% (phi) p-values of the Smirnov statistic D under the hypothesis that 
% the decomposition rule is "rule."  Rule can be anything, including
% "plus" (for addition), "min" (for minimum) or "max" (for maximum).
%
% Note that plo and phi both are not required.  For dep=0, only plo is
% needed.
%
% This routine makes use of the function THETA4, the fourth theta
% function, which provides the p-values.  It also uses EDF, which 
% computes the empirical distribution function.
if dep==1 
   t11 = sort(t11);
   t12 = sort(t12);
   t21 = sort(t21);
   t22 = sort(t22);
end   
n1 = min(length(t11),length(t22));
n2 = min(length(t12),length(t21));
n=harmmean([n1,n2]);
t1122 = feval(rule,t11(1:n1),t22(1:n1));
t1221 = feval(rule,t12(1:n2),t21(1:n2));
low = min(min(t1122),min(t1221));
high = max(max(t1122),max(t1221));
t = [low:high]';
t1122 = sort(t1122);
t1221 = sort(t1221);
F1 = EDF(t,t1122);
F2 = EDF(t,t1221);
d = max(abs(F1-F2));
z = sqrt(2)*d/pi;
plo = 1-theta4(0,sqrt(n)*z);
phi = 1-theta4(0,sqrt(n/2)*z);
