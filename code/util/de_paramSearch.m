function paramSearch(nDims)
% First, set this up for all client/server pairs!
% http://www.csua.berkeley.edu/~ranga/notes/ssh_nopass.html

  %
  if (~exist('nDims','var'))
    nDims         = 2; %2d simulation
  end;

  switch (nDims)
    case 1
      sigmas       = [1.8 12];
      nHidden      = [11:15];
      nConnections = [5:9];
      
    case 2
      sigmas       = [4 18];
      nHidden      = [11:15];
      nConnections = [170:10:220]; 
      
    otherwise
      error('Unexpected nDims: %d', nDims);
  end;
  
  %
  nRuns        = 500;
  % one server per PROCESSOR!
  servers      = {'janis', 'marley', 'dino', 'garcia'};
  params       = cell(length(nHidden)*length(nConnections), 3);

  % generate full list of parameters
  i            = 1;
  for h=nHidden
    for c=nConnections
      params(i,:) = {h , ...                     % # hidden nodes
                     c , ...                     % # connections
                     sprintf('S%d_paramSearch', nDims) }; % results output stem
      
      i = i + 1;
    end;
  end;

  % generate output filenames
  matfiles = cell(length(servers), 1);
  for i=1:length(servers)
    matfiles{i} = sprintf('%s_script.m', servers{i});
    if (exist(matfiles{i}, 'file'))
      delete(matfiles{i});
    end;
  end;

  % create scripts to execute on each server
  strSigmas = ['[' sprintf('%f ',sigmas(:)) ']'];
  i = 1;
  while (i<size(params,1))

    for j=1:min(length(servers),size(params,1)-i+1)
      fid = fopen(matfiles{j}, 'a');
      fprintf( fid, 'S%d_orig(%s, %d, %d, %d, ''%s'');\n', ...
                   nDims, strSigmas, nRuns, params{i,1}, params{i,2}, params{i,3});
      fclose(fid);
      i = i + 1;
    end;
    
  end;

  % run!
  for i=1:length(servers)
    matcmd  = sprintf('%s;exit', strrep(matfiles{i},'.m','')); % script filename
    outfile = sprintf('%s_out.txt', servers{i}); % script filename

    sshcmd  = sprintf('ssh -i $HOME/.ssh/id_dsa %s.ucsd.edu "pushd `pwd`;matbgcc ''%s'' %s " &', ...
                         servers{i}, matcmd, outfile);

    fprintf('Launching script to %s: %s\n', servers{i}, sshcmd);
    unix(sshcmd);
  end;

    
