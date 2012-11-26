function [str] = de_modelSummary(model, style)
%
% A brief summary of the networks being run.
%   Also is the base text for input into a hash function
%   for the base directory name of this simulation set
%
% model - model settings to summarize
% style - 'clear': clear text
%       - 'pre-hash': clear text, but remove any information not relevant to the hash
%       - 'hash': hashed version of the pre-hash text
%

  if (~exist('style','var')), style = 'clear'; end;


  deSummary = sprintf('DE: %dD network; distn=%s, m=%s, o=%s, nConns=%d, nHidden=%dx%d, trials=%d, dataFile=%s\n', ...
                      length(model.nInput), guru_cell2str(model.distn),  ...
                      ['[ ' sprintf('%.1f ',model.mu) ']'], ['[ ' sprintf('%4.1f ',model.sigma) ']'], ...
                      model.nConns, model.nHidden/model.hpl, model.hpl, model.runs, model.dataFile);

  acSummary = sprintf('AC: AvgErr: %5.4f, MaxIterations: %4d, Acc: %6.5f, EtaInit: %6.5f, Dec: %6.5f, XferFn: %s\n',...
                  model.ac.AvgError, model.ac.MaxIterations, model.ac.Acc, model.ac.EtaInit, ...
                  model.ac.Dec, ['[ ' sprintf('%d ', model.ac.XferFn) ']'] ...
                );

  if (isfield(model,'p'))
      pSummary = sprintf('P:  AvgErr: %5.4f, MaxIterations: %4d, Acc: %6.5f, EtaInit: %6.5f, Dec: %6.5f, XferFn: [ %d]\n',...
                      model.p.AvgError, model.p.MaxIterations, model.p.Acc, model.p.EtaInit, ...
                      model.p.Dec, guru_csprintf('%d ', num2cell(model.p.XferFn)) ...
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
  end;