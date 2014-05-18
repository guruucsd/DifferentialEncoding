function F=EDF(t,y)
% EDF The empirical distribution function
F=ones(length(t),1);
for i=1:length(t)
    F(i) = sum(y<=t(i))/length(y);
end
