function [groups,group_sizes] = get_groups(pix, position, ngroups)
%function [groups,group_sizes] = get_groups(pix, position, ngroups)
%
%
%

if ~exist('position','var'), position='center'; end;
  
    groups = [];
    group_sizes = [];
    
    group_startidx = nan;
    
    for ii=1:length(pix)
      if ~pix(ii) 
        if ~isnan(group_startidx)
          [groups(end+1), group_sizes(end+1)] = end_group(ii, group_startidx,position);
          group_startidx = nan;
        end;
    
      % pixel is on, and no "group" is started; start one!
      elseif isnan(group_startidx)
        group_startidx = ii;
    
      end;
    end;
    
    % complete last group
    if ~isnan(group_startidx)
        [groups(end+1), group_sizes(end+1)] = end_group(ii, group_startidx,position);
    end;
    
    if exist('ngroups','var') && length(groups) ~= ngroups
        warning(sprintf('found %d groups, != expected (%d)', length(groups), ngroups));
    end;
        
function [group,group_size] = end_group(ii, group_startidx,position)
    
  group_size = (ii-1) - group_startidx + 1;
  switch position
    case 'center', group = (group_startidx+(ii-1))/2;
    case 'left',   group = group_startidx;
    case 'right',  group = (ii-1);
  end;

