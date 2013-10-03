  function de_SaveMat(fn, mSets, models, stats)
  %
  %  
    models = de_CompressModels(models);
    save( fn, 'mSets', 'models', 'stats' );
