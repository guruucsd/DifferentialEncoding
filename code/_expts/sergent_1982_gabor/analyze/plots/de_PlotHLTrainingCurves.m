function [fig] = de_PlotHLTrainingCurves(ms, errorType)
%
% ms : one model per run
  
  ms = ms{1};
  
  fig.name   = 'tc';
  fig.handle = figure; 
  
  % Training error
  subplot(2,2,1); hold on; title('Autoencoder training error');
  subplot(2,2,3); hold on; title('Autoencoder training error (zoomed)');
  subplot(2,2,2); hold on; title('Perceptron training error');
  subplot(2,2,4); hold on; title('Perceptron training error (zoomeed)');

  for i=1:length(ms)
    m = ms(i);

    if (~isfield(m.ac, 'err'))
      m.ac.err = guru_loadVars(de_GetOutFile(m, 'ac.err'), 'err');, 
    end;
    
    %
    if (~isfield(m.p,'err'))
      if (~isfield(m.p, 'output'))
        m.p.output = guru_loadVars(de_GetOutFile(m, 'p.output'), 'output');, 
      end;
      m.p.err = de_calcPErr(m.p.output, m.data.train.T, errorType);
    end;

    guru_assert(isempty(find(m.p.err)<0), 'classifier error should never be negative!');
    
    %Plot training curves
    c_eAC = sum(m.ac.err,2);
    c_eP  = sum(m.p.err,2);
    
    % Autoencoder training
    subplot(2,2,1); plot(1:length(c_eAC), c_eAC); %plot(length(c_eAC)+1:m.ac.MaxIterations,c_eAC(end));
    subplot(2,2,3); plot(1:length(c_eAC), c_eAC); %plot(length(c_eAC)+1:m.ac.MaxIterations,c_eAC(end));
    xlim([round(2*m.ac.MaxIterations/3),m.ac.MaxIterations]); ylim([min(c_eAC), mean(c_eAC)+1/length(c_eAC)]);
  
    % Perceptron training
    subplot(2,2,2); plot(1:length(c_eP), c_eP); %plot(length(c_eP)+1:m.p.MaxIterations,c_eP(end));
    subplot(2,2,4); plot(1:length(c_eP), c_eP); %plot(length(c_eP)+1:m.p.MaxIterations,c_eP(end));
    xlim([round(2*m.p.MaxIterations/3),m.p.MaxIterations]); ylim([min(c_eP), mean(c_eP)+1/length(c_eAC)]);
  end;
