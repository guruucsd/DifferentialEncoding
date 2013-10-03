function [rs] = de_GetRejSets(rejSets, propName)
%

  rejsToApply = strcmp(propName, rejSets.props);
  
  rs       = rmfield(rejSets, 'props');
  rs.type  = rs.type (rejsToApply);
  rs.width = rs.width(rejsToApply);
  