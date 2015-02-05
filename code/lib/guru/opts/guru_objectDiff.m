function [dff, diff1, diff2] = guru_objectDiff(o1, o2)
%
%

  fieldnames1 = fieldnames(o1);
  fieldnames2 = fieldnames(o2);

  diff1 = setdiff(fieldnames1, fieldnames2);
  diff2 = setdiff(fieldnames2, fieldnames1);

  for i=1:length(fieldnames1)

    % No need
    if (ismember(fieldnames1{i}, diff1))
      continue;

    elseif (~isstruct(getfield(o1, fieldnames1{i})))
      continue;

    else
      [d1, d2] = guru_objectDiff( getfield(o1, fieldnames1{i}), ...
                                  getfield(o2, fieldnames1{i}) );
      for j=1:length(d1)
        diff1{end+1} = [fieldnames1{i} '.' d1{:}];
      end;
      for j=1:length(d2)
        diff2{end+1} = [fieldnames2{i} '.' d2{:}];
      end;
    end;
  end;

  dff = {diff1{:} diff2{:}};
