% First time to run the script
if (~exist('net','var') || ~isfield(net.sets,'continue') || ~net.sets.continue)
    lewis_elman_noac;
    net.sets.continue=1;
else
    Sdel = (net.sets.tstop-net.sets.S_LIM(2))/net.sets.dt - 1;
end;

%%%%%%
% Titrate down to a single
%net.sets.niters = 50;
%Sdur = 1;

%Sdels = randperm(Sdel+1)-1;

%for ii=1:length(Sdels)
%    Sdel = Sdels(ii);
    
%    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

%    [net,pats,data]          = r_main(net);
%    [data.an]                = r_analyze(net, pats, data);
%end;

%%%%%%
% Titrate down to a single
net.sets.niters = 250;

while Sdel<(tsteps-5)
    Sdel = Sdel + 1;
    
    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

    [net,pats,data]          = r_main(net);
    [data.an]                = r_analyze(net, pats, data);
end;




%%%%%%
% Titrate up to a single
%while (Sdur < tsteps+3)
%    Sdur = Sdur + 1;
%    
%    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error
%
%    [net,pats,data]          = r_main(net);
%    [data.an]                = r_analyze(net, pats, data);
%end;

%
