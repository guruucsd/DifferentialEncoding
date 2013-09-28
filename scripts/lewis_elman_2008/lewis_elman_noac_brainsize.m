% First time to run the script
keyboard
if (~exist('net','var') || ~isfield(net.sets,'continue') || ~net.sets.continue)
    net.sets.run = false
    net.sets.continue=true;
    lewis_elman_noac;
else
    Sdel = (net.sets.tstop-net.sets.S_LIM(2))/net.sets.dt - 1;
end;


%%%%%%
% Titrate down to a single
net.sets.niters = 250;

while Sdel<(tsteps-5)
    Sdel = Sdel + 1;
    
    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

    [net,pats,data]          = r_main(net);
    [data.an]                = r_analyze(net, pats, data);
end;

