function slide=density_demo
% This is a slideshow file for use with playshow.m and makeshow.m
% To see it run, type 'playshow density_demo', 

% Copyright 1984-2000 The MathWorks, Inc.
if nargout<1,
  playshow density_demo
else
  %========== Slide 1 ==========

  slide(1).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'sim=gamrnd(3,200,200,1);',
   'x=[50:100:2500];',
   'edges=[0:100:2550];',
   '[n bin]=histc(sim,edges);',
   'nn=n/(100*200);',
   'hold off',
   'bar(edges,nn,''c'')',
   'hold on',
   'plot(x,gampdf(x,3,200),''r-'')',
   'hold off',
   '' };
  slide(1).text={
   'This demo illustrates how to compute a nonparametric estimate of the density, distribution and hazard function for a set of data.',
   '',
   ''};

  %========== Slide 2 ==========

  slide(2).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'rt=textread(''test.dat'');',
   'hist(rt,20)',
   'title(''Histogram'')' };
  slide(2).text={
   'First read in the data in the file ''test.dat'' using the ''textread'' command.  Alternatively, you could construct your own data by simulating a model.  Examine the data with a simple histogram.',
   '',
   '>> rt=textread(''test.dat'');',
   '>> hist(rt,20)'};

  %========== Slide 3 ==========

  slide(3).code={
   'subplot(''Position'',[.1 .75 .3 .2])',
   'hist(rt,20)',
   'title(''Histogram'')',
   'subplot(''Position'',[.45 .75 .3 .2])',
   'plot([0:25:2000]'',EDF([0:25:2000],sort(rt)))',
   'title(''Cumulative Distribution'')',
   '',
   '' };
  slide(3).text={
   'There are three ways we can characterize the data in terms of its "distribution."   The histogram that we just plotted is a rough estimate of the density function (pdf), the first and most common way.  Second, we might examine the empirical distribution function, which is an estimate of the cumulative distribution (cdf), the second way.'};

  %========== Slide 4 ==========

  slide(4).code={
   'subplot(''Position'',[.1 .75 .3 .2])',
   'hist(rt,20)',
   'title(''Histogram'')',
   'subplot(''Position'',[.45 .75 .3 .2])',
   'plot([0:25:2000]'',EDF([0:25:2000],sort(rt)))',
   'title(''Cumulative Distribution'')',
   'subplot(''Position'',[.25 .45 .3 .2])',
   'plot( [0:25:2000]'',hazard([0:25:2000]'',sort(rt)))',
   'set(gca,''ylim'',[0 .02])',
   'title(''Hazard'')' };
  slide(4).text={
   'The third way of characterizing a variable is by the hazard function, which is the density function divided by one minus the cumulative distribution function.  The hazard function is not what you first think of when you imagine a distribution, but it can be very useful.',
   '',
   'In the plot above, the hazard function looks very messy.  This behavior is typical of hazard estimates, because as the cdf approaches one, the denominator of the hazard becomes very small.  Real hazard functions aren''t messy.'};

  %========== Slide 5 ==========

  slide(5).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot([-4:.1:4],normpdf([-4:.1:4],0,1),''k-'' )',
   'hold on',
   'plot([-4:.1:4],normcdf([ -4:.1:4],0,1),''r-'' )',
   'title(''Normal pdf (black) and cdf (red)'')',
   'hold off',
   '' };
  slide(5).text={
   'Let''s begin with the cdf.  This function gives the probability of observing a value (an RT) less than some value t.  For continuous variables, we usually find it by integrating the density function (but not always).'};

  %========== Slide 6 ==========

  slide(6).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'cdfplot(rt)' };
  slide(6).text={
   'The cdf is estimated easily using the cumulative relative frequency.  The estimate of the cdf is called the empirical distribution or edf.  The edf has a number of nice properties, including unbiasedness, asymptotic normality, and it is a maximum likelihood estimate of the cdf.',
   '',
   'You can plot the edf using the ''cdfplot'' command.',
   '',
   '>> cdfplot(rt)'};

  %========== Slide 7 ==========

  slide(7).code={
   't=[100:5:1800]'';',
   'F=EDF(t,sort(rt));',
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,F,''b-'')',
   'title(''EDF'')',
   '' };
  slide(7).text={
   'I have found it useful to write a matlab function that computes the edf for a set of points that I specify.  (I can then use these points to do other statistics.)  After choosing the points of interest, the function EDF is called and the results plotted.',
   '',
   '>> t=[100:5:1800]'';',
   '>> F=EDF(t,sort(rt));',
   '>> plot(t,F,''b-'')'};

  %========== Slide 8 ==========

  slide(8).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'x=gamrnd(3,200,200,1)'';',
   'F = EDF(t,sort(x));',
   'plot(t,F, ''b-'',t,gamcdf(t,3,200),''r-'')',
   'title(''Gamma CDF (red) and EDF (blue)'')' };
  slide(8).text={
   'The edf is usually a very accurate estimate.  To demonstrate this, generate a random sample (N=200) from a gamma distribution and then plot the edf on top of the (true) cdf.',
   '',
   '>> x = gamrnd(3,200,200,1)'';',
   '>> F=EDF(t,sort(x));',
   '>> plot(x,F,''b-'',x,gamcdf(x,3,200),''r-'')'};

  %========== Slide 9 ==========

  slide(9).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'hist(rt,20)',
   'title(''Histogram'')' };
  slide(9).text={
   'Now let''s focus on the pdf.  Unlike the cdf, there are no "good" nonparametric estimates of the pdf, where "good" means unbiased, asymptotically normal, etc.  This means we have to be more careful.  In particular, we need to worry about smoothness.  Too much smoothing and all the interesting features of our data disappear,  Too little and the plots will be jagged and irregular.',
   '',
   'We''ll look at two estimators, the histogram and the Gaussian kernel.'};

  %========== Slide 10 ==========

  slide(10).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'hist(rt,20)',
   'title(''Histogram'')' };
  slide(10).text={
   'It is important to distinguish between a data histogram and a histogram estimate of a pdf.  Remember that a pdf (and, hopefully, its estimate) will integrate to 1.  If we sum the areas of the bars of a histogram, we will obtain some huge number.  To obtain a histogram estimate, we need to divide the height of the bars by the total number of observations times the width of the bar.  The width of each bar is our "smoothing parameter."'};

  %========== Slide 11 ==========

  slide(11).code={
   'edges=[0:100:2550];',
   ' [n bin]=histc(rt,edges) ;',
   ' subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'bar(edges,n,''b'')',
   'set(gca,''ylim'',[0 80],''xlim'',[0 2000])',
   'title(''Histogram'')' };
  slide(11).text={
   'We''ll have to specify the bins explicitly for our histogram estimate.  Let the bin width be 100 ms, and start the first bin at  0.  Use the function ''histc'' to count up the observations in each bin and ''bar'' to plot the results.  (Notice any changes that result in the histogram from changing the bins.)',
   '',
   '>> edges=[0:100:2550];',
   '>> n=histc(rt,edges);',
   '>> bar(edges,n)'};

  %========== Slide 12 ==========

  slide(12).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'f=n/(100*200);',
   'bar(edges,f,''b'')',
   'set(gca,''ylim'',[0 .004],''xlim'',[0 2000])',
   'hold on',
   'plot(t,exgauss(t,[447.3645 107.5749 195.6705]),''r'')',
   'title(''Histogram estimate with bin width 100 ms'')',
   'hold off',
   '' };
  slide(12).text={
   'To obtain the histogram estimate, we note that the bin width is 100 ms and that there are 200 observations.  We divide the height of each bar by 100*200 to compute the estimate.  (The red line on the plot is a best-fitting exGaussian pdf.  Your plot won''t show this.)',
   '',
   '>> f=n/(100*200);',
   '>> bar(edges,f,''b'')'};

  %========== Slide 13 ==========

  slide(13).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'edges=[0:200:2200]'';',
   'f=histc(rt,edges)/(200*200);',
   'bar(edges,f,''b'')',
   'set(gca,''ylim'',[0 .004],''xlim'',[0 2000])',
   'title(''Histogram estimate with bin width 200 ms'')',
   '' };
  slide(13).text={
   'The bin width is very important.  The shape of the estimate can vary drastically with different bin widths.  Play around with the edges of the bins to see what effect this has on your estimate.',
   '',
   '>> edges=[0:200:2200]'';',
   '>> f=histc(rt,edges)/(200*200);',
   '>> bar(edges,f,''b'')'};

  %========== Slide 14 ==========

  slide(14).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'x=gamrnd(3,200,200,1)'';',
   'edges=[0:100:2100]'';',
   'f=histc(x,edges)/(100*200);',
   'bar(edges,f,''b'')',
   'hold on',
   'plot(t,gampdf(t,3,200) ,''-r'')',
   'set(gca,''ylim'',[0 .002],''xlim'',[0 2000])',
   'title(''Histogram estimate (blue) and gamma pdf (red)'')',
   'hold off' };
  slide(14).text={
   'The accuracy of the histogram estimator depends in a complicated way on the sample size and the bin width.  To explore accuracy,  use the simulated data you generated earlier.',
   '',
   '>> edges=[0:100:2100]'';',
   '>> f=histc(x,edges)/(200*100);',
   '>> bar(edges,f,''b'')',
   '>> hold on',
   '>> plot(t,gampdf(t,3,200)'};

  %========== Slide 15 ==========

  slide(15).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'h = .9*min(std(rt),iqr(rt)/1.349)/length(rt)^.2;',
   'plot(rt,zeros(size(rt)),''r*'')',
   'hold on',
   'stem(rt,normpdf(rt,450,h),''b.'')',
   'set(gca,''ylim'',[0 .009],''xlim'',[250 650])',
   ' xlabel Observations',
   'title(''Kernel values at 450 ms'')',
   'hold off',
   '' };
  slide(15).text={
   'Now we turn to the Gaussian kernel estimator.  A "kernel" is defined as "something that is integrated," or, in our situation, summed.  For the kernel estimators, the kernel "filters" the data in a way similar to a moving average.  Observations that are close to the center of the kernel contribute a lot to the average: those that are far away contribute nothing.  The center of the kernel is the point at which the density is to be estimated.  The width of the kernel determines the smoothness of the estimate.',
   '',
   'In the plot above, the observations (rt) are shown as red points along the x-axis.  The height of the kernel is shown in blue.'};

  %========== Slide 16 ==========

  slide(16).code={
   'f = Gausskernel(t,sort(rt));',
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,f,''r-'')',
   'title(''Gaussian Kernel Estimate'')',
   '' };
  slide(16).text={
   'To compute the Gaussian kernel estimate, we average the values of the kernel centered at each point where we desire an estimate.  I have written a function ''Gausskernel'' that estimates the pdf at each of a set of points t.',
   '',
   '>> f = Gausskernel(t,sort(rt));',
   '>> plot(t,f,''b-'')'};

  %========== Slide 17 ==========

  slide(17).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'h=histc(rt,edges)/(200*100);',
   'bar(edges,h,''b'')',
   'hold on',
   'plot(t,f,''r-'')',
   'title(''Gaussian Kernel Estimate'')',
   'set(gca,''ylim'',[0 .004],''xlim'',[0 2000])',
   'hold off' };
  slide(17).text={
   'It is almost impossible to resist comparing the Gaussian kernel estimate with the histogram estimate, even though the comparison is not very informative.  So go ahead, do it.',
   '',
   '>> hold on',
   '>> h=histc(rt,edges)/(200*100);',
   '>> bar(edges,h,''b'')',
   '>> hold off',
   ''};

  %========== Slide 18 ==========

  slide(18).code={
   'rt=sort(rt);',
   'pd=[[''k-''];[''b-''];[''r-'']];',
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'for a=.3:1.2:3,',
   '   i=round(a*2/2.4 + .75);',
   '   f(:,i)=Gausskernel(t,rt,a);',
   '  plot(t,f(:,i),pd(i,:))',
   '  hold on',
   'end',
   'hold off' };
  slide(18).text={
   'What about the smoothing parameter?  The Gausskernel function computes the degree of smoothing according to Silverman''s formula (Silverman, 1986).  We can modulate the smoothing by passing a third argument to Gausskernel.  The smaller the argument, the less smoothing there will be.  In the estimates we just computed, the value of this (ignored) argument was .9.',
   '',
   '>> rt=sort(rt);',
   '>> for a=.3:1.2:3,',
   '>>     f=Gausskernel(t,rt,a)',
   '>>    plot(t,f)',
   '>> end',
   '>> hold off'};

  %========== Slide 19 ==========

  slide(19).code={
   '' };
  slide(19).text={
   'How to choose the best smoothing parameter?  Good question.  Silverman recommends sticking with .9 unless you know what you''re doing.  The bad thing about density estimation is that you can never be sure that you''re doing it right.  One thing you might do is to compare your estimate with the estimate of simulated data from a known distribution.'};

  %========== Slide 20 ==========

  slide(20).code={
   'theta=gamfit(rt);',
   'pd=[[''k-''];[''b-''];[''r-'']];',
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,gampdf(t,theta(1),theta(2)),''g-'')',
   'hold on',
   'plot(t,Gausskernel(t,rt,2.8),''b-'')',
   'set(gca,''ylim'',[0 .006],''xlim'',[0 2000])',
   'title(''Gamma pdf (green) and kernel estimate (blue)'')',
   '' };
  slide(20).text={
   'Let''s look at the Gaussian kernel estimate of the pdf for rt relative to a best-fitting gamma pdf.   We''ll use the ''gamfit'' function to estimate the gamma parameters.',
   '',
   '>> theta=gamfit(rt);',
   '>> plot(t,gampdf(t,theta(1),theta(2)),''g-'')',
   '>> hold on',
   '>> plot(t,Gausskernel(t,rt,2.8),''b-'')',
   ''};

  %========== Slide 21 ==========

  slide(21).code={
   '' };
  slide(21).text={
   'Looks pretty good, eh?  It''s really important to keep in mind that smoothing removes potentially important characteristics of the data.  If I base the choice of smoothing parameter on some best-fitting, unimodel and positively-skewed distribution, my estimate is going to look unimodal too.   The value 2.8 is pretty huge, as far as these things go.',
   ''};

  %========== Slide 22 ==========

  slide(22).code={
   'plot(t,.25*(normpdf(t,700,100)+gampdf(t,3.5,200)+exppdf(t-400,300)+chi2pdf((t-500)/10,4)/10),''r-'')',
   'title(''True pdf (red), gamma pdf (green) and oversmoothed estimate (blue)'')',
   '' };
  slide(22).text={
   'This is the true pdf, the distribution from which I simulated the data in test.dat.  It''s a mixture of 4 very different distributions.  You can see now that the estimate was terribly oversmoothed.'};

  %========== Slide 23 ==========

  slide(23).code={
   'hold off',
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,.25*(normpdf(t,700,100)+gampdf(t,3.5,200)+exppdf(t-400,300)+chi2pdf((t-500)/10,4)/10),''r-'')',
   'hold on',
   'f = Gausskernel(t,sort(rt));',
   'plot(t,f,''g-'')',
   'title(''True pdf (red) and original estimate (green)'')',
   '',
   '' };
  slide(23).text={
   'Here we see the true pdf with the original kernel estimate we computed.  Even with a smoothing parameter of .9 it still is oversmoothed.',
   '',
   ''};

  %========== Slide 24 ==========

  slide(24).code={
   'plot(t,Gausskernel(t,rt,.3),''k-'')',
   'hold off',
   '',
   '' };
  slide(24).text={
   'The point of this exercise is that you need to be careful when it comes to the smoothing parameter, whether you''re working with histogram or kernel estimators.  Expect some error.  Don''t be afraid to explore your data to determine the best estimate.  But also, don''t build any theoretical arguments on the appearance of a density estimate.',
   '',
   '(The true pdf used in this example is one that will never be accurately estimated.  All density estimators will have trouble with sharp, narrow peaks.)',
   '',
   '>> plot(t,Gausskernel(t,rt,.3),''k-'')',
   '>> hold off'};

  %========== Slide 25 ==========

  slide(25).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot([ -3:.01:3],epanech([ -3:.01:3]),''b-'')',
   'title(''The Epanechnikov Kernel'')',
   'hold on',
   '' };
  slide(25).text={
   'Let''s move on the the hazard function.  The hazard function is even more difficult to estimate than the density.  There have been a number of proposals on how best to perform such an estimate, but I am only going to tell you about the one that I like best.  It, too, is based on a kernel estimate, but of both the density and the distribution.',
   '',
   'The kernel estimate is constructed just as before, only using an Epanechnikov kernel (shown above) instead of a Gaussian kernel.  (There is little difference between the two, except that the Epanechnikov kernel has slightly better asymptotic properties.)'};

  %========== Slide 26 ==========

  slide(26).code={
   'hold off' };
  slide(26).text={
   'By using kernel estimators for both the pdf and the cdf (remember that the hazard function is pdf/(1-cdf)), both estimates are continuous functions.  This means that as the cdf goes to one, the behavior in the tail of the hazard function estimate will be better behaved.',
   '',
   'I have found that the Epanechnikov kernel estimate of the hazard function works better on average than other hazard function estimators.  Your mileage may vary.'};

  %========== Slide 27 ==========

  slide(27).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'h=  hazard(t,rt);',
   'plot(t,h)',
   'title(''Hazard Estimate'')',
   'hold on' };
  slide(27).text={
   'I have written a few functions that allow for the estimation of hazard functions.  The function "epanech" computes the Epanechnikov kernel, and "Iepanech" computes its integral (necessary for the kernel estimate of the cdf).   Both these functions are used by "hazard," which computes the estimated hazard function.',
   '',
   '>> h = hazard(t,rt);',
   '>> plot(t,h)'};

  %========== Slide 28 ==========

  slide(28).code={
   'axis([0 2000 0 .02])' };
  slide(28).text={
   'Notice that our plot is not very informative.  The problem is that the cdf in the denominator has reached 1, and the estimate has shot up to very large values in the tail.  Ignore those values: we know they''re wrong anyway.',
   '',
   '>> axis([0 2000 0 .02])'};

  %========== Slide 29 ==========

  slide(29).code={
   '[h,sh]=hazard(t,rt);',
   ' plot(t,h-sh,''r:'',t,h+sh,''r:'')' };
  slide(29).text={
   'One question we might want to answer using the hazard function is whether or not it is monotonic increasing.  If it isn''t, we can rule out lots of candidate distributions for the RTs, like the exGaussian and the gamma.  There are a few ways that we might explore this problem statistically.  One way is to bootstrap the hazard estimate - we''ll talk about bootstrapping another time.  The asymptotic standard error can also be computed, and you can request the standard errors by specifying a second output variable from hazard.',
   '',
   '>> [h,sh]=hazard(t,rt);',
   '>> plot(t,h-sh,''r:'',t,h+sh,''r:'')'};

  %========== Slide 30 ==========

  slide(30).code={
   'axis([0 1000 0 .01])' };
  slide(30).text={
   'We can see that the size of the standard error in the earliest peak of the estimate is fairly small, much smaller than the overall tendency to decline.  I would therefore argue that this curve is nonmonotonic, ruling out the exGaussian, gamma, and other distributions with monotonic increasing hazard functions.',
   '',
   'If you want, you can shorten up the axes to get a better look.',
   '',
   '>> axis([0 1000 0 .01])'};

  %========== Slide 31 ==========

  slide(31).code={
   'th=.25*(normpdf(t,700,100)+gampdf(t,3.5,200)+exppdf(t-400,300)+chi2pdf((t-500)/10,4)/10)./(1-.25*(normcdf(t,700,100)+gamcdf(t,3.5,200)+expcdf(t-400,300)+chi2cdf((t-500)/10,4)/10));',
   'plot(t,th,''g-'')',
   'hold off' };
  slide(31).text={
   'The reason that I like this estimator is that it''s a little easier to see when it''s giving garbage.  When the tail starts oscillating, you know that you can ignore it, and it tends to fall apart a little bit later than some other estimators.',
   'In the plot above, I''ve computed the true hazard function and plotted it in green.',
   '',
   'The hazard estimate is very accurate for the early part of the curve, and the nonmonotonicity is not an illusion, although the estimate does not decrease as rapidly as the true hazard.  The oscillations beginning at about 800 ms are indicating that the estimate is breaking down.'};

  %========== Slide 32 ==========

  slide(32).code={
   'pd =[''b-'';''g-'';''k-'';''y-'';''c-''];',
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,th,''r-'')',
   'hold on',
   'for a=.1:.1:.5,',
   '    h=hazard(t,rt,a);',
   '    i=round(a*10);',
   '    plot(t,h,pd(i,:))',
   ' end',
   'axis([0 1000 0 .02])',
   'title(''True hazard (red) and several estimates'')',
   'hold off' };
  slide(32).text={
   'You can play around with the smoothing constant if you like.  The function hazard takes a third argument (which defaults to the value .3).   In the plot above, the true hazard is shown in red, and several estimates are shown.  The blue estimate has the lowest smoothing and cyan has the highest.',
   '',
   '>> for a=.1:.1:.5,',
   '>>      h=hazard(t,rt,a);',
   '>>      plot(t,h)',
   '>>      hold on',
   '>> end'};

  %========== Slide 33 ==========

  slide(33).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'xh=hazard(t,x'') ;',
   'gamhaz=  gampdf(t,3,200)./(1-gamcdf(t,3,200));',
   'plot(t,xh,''r-'',t,gamhaz,''b-'')',
   'axis([0 2000 0 .01])',
   'title(''Gamma hazard (blue) and Estimate (red)'')',
   'hold off' };
  slide(33).text={
   'You should also compare the hazard estimator computed for simulations from known distributions, just to convince yourself that it works.',
   '',
   '>> xh=hazard(t,x);',
   '>> gamhaz=gampdf(t,3,200)./(1-gamcdf(t,3,200));',
   '>> plot(t,xh,t,''r-'',t,gamhaz,''b-'')'};

  %========== Slide 34 ==========

  slide(34).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'text(500,.005,''End of Function Estimation Demo'')',
   'title('''')' };
  slide(34).text={
   'That''s about all I have to say about nonparametric function estimators.  Remember that there are probably mistakes in the routines that I''ve provided for you, and be careful!'};
end