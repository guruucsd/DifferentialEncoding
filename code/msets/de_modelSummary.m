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


  deSummary = sprintf('DE: %dD network; distn=%s, m=%s, o=%s, nConns=%s, nHidden=%sx%s, trials=%s, dataFile=%s\n', ...
                      length(model.nInput), guru_cell2str(model.distn),  ...
                      mat2str(model.mu), mat2str(model.sigma),  ...
                      mat2str(model.nConns), mat2str(model.nHidden./model.hpl), mat2str(model.hpl), mat2str(model.runs), model.dataFile);

  acSummary = sprintf('AC: AvgErr: %5.4f, MaxIterations: %4d, Acc: %6.5f, EtaInit: %6.5f, Dec: %6.5f, XferFn: %s\n',...
                  model.ac.AvgError, model.ac.MaxIterations, model.ac.Acc, model.ac.EtaInit, ...
                  model.ac.Dec, ['[ ' sprintf('%d ', model.ac.XferFn) ']'] ...
                );
  acSummary = [acSummary sprintf('\tzscore=%.2f, lambda=%.2f, ts=%d, dropout=%.1f, noise=%.2f\n', ...
                    model.ac.zscore, model.ac.lambda, model.ac.ts, model.ac.dropout, model.ac.noise_input ...
               )];

  if (isfield(model,'p'))
      pSummary = sprintf('P:  AvgErr: %5.4f, MaxIterations: %4d, Acc: %6.5f, EtaInit: %6.5f, Dec: %6.5f, XferFn: %s\n',...
                      model.p.AvgError, model.p.MaxIterations, model.p.Acc, model.p.EtaInit, ...
                      model.p.Dec, ['[' sprintf('%d ', model.p.XferFn) ']']  ...
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
