function huencs = de_StatsHUEncodings(mss, dset)
%
%

  huencs = cell(size(mss));
  
%  keyboard
  for i=1:length(mss)
    huencs{i} = zeros(length(mss{i}), mss{i}(1).nHidden, nHUs);
    
    for j=1:length(mss{i})
    
      fprintf( '%d ', j);
      
      model = de_LoadProps(mss{i}(j), 'ac', 'Weights');

      % Produce hidden unit activations  
      [~,~,encs]   = guru_nnExec(model.ac, dset.X, dset.X(1:end-1,:));

      % Now, clamp each hidden unit, and produce output
    end;
    
    fprintf('\t');
  end;
      