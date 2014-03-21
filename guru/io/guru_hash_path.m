function hp = guru_hash_path(p)
  hv = round( sum(p.*[1:5:5*length(p)]) );
  guru_assert(hv<1E10, 'hash cannot be too big')
  hp = sprintf('%d', hv);