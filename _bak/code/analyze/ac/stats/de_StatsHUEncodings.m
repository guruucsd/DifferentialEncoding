function huencs = de_StatsHUEncodings(mss, dset)

  huencs = cell(size(mss));
  nImages = size(dset.X, 2);
  
%  keyboard
  for i=1:length(mss)
    huencs{i} = zeros(length(mss{i}), mss{i}(1).nHidden, nImages);
    
    for j=1:length(mss{i})
    
      fprintf( '%d ', j);
      
      model = de_LoadProps(mss{i}(j), 'ac', 'Weights');

      % Produce hidden unit activations  
      [imgs,err,huencs{i}(j,:, :)]   = guru_nnExec(model.ac, dset.X, dset.X);
      clear('imgs','err');

      % Now, clamp each hidden unit, and produce output
    end;
    
    fprintf('\t');
  end;
      