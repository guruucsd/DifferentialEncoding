function looper(net);

min_rseed = net.sets.rseed;
sets= net.sets;

for s=(min_rseed-1+[1:net.sets.n_nets])

   % Make sure not to reuse networks!
   clear 'net';
   net.sets = sets;
   net.sets.rseed = s;

    %
    matfile = fullfile(net.sets.dirname, getfield(getfield(r_massage_params(net), 'sets'),'matfile'));
    %keyboard;
    if exist(matfile, 'file')
        fprintf('Skipping %s\n', matfile);
        continue;
    end; % don't re-run

    %
    if ~exist(net.sets.dirname,'dir'), mkdir(net.sets.dirname); end;

    try
     [net,pats,data]          = r_main(net);
     [data.an]                = r_analyze(net, pats, data);
     %unix(['mv ' net.sets.matfile ' ./' net.sets.dirname]);
   catch
     fprintf(lasterr);
   end;
end;


