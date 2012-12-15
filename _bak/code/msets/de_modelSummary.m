function [str] = de_modelSummary(model, style)
%
  if (~exist('style','var'))
    style = 'clear';
  end;

  deSummary = sprintf('DE: %dD network; distn=%s, m=%s, o=%s, nConns=%d, nHidden=%d, trials=%d, dataFile=%s\n', ...
                      length(model.nInput), ['{' sprintf('%s ',model.distn{:}) '}'],  ...
                      ['[' sprintf('%4.1f ',model.mu) ']'], ['[' sprintf('%4.1f ',model.sigma) ']'], ...
                      model.nConns, model.nHidden, model.runs, model.dataFile);

  acSummary = sprintf('AC: AvgErr: %5.4f, MaxIterations: %4d, Acc: %6.5f, EtaInit: %6.5f, Dec: %6.5f, XferFn: %d\n',...
                  model.ac.AvgError, model.ac.MaxIterations, model.ac.Acc, model.ac.EtaInit, ...
                  model.ac.Dec, model.ac.XferFn ...
                );

  if (isfield(model,'p'))
      pSummary = sprintf('P:  AvgErr: %5.4f, MaxIterations: %4d, Acc: %6.5f, EtaInit: %6.5f, Dec: %6.5f, XferFn: %d\n',...
                      model.p.AvgError, model.p.MaxIterations, model.p.Acc, model.p.EtaInit, ...
                      model.p.Dec, model.p.XferFn ...
                    );
  else
      pSummary = '';
  end;
  
  str = [deSummary acSummary pSummary];
  str = regexprep(str, '\n', sprintf('\n\t')); %indent
  
  switch (style)
    case 'pre-hash'
      str = regexprep(str, ', trials=[0-9]+', '');
    case 'hash'
      str = regexprep(str, ', trials=[0-9]+', '');
      str = sprintf('%d', sum(str.*[1:10:10*length(str)]));
    otherwise %put here for legacy purposes, to avoid killing our current cache
      str = regexprep(str, '\n\t$', '\n');
  end;