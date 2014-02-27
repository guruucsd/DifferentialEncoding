function [fig] = de_PlotHLTrainingCurves(ms, errorType)
%
% ms : one model per run

  %ms = ms{1};

  fig = de_NewFig('tc');

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
      m.p.err = de_calcPErr(m.p.output.train, m.data.train.T, errorType);
    end;

    guru_assert(isempty(find(m.p.err)<0), 'autoencoder error should never be negative!');

    %Plot training curves
    c_eAC = sum(m.ac.err,2);
    c_eP  = sum(m.p.err,2);

    % Autoencoder training
    subplot(2,2,1); plot(1:length(c_eAC), c_eAC); %plot(length(c_eAC)+1:m.ac.MaxIterations,c_eAC(end));
    subplot(2,2,3); plot(1:length(c_eAC), c_eAC); %plot(length(c_eAC)+1:m.ac.MaxIterations,c_eAC(end));
    xlim([0.99*round(2*m.ac.MaxIterations/3),m.ac.MaxIterations*1.01]); ylim([0.99*min(c_eAC), (mean(c_eAC)+1/length(c_eAC))*1.01]);

    % Perceptron training
    subplot(2,2,2); plot(1:length(c_eP), c_eP); %plot(length(c_eP)+1:m.p.MaxIterations,c_eP(end));
    subplot(2,2,4); plot(1:length(c_eP), c_eP); %plot(length(c_eP)+1:m.p.MaxIterations,c_eP(end));
    xlim([0.99*round(2*m.p.MaxIterations/3),m.p.MaxIterations*1.01]); ylim([0.99*min(c_eP), (mean(c_eP)+1/length(c_eAC))*1.01]);
  end;
