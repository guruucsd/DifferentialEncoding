function guru_mkdir (dirpath)

% MATLAB mkdir in OCTAVE
% Adapted from https://savannah.gnu.org/bugs/?func=detailitem&item_id=30650 comment #11

if ~mkdir(dirpath) && ~exist(fileparts(dirpath), 'dir')
  system(sprintf('mkdir -p "%s"', dirpath));
end;