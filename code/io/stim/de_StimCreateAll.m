	function de_StimCreateAll(set)
%
% Inputs:
%   set: string specifying stimulus set to create
%        all: all known datasets
%        hl:  all 1D and 2D hierarchical stimuli
%        lsb: all 2D left-side-bias stimuli
%        sf:  all spatial frequency stimuli

  if (~exist('set','var')), set = 'all'; end;
  
  % hierarchical letters
  if (strcmp(set, 'hl') || strcmp(set,'all'))
    for dim = [1 2]
      for stimSet = {'de', 'dff', 'sergent'}
        for taskType = {'dff', 'gary', 'pc1', 'sergent','gd','ld','sergent2','mtl'}
          for opt = {{}, {'reza-ized'}, {'swapped'}, {'D2#T1'}, {'D2#T2'}, {'D1#T1'}, {'D1#T2'} }
            fprintf('Hierarchical letters: de_StimCreateHL(%d, ''%s'', ''%s'', {''%s''});\n', ...
                    dim, stimSet{1}, taskType{1}, [opt{1}{:}]);
            de_StimCreateHL(dim, stimSet{1}, taskType{1}, opt{1});
          end;
        end;
      end;
    end;
  end;
  
  % left side bias
  if (strcmp(set, 'lsb') || strcmp(set, 'all'))
    for dim = [2]
      for stimSet = {'orig', 'left', 'right'} %, 'mixed'
        for sz= {'small', 'med', 'large'}
          for taskType = {'recog', 'emot'}
%            for opt = {}
%            keyboard
              %ss = sprintf('%s_%s', stimSet{1}, sz{1});
              opt = {sz};
              fprintf('Left side bias: de_StimCreateLSB(%d, ''%s'', ''%s'', {''%s''});\n', ...
                      dim, stimSet{1}, taskType{1}, [opt{1}{:}]);
              de_StimCreateLSB(dim, stimSet{1}, taskType{1}, opt{1});
%            end;
          end;
        end;
      end;
    end;
  end;
  
  % frequencies
  if (strcmp(set, 'sf') || strcmp(set, 'all'))
    for dim = [2]
      for stimSet = {'low', 'mid', 'high', 'mixed'} %, 'mixed'
        for taskType = {'recog'}
          for opt = {{}}
            fprintf('Left side bias: de_StimCreateSF(%d, ''%s'', ''%s'', {''%s''});\n', ...
                    dim, stimSet{1}, taskType{1}, [opt{1}{:}]);
            de_StimCreateSF(dim, stimSet{1}, taskType{1}, opt{1});
          end;
        end;
      end;
    end;
  end;
  
  % remove any file

  % close debug plots
  close all;
