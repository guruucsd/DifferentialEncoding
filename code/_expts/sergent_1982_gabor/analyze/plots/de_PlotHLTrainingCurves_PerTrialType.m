function [fig] = de_PlotHLTrainingCurves_PerTrialType(mss, errorType)
%[fig] = de_PlotTrainingCurves_PerTrialType(mss)
%
% Used to plot average training curves per trial type
%
% Inputs:
% mss : 
%
% Outputs:
% fig : figure object

  nSigmas = length(mss);
  guru_assert(nSigmas == 2);
  
  
  %----------------
  % Loop over sigmas and trials
  %   (to collect enough samples)
  %----------------
  
  for ss=1:nSigmas
    ms      = mss{ss};
    rons    = size(ms,1);
    nTrials = size(ms(1).data.train.T,2);
    
    avg_eAC(ss,:,:) = zeros(ms(1).ac.MaxIterations,nTrials);
    avg_eP(ss,:,:)  = zeros(ms(1).p.MaxIterations,nTrials);

    for zz=1:rons
      m = ms(zz);
      
      % Pad
      if (~isfield(m.ac, 'err'))
        m.ac.err = guru_loadVars(de_GetOutFile(m, 'ac.err'), 'err');, 
      end;
      c_eAC = m.ac.err;
      if (size(c_eAC,1)<m.ac.MaxIterations)
        c_eAC(end+1:m.ac.MaxIterations,:) = repmat(c_eAC(end,:), ...
                                            [m.ac.MaxIterations-size(c_eAC,1) 1]);
      end;
      
      % pad
      if (~isfield(m.p,'err'))
        if (~isfield(m.p, 'output'))
          m.p.output = guru_loadVars(de_GetOutFile(m, 'p.output'), 'output');, 
        end;
        m.p.err = de_calcPErr(m.p.output, m.data.train.T, errorType);
      end;
      
      c_eP = m.p.err;
      if (size(c_eP,1)<m.p.MaxIterations)
        c_eP(end+1:m.p.MaxIterations,:) = repmat(c_eP(end,:), ...
                                            [m.p.MaxIterations-size(c_eP,1) 1]);
      end;

      if (~isempty(find(c_eAC<0))), keyboard; end;
      if (~isempty(find(c_eP<0))), keyboard; end;
      
      avg_eAC(ss,:,:) = squeeze(avg_eAC(ss,:,:)) + c_eAC;
      avg_eP(ss,:,:)  = squeeze(avg_eP(ss,:,:))  + c_eP;
    end; %rons

    avg_eAC(ss,:,:) = avg_eAC(ss,:,:)/rons;
    avg_eP(ss,:,:)  = avg_eP(ss,:,:) /rons;

    if (nSigmas == 1)
      fig.name = 'tcptt';
      [fig.handle] = de_PlotTrainingCurves_PerTrialType_DOIT( ...
                         m, ...
                         squeeze(avg_eAC(ss,:,:)), ...
                         squeeze(avg_eP(ss,:,:)) ...
                     );
    end;
  end;  %ss

  fig = de_PlotTrainingCurves_PerTrialType_DOIT( ...
                     m, ...
                     squeeze(avg_eAC(2,:,:) - avg_eAC(1,:,:)), ...
                     squeeze(avg_eP(2,:,:) - avg_eP(1,:,:)) ...
                 );

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function fig = de_PlotTrainingCurves_PerTrialType_DOIT(m, avg_eAC, avg_eP)
  % do a final plot for the ss comparisons
    nTrials = size(m.data.train.X,2);  

    fig.name = 'tcptt-diff';
    fig.handle = figure;

    % autoencoder
    subplot(2,2,1); imagesc(avg_eAC);
    hold on; title( sprintf('Autoencoder training error (%d trial types)', nTrials) );
    set(gca,'xtick',[2:4:14],'xticklabel',m.data.TLBL([m.data.LpSm m.data.LmSp m.data.LpSp m.data.LmSm]));
    ylabel('training step #');
    colorbar;
    subplot(2,2,3); imagesc(0.25*[sum(avg_eAC(:,m.data.train.TIDX{m.data.LpSm}),2) ...
                                  sum(avg_eAC(:,m.data.train.TIDX{m.data.LmSp}),2) ...
                                  sum(avg_eAC(:,m.data.train.TIDX{m.data.LpSp}),2) ...
                                  sum(avg_eAC(:,m.data.train.TIDX{m.data.LmSm}),2)]);
    hold on; title('Autoencoder training error (4 trial types)');
    set(gca,'xtick',[1:4],'xticklabel',m.data.TLBL([m.data.LpSm m.data.LmSp m.data.LpSp m.data.LmSm]));
    ylabel('training step #');
    colorbar;

    % perceptron
    subplot(2,2,2); imagesc(avg_eP);
    hold on; title( sprintf('Perceptron training error (%d trial types', nTrials) );
    set(gca,'xtick',[2:4:14],'xticklabel',m.data.TLBL([m.data.LpSm m.data.LmSp m.data.LpSp m.data.LmSm]));
    ylabel('training step #');
    colorbar;

    subplot(2,2,4); imagesc(0.25*[sum(avg_eP(:,m.data.train.TIDX{m.data.LpSm}),2) ...
                                  sum(avg_eP(:,m.data.train.TIDX{m.data.LmSp}),2) ...
                                  sum(avg_eP(:,m.data.train.TIDX{m.data.LpSp}),2) ...
                                  sum(avg_eP(:,m.data.train.TIDX{m.data.LmSm}),2)]);
    hold on; title('Perceptron training error (4 trial types)');
    set(gca,'xtick',[1:4],'xticklabel',m.data.TLBL([m.data.LpSm m.data.LmSp m.data.LpSp m.data.LmSm]));
    ylabel('training step #');
    colorbar;
