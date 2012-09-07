function [fig] = de_PlotReza(mSets, LS, errAC, sigmas)
%function [fig] = de_PlotReza(models, LS)
%
% Replicate reza's figure  from the original scripts
%
% Input:
% model         : see de_model for details
% LS            :
% errAutoEnc    :
% rmode         : (optional) rejections mode
% dbg           : (optional) 
%
% Output:
% fig             : array of handles to plots

  %fig = guru_newFig('reza', 'images', 6);
  fig.handle = figure;
  fig.name = 'reza';
  
  % Make assigments so that reza's code works
  rLpSm(:,1) = LS{1}(:,mSets.data.LpSm); rLpSm(:,2) = LS{2}(:,mSets.data.LpSm); 
  rSpLm(:,1) = LS{1}(:,mSets.data.LmSp); rSpLm(:,2) = LS{2}(:,mSets.data.LmSp); 
  rLpSp(:,1) = LS{1}(:,mSets.data.LpSp); rLpSp(:,2) = LS{2}(:,mSets.data.LpSp); 
  rLmSm(:,1) = LS{1}(:,mSets.data.LmSm); rLmSm(:,2) = LS{2}(:,mSets.data.LmSm); 
  
  BAR(1,:)=sum(rLpSm);BAR(2,:)=sum(rSpLm);
  BAR(3,:)=sum(rLpSp);BAR(4,:)=sum(rLmSm);
  BAR=BAR/size(rLpSm,1);
  
  learningError = zeros(size(errAC));
  for i=1:length(errAC)
    learningError(i) = mean(errAC{i},1); %
  end;
  
  % Copy/paste reza's code here!
  subplot(2,3,1)
  plot(rLpSm(:,1),'g'); hold on
  plot(rLpSm(:,2),'r');
  legend(sprintf('local net (s=%4.1f)',sigmas(1)), ...
         sprintf('global net (s=%4.1f)',sigmas(2)));
  title('L+S- (large letter is target only)');

  subplot(2,3,2)
  plot(rSpLm(:,1),'g'); hold on
  plot(rSpLm(:,2),'r');
  legend(sprintf('local net (s=%4.1f)',sigmas(1)), ...
         sprintf('global net (s=%4.1f)',sigmas(2)));
  title('L-S+ (small letter is target only)');

  subplot(2,3,3)
  plot(rLpSp(:,1),'g'); hold on
  plot(rLpSp(:,2),'r');
  legend(sprintf('local net (s=%4.1f)',sigmas(1)), ...
         sprintf('global net (s=%4.1f)',sigmas(2)));
  title('L+S+ (both letters are target)');


  subplot(2,3,4)
  plot(rLmSm(:,1),'g'); hold on
  plot(rLmSm(:,2),'r');
  legend(sprintf('local net (s=%4.1f)',sigmas(1)), ...
         sprintf('global net (s=%4.1f)',sigmas(2)));
  title('L-S- (No target letter)');



  subplot(2,3,5)
  bar(BAR);
  legend(sprintf('local net (s=%4.1f)',sigmas(1)), ...
         sprintf('global net (s=%4.1f)',sigmas(2)), ...
         'Location','NorthOutside');
  title('1: L+S-, 2: L-S+, 3=L+S+, 4: L-S-');

  subplot(2,3,6)
  bar(learningError);
  title('Error of the Auto encoders in learning Images; 1=local, 2=global');
