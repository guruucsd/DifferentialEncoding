function slide=miller_demo
% This is a slideshow file for use with playshow.m and makeshow.m
% To see it run, type 'playshow miller_demo',

% Copyright 1984-2000 The MathWorks, Inc.
if nargout<1,
  playshow miller_demo
else
  %========== Slide 1 ==========

  slide(1).code={
   '[rt1 rt2 rt3 rt4]=textread(''test2.dat'');',
   'rt1=sort(rt1);rt2=sort(rt2);rt3=sort(rt3);rt4=sort(rt4);',
   't=[200:10:2500];',
   'plot(t,EDF(t,rt1),''r-'',t,EDF(t,rt3),''b-'')',
   'title(''Two EDFs'')' };
  slide(1).text={
   'Miller and Grice inequality demos.'};

  %========== Slide 2 ==========

  slide(2).code={
   '' };
  slide(2).text={
   'Suppose that we have two processing channels for some task.  Information flows over both channels and a response is made as soon as processing is complete in either channel.  How can we determine how the channels interact, if at all?',
   '',
   'Let rt1 represent the RTs when only channel one is operating.  Let rt3 and rt4 represent the RTs when only channel two is operating (in different conditions).  Let rt2 represent the RTs when both channels are operating.',
   '',
   '>> [rt1 rt2 rt3 rt4]=textread(''test2.dat'');'};

  %========== Slide 3 ==========

  slide(3).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,EDF(t,rt1),''r-'',t,EDF(t,rt2),''b-'',t,EDF(t,rt3),''r-'')',
   'set(gca,''xlim'',[0 1700])',
   'title(''EDFs for rt1,rt3 (red) and rt2 (blue)'')' };
  slide(3).text={
   'The Miller inequality (Miller, 1982; called Boole''s inequality by statisticians) notes that in the absence of "coactivation" between the two channels, cdf(rt2) <= cdf(rt1)+cdf(rt3).',
   '',
   'This inquality is only interesting until cdf(rt1)+cdf(rt3) = 1, since all cdfs are less than or equal to one.'};

  %========== Slide 4 ==========

  slide(4).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,EDF(t,rt2),''r-'',t,EDF(t,rt1)+EDF(t,rt3),''b-'')',
   'set(gca,''xlim'',[0 1200])',
   'title(''EDF for rt2 (red) and the sum of the EDFs for rt1,rt4 (blue)'')',
   '' };
  slide(4).text={
   'The three edfs we need were plotted in the last slide.  Now let''s plot the Miller inequality.',
   '',
   '>> plot(t,EDF(t,rt2),''r-'',t,EDF(t,rt1)+EDF(t,rt3),''b-'')'};

  %========== Slide 5 ==========

  slide(5).code={
   't=[300:10:700]'';',
   'plot( t,(EDF(t,rt3)+EDF(t,rt1))-EDF(t,rt2))',
   '' };
  slide(5).text={
   'As you can see, the edf for rt2 slightly exceeds the sum of the edfs for rt1 and rt3 below 400 ms and around 600 ms.  Are these violations of the Miller Inequality large enough to cast doubt on the pure race model?  We need to estimate the standard error of the difference between the two curves to find out.',
   '',
   'Let''s concentrate on the region where the Miller inequality is failing, and plot the difference between the two curves.  Whenever the difference is negative the inequality is violated.',
   '',
   '>> t=[300:10:700]'';',
   '>> plot(t,(EDF(t,rt3)+EDF(t,rt1))-EDF(t,rt2))'};

  %========== Slide 6 ==========

  slide(6).code={
   'hold on',
   '' };
  slide(6).text={
   'We''ll use bootstrapping to determine a 95% confidence interval for each point on the difference curve.',
   '',
   '>> for i=1:1000,',
   '>>   y1=bootstrap(rt1);',
   '>>   y2=bootstrap(rt2);',
   '>>   y3=bootstrap(rt3);',
   '>>  diff(:,i) = EDF(t,sort(y1))+EDF(t,sort(y3))-EDF(t,sort(y2));',
   '>> end',
   '>> ci=prctile(diff'',[2.5 97.5])'';',
   ''};

  %========== Slide 7 ==========

  slide(7).code={
   'ci=textread(''ci.dat'');',
   'plot(t,ci(:,1),''r-'',t,ci(:,2),''r-'')' };
  slide(7).text={
   'Now plot the original difference curve along with the bootstrapped confidence interval.',
   '',
   '>> hold on',
   '>> plot(t,ci(:,1),''r-'',t,ci(:,2),''r-'')',
   '',
   'Nowhere does the confidence interval not include zero.  Therefore we can conclude that the Miller inequality is not significantly violated, and that the data are consistent with a pure race model.'};

  %========== Slide 8 ==========

  slide(8).code={
   't=[200:10:2000]'';',
   'hold off',
   'plot(t,EDF(t,rt2),''r-'',t,max(EDF(t,rt1),EDF(t,rt3)),''b-'')',
   'title(''EDF for rt2 (red) and the max of the EDFs for rt1 and rt3 (blue)'')',
   '' };
  slide(8).text={
   'The Miller inequality represents an upper bound for the cdf of rt2 (both channels operating).  A lower bound is given by the Grice inequality, which states that max(cdf(rt1),cdf(rt3)) <=cdf(rt2).',
   '',
   'We will now repeat the procedure, examining the Grice inequality.  First plot the edf for rt2 and the max of the edfs for rt1 and rt3.',
   '',
   '>> t=[200:10:2000]'';',
   '>> plot(t,EDF(t,rt2),''r-'',t,max(EDF(t,rt1),EDF(t,rt3)),''b-'')'};

  %========== Slide 9 ==========

  slide(9).code={
   't=[200:10:600]'';',
   'diff_obs = EDF(t,rt2)-max(EDF(t,rt1),EDF(t,rt3));',
   'plot(t,diff_obs)',
   'hold on' };
  slide(9).text={
   'From this plot, we see that the Grice inequality seems to be violated for a cluster of points less than 500 ms.  Let''s plot the difference between the curves and zoom in on that region.',
   '',
   '>> t=[200:10:600]'';',
   '>> diff_obs = EDF(t,rt2)-max(EDF(t,rt1),EDF(t,rt3));',
   '>> plot(t,diff)'};

  %========== Slide 10 ==========

  slide(10).code={
   'cig=textread(''cig.dat'');' };
  slide(10).text={
   'Everywhere the difference is negative indicates a violation of the Grice inequality.  Is the negative difference we see between 400 ms and 500 ms significant?  Let''s compute the bootstrapped confidence interval and see.',
   '',
   '>> for i=1:1000,',
   '>>  y1=bootstrap(rt1);',
   '>>  y2=bootstrap(rt2);',
   '>>  y3=bootstrap(rt3);',
   '>>  diff(:,i) = EDF(t,sort(y2))-max(EDF(t,sort(y3)),EDF(t,sort(y1)));',
   '>> end',
   '>> ci=prctile(diff'',[2.5 97.5])'';',
   '>> hold on',
   ''};

  %========== Slide 11 ==========

  slide(11).code={
   'plot(t,cig(:,1),''r-'',t,cig(:,2),''r-'')' };
  slide(11).text={
   'Now plot the 95% confidence interval on top of the observed difference.',
   '',
   '>> plot(t,ci(:,1),''r-'',t,ci(:,2),''r-'')',
   '',
   'Nowhere does the confidence interval fail to include zero.  Therefore the three samples satisfy the conditions for a pure race.'};

  %========== Slide 12 ==========

  slide(12).code={
   'hold off',
   't=[200:10:1700]'';',
   'plot(t,max(EDF(t,rt1),EDF(t,rt3)),''r-'',t,EDF(t,rt2),''b-'',t,(EDF(t,rt1)+EDF(t,rt3)),''r-'')',
   'text(400,1.5,''End of Miller Demo'')' };
  slide(12).text={
   'This demo incorporates just a small application of the things we have been talking about: nonparametric function evaluation and bootstrapped estimates of error.  As always read up on these techniques before you use them in your own work.  I hope this demonstration has been helpful.'};
end