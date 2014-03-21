function obj = guru_rmfield(obj, fieldname)
%function obj = guru_rmfield(obj, fieldname)
%
% Removes a field, but only if it EXISTS.  Otherwise, simply returns the object

  if (isfield(obj, fieldname))
      obj = rmfield(obj, fieldname);
  end;