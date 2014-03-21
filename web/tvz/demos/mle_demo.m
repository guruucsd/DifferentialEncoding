function slide=mle_demo
% This is a slideshow file for use with playshow.m and makeshow.m
% To see it run, type 'playshow mle_demo', 

% Copyright 1984-2000 The MathWorks, Inc.
if nargout<1,
  playshow mle_demo
else
  %========== Slide 1 ==========

  slide(1).code={
   'ezmesh(''2*x^2 + 2*y^2'')',
   ' title(''-log L(x,y)'')',
   '' };
  slide(1).text={
   'Model fitting and parameter estimation demo'};

  %========== Slide 2 ==========

  slide(2).code={
   't=[200:10:1800]'';',
   '[rt1 rt2 rt3,rt4]=textread(''test2.dat'');',
   'hist(rt1,20)',
   'hold on',
   'plot(t,100*75*gampdf(t-300,2,200),''r-'')',
   'axis([200 1800 0 15])',
   '' };
  slide(2).text={
   'Fitting a model is the same as estimating the parameters of a model.  We want to use our data to estimate as best we can the parameters, and ideally, observe changes in those parameters across experimental conditions.  Matlab provides a lot of tools for parameter estimation, and I have written some specialized ones for RT modeling.'};

  %========== Slide 3 ==========

  slide(3).code={
   'hold off' };
  slide(3).text={
   'Most of the models that folks who are interested in RTs use specify explicitly the distributional family from which RTs are presumed to arise.  Estimating the parameters of these models is not always easy.  Using these estimates to make inferences is also difficult, because often we use nonstandard approaches to obtain those estimates, and the statistical formalizations of error in those estimates are based on assumptions that are unfounded (e.g., equal variance, stationarity of error, etc.).'};

  %========== Slide 4 ==========

  slide(4).code={
   '' };
  slide(4).text={
   'In this demo I will concentrate on Maximum Likelihood Estimation (MLE) of parameters.  MLEs are not always the best, but they usually are, and they have really nice properties, and the likelihood function is used for model comparisons, hypothesis testing, and other interesting problems.'};

  %========== Slide 5 ==========

  slide(5).code={
   'subplot(''Position'',[0.1 .75 0.23 0.23]);',
   'hist(rt1,20)',
   'set(gca,''ylim'',[0 25],''xlim'',[0 3000])',
   'text(2000,20,''rt1'')',
   'subplot(''Position'',[0.45 .75 0.23 0.23]);',
   'hist(rt2,20)',
   'set(gca,''ylim'',[0 25],''xlim'',[0 3000])',
   'text(2000,20,''rt2'')',
   'subplot(''Position'',[0.1 .45 0.23 0.23]);',
   'hist(rt3,20)',
   'set(gca,''ylim'',[0 25],''xlim'',[0 3000])',
   'text(2000,20,''rt3'')',
   'subplot(''Position'',[0.45 .45 0.23 0.23]);',
   'hist(rt4,20)',
   'set(gca,''ylim'',[0 25],''xlim'',[0 3000])',
   'text(2000,20,''rt4'')',
   '' };
  slide(5).text={
   'The likelihood function is simply the joint probability of a data set under the assumption that the data are independent and identically distributed.  The likelihood is assumed to be a function of the parameters, not the data.  Let''s begin by entering the data in file "test2.dat."',
   '',
   '>> [rt1 rt2 rt3,rt4]=textread(''test2.dat'');',
   '>> subplot(2,2,1); hist(rt1,20)',
   '>> subplot(2,2,2); hist(rt2,20)',
   '>> subplot(2,2,3); hist(rt3,20)',
   '>> subplot(2,2,4); hist(rt4,20)'};

  %========== Slide 6 ==========

  slide(6).code={
   'p=gamfit(rt1);',
   '' };
  slide(6).text={
   'Let''s begin with rt1, the RTs from "condition 1."  Matlab has a number of fitting routines, but they are somewhat limited.  For example, the fitting routine for the gamma distribution does not allow a shift parameter and it uses method of moments (not MLE).  But let''s try it.',
   '',
   '>> p=gamfit(rt1)',
   'p =',
   '',
   '    6.7125  104.8687',
   ''};

  %========== Slide 7 ==========

  slide(7).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   't=[200:10:2500]'';',
   'edges=[100:50:2500];',
   'h=histc(rt1,edges)/(50*100);',
   'bar(edges,h,''b'')',
   'hold on',
   'plot(t,gampdf(t,p(1),p(2)),''r-'')',
   'set(gca,''ylim'',[0 .003])',
   'title(''RT1 and the best-fitting gamma (red)'')' };
  slide(7).text={
   'Plot the best-fitting gamma pdf on top of the histogram estimate of the pdf.',
   '',
   '>> t=[200:10:2500]'';',
   '>> edges=[100:50:2500];',
   '>> h=histc(rt1,edges)/(50*100);',
   '>> bar(edges,h,''b'')',
   '>> hold on',
   '>> plot(t,gampdf(t,p(1),p(2)))'};

  %========== Slide 8 ==========

  slide(8).code={
   'hold off' };
  slide(8).text={
   'You may be asking now, "So it''s a fit, but is it a good fit?"  There are many ways to answer that question, most of them aren''t very good.  A thorough discussion of model evaluation is beyond the scope of this demonstration.  I''ll briefly cover some options later.'};

  %========== Slide 9 ==========

  slide(9).code={
   'plot(t,exgausspdf(t,[400,50,100]),t,exgausspdf(t,[400,50,200]),t,exgausspdf(t,[400,50,300]))',
   'title(''ExGaussian pdfs'')' };
  slide(9).text={
   'I''d like to concentrate on the exGaussian distribution, which is frequently used as a parametric (but atheoretical) estimate of the pdf.  The exGaussian is the sum of an exponential and a normal random variable.  I have written two functions, exgausspdf and exgausscdf, for the exGaussian.  The exGaussian has three parameters, mu and sigma of the normal component and tau of the exponential.',
   '',
   '>> plot(t,exgausspdf(t,[400,50,100]),t,exgausspdf(t,[400,50,200]),...',
   '            t,exgauss(t,[400,50,300]))',
   ''};

  %========== Slide 10 ==========

  slide(10).code={
   'theta1=fminsearch(''MLE'',[400,500,100],optimset(''MaxFunEvals'',500),''exgausspdf'',rt1);',
   'bar(edges,h,''b'')',
   'hold on',
   'plot(t,exgausspdf(t,theta1),''r-'')',
   'title(''RT1 and the best-fitting exGaussian (red)'')' };
  slide(10).text={
   'The function ''MLE'' (not to be confused with the matlab function ''mle'') computes the negative log likelihood of any function we specify (like exgausspdf).  Let''s fit the exGaussian model to rt1.',
   '',
   '>> theta=fminsearch(''MLE'',[400,50,100],optimset(''MaxFunEvals'',500),...',
   '        ''exgausspdf'',rt1)',
   'theta =',
   '',
   '  361.4770   37.0692  342.4530',
   '',
   '>> bar(edges,h,''b-'')',
   '>> hold on',
   '>> plot(t,exgausspdf(t,theta),''r-'')'};

  %========== Slide 11 ==========

  slide(11).code={
   '',
   '' };
  slide(11).text={
   'Does the model fit well?  By eye, it might not fit as well as the gamma model.  There are a few things we can do.  First, we might compute a chi-squared statistic.',
   '',
   '>> [x2,p] = chi2(rt1,''exgausscdf'',theta,[20:10:80]);',
   '>> [x2,p]',
   '',
   'ans =',
   '',
   '    9.8092    0.0438',
   '',
   ''};

  %========== Slide 12 ==========

  slide(12).code={
   '' };
  slide(12).text={
   'The chi2 function returns a p-value slightly less than .05, indicating a "poor" fit.  This function divides the data according to the percentiles specified in the last (optional) argument. It requires a function (''exgausscdf'') to indicate the cdf of the model being fit.  Play around with the chi2 function and notice what happens when you change the bins.  Because the chi2 statistic depends so much on the choice of bins, it is not a very good measure of goodness of fit.  Furthermore, for larger sample sizes, a chi2 statistic can indicate significance when in fact the true model has been fit.',
   '',
   '>> [x2,p]=chi2(rt1,''exgausscdf'',theta,[15:7:85]);',
   '>> [x2,p]',
   'ans =',
   '',
   '   11.7729    0.1616',
   ''};

  %========== Slide 13 ==========

  slide(13).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,EDF(t,rt1),''b-'')',
   'hold on',
   'plot(t,exgausscdf(t,theta1),''r-'')',
   'title(''RT1 edf (blue) and best-fitting exGaussian cdf (red)'')' };
  slide(13).text={
   'Another thing we might do is a Kolmogorov-Smirnoff test, which can help us determine whether a particular sample was drawn from a particular distribution.  Both one and two-sample KS tests are available in matlab.',
   '',
   '>> kstest(rt1,[rt1 exgausscdf(rt1,theta)],.05,0)',
   'ans =',
   '',
   '     0',
   '',
   'Because a 0 was returned, we must retain the null hypothesis that the sample is exGaussian.'};

  %========== Slide 14 ==========

  slide(14).code={
   'hold off' };
  slide(14).text={
   'The KS test is not satisfactory in the case where the parameters of the null distribution have been estimated.  This introduces additional variability and reduces power.  Although the KS test indicated that we cannot reject the null hypothesis of an exGaussian sample (with the parameters we estimated), this sample is not exGaussian at all.',
   '',
   'Evaluating goodness of fit is hard.'};

  %========== Slide 15 ==========

  slide(15).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot([350:.1:370],normpdf([350:.1:370],theta1(1),2))',
   'title(''Pdf of mu'')',
   'xlabel(''mu'')',
   'axis([350 370 0 .22])' };
  slide(15).text={
   'Let''s examine the MLEs of the exGaussian fit to our data.',
   '',
   '>> theta',
   '',
   'theta =',
   '',
   '  361.4770   37.0692  342.4530',
   '',
   'These values are estimates; there is some variability associated with them.  With a slightly different sample, I must obtain different MLEs.'};

  %========== Slide 16 ==========

  slide(16).code={
   '' };
  slide(16).text={
   'Some of the matlab MLE fitting routines provide estimates of variability in the form of a confidence interval.  This interval is computed from the Fisher information matrix (a matrix of derivatives of the likelihood function) and an assumption that the MLEs are normally distributed.  In the limit, the Fisher information matrix is an excellent way to estimate variability.',
   '',
   'There is another way that I am going to demonstrate because it is incredibly powerful, widely applicable, and does not require assumptions at all.  It is called bootstrapping.'};

  %========== Slide 17 ==========

  slide(17).code={
   '' };
  slide(17).text={
   'Bootstrapping uses the sample itself as a nonparametric estimate of the distribution.  We want to know what will happen to mu if we repeatedly sample from the distribution that generated rt1.  Pretending that our sample is our distribution, we sample observations with replacement until we obtain a "bootstrapped" sample the same size as the original sample.',
   '',
   '>> y=bootstrap(rt1);',
   '>> bs_theta=fminsearch(''MLE'',[400,500,100],...',
   '                  optimset(''MaxFunEvals'',500),''exgausspdf'',y)',
   'bs_theta =',
   '',
   '  442.7871  102.7559  283.3628',
   ''};

  %========== Slide 18 ==========

  slide(18).code={
   '' };
  slide(18).text={
   'The value of mu for the bootstrapped sample is 442.79, considerably different from the original value of  361.48.  Suppose we wanted to argue that the population parameter mu was 300.  Should we accept or reject this hypothesis?  Let''s construct a 95% bootstrapped confidence interval around 361.48.',
   '',
   '>> for i=1:100,',
   '>>   y=bootstrap(rt1);',
   '>>   bs_theta(i,:)=fminsearch(''MLE'',theta,optimset(''MaxFunEvals'',500),...',
   '                         ''exgausspdf'',y) ;',
   '>> end',
   '>> prctile(bs_theta(:,1),[2.5 97.5])',
   'ans =',
   '',
   '  342.1776  530.7211',
   ''};

  %========== Slide 19 ==========

  slide(19).code={
   'subplot(''Position'',[0.05 .75 0.17 0.17]);',
   'plot([200:520],normpdf([200:520],theta1(1),45.15))',
   'text(500,.007,''mu'')',
   'subplot(''Position'',[0.3 .75 0.17 0.17]);',
   'plot([-90:200],normpdf([-90:200],theta1(2),44.25))',
   'text(75,.007,''sigma'')',
   'subplot(''Position'',[0.55 .75 0.17 0.17]);',
   ' plot([180:500],normpdf([180:500],theta1(3),43.96))',
   'text(100,.007,''tau'')',
   '' };
  slide(19).text={
   'The confidence interval is [342.1776 ,530.7211], based on 100 bootstrapped samples (which is not enough).  Based on this interval, we would reject the hypothesis that mu=300.',
   '',
   'We only perform 100 bootstraps because of time.  Do at least 1000 for your own applications.',
   '',
   'We can also estimate the standard error of the estimates by computing the standard deviation of the bootstrapped estimates:',
   '',
   '>> std(bs_theta)',
   'ans =',
   '',
   '   45.1532   44.2519   43.9624',
   ''};

  %========== Slide 20 ==========

  slide(20).code={
   '' };
  slide(20).text={
   'Now let''s look at rt1 and rt2.  Can we say that the exGaussian parameters are the same for the distributions from which these two conditions were sampled?',
   '',
   '>> theta1=theta;',
   '>> theta2=fminsearch(''MLE'',[400,500,100],...',
   '                  optimset(''MaxFunEvals'',500),''exgausspdf'',rt2);',
   ''};

  %========== Slide 21 ==========

  slide(21).code={
   'subplot(''Position'',[0.05 .75 0.17 0.17]);',
   'plot([-200:200],normpdf([-200:200],0,50))',
   'text(50,.009,''mu1-mu2'')',
   'subplot(''Position'',[0.3 .75 0.17 0.17]);',
   'plot([-200:200],normpdf([-200:200],0,50))',
   'text(-50,.009,''sigma1-sigma2'')',
   'subplot(''Position'',[0.55 .75 0.17 0.17]);',
   'plot([-200:200],normpdf([-200:200],0,50))',
   'text(30,.009,''tau1-tau2'')' };
  slide(21).text={
   '>> [theta1;theta2]',
   '',
   'ans =',
   '',
   '   361.4770   37.0692  342.4530',
   '   421.9847   84.5116  234.4154',
   '',
   'There are a few ways to approach this question.  I will bootstrap the difference between the two parameter estimates and construct a confidence interval for the difference.'};

  %========== Slide 22 ==========

  slide(22).code={
   '' };
  slide(22).text={
   'As we see below, all of the confidence intervals contain 0, so we might conclude that the parameters estimated from each sample are not significantly different.  (Remember to use more than 100 samples in real applications.)',
   '',
   '>> for i=1:100,',
   '>>  y1=bootstrap(rt1);y2=bootstrap(rt2);',
   '>>  bs_theta1=fminsearch(''MLE'',theta1,...',
   '                  optimset(''MaxFunEvals'',500),''exgausspdf'',y1);',
   '>>  bs_theta2=fminsearch(''MLE'',theta2,...',
   '                  optimset(''MaxFunEvals'',500),''exgausspdf'',y2);',
   '>>  diff(i,:) = bs_theta1-bs_theta2;',
   '>> end',
   '>> prctile(diff,[2.5 97.5])',
   '',
   'ans =',
   '',
   ' -112.6714  -99.8444  -25.5577',
   '     55.8608    48.1254  202.4226',
   ''};

  %========== Slide 23 ==========

  slide(23).code={
   '[edf se_edf]=textread(''edf.dat'');',
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t(1:184),edf,''b-'',t(1:184),edf-se_edf,''r:'',t(1:184),edf+se_edf,''r:'')' };
  slide(23).text={
   'So far we''ve concentrated on estimating parameters and the standard errors of those parameters.  We can also talk about estimating the standard errors of functions, like the Gaussian kernel or the EDF.',
   '',
   'Let''s bootstrap the standard error of the EDF of rt1.',
   '',
   '>> for i=1:1000,',
   ' >>  y=bootstrap(rt1);',
   ' >>  edf(:,i)=EDF(t,sort(y));',
   '>> end',
   '>> se_edf=std(edf'')'';',
   '>> edf=EDF(t,rt1);',
   '>> plot(t,edf,''b-'',t,edf-se_edf,''r:'',t,edf+se_edf,''r:'')'};

  %========== Slide 24 ==========

  slide(24).code={
   '' };
  slide(24).text={
   'Before we leave this demonstration, there is one more technique I''d like to show you.  We already compared rt1 and rt2 by looking at the best-fitting exGaussian parameters for each.  But we could examine the distributions of each directly.  The test that we are going to perform is called a permutation test.  It is nonparametric and extremely powerful, and is usually more accurate than tests based on asymptotic assumptions, like the t-test or F-test.',
   '',
   'Our null hypothesis is the following: the distributions of rt1 and rt2 are the same.'};

  %========== Slide 25 ==========

  slide(25).code={
   's_obs = (EDF(t,rt1)-EDF(t,rt2))''*(EDF(t,rt1)-EDF(t,rt2));' };
  slide(25).text={
   'If the null hypothesis is true, all the observations in rt1 and rt2 are independent and identically distributed.  The condition is irrelevant.  Let''s define a statistic that we expect to be big if the null hypothesis is false and small if it is true.  The KS test is based on the maximum difference between the EDFs of rt1 and rt2.  We could also use the sum of squared differences between the two curves.',
   '',
   '>> ss_obs = (EDF(t,rt1)-EDF(t,rt2))''*(EDF(t,rt1)-EDF(t,rt2))',
   'ss_obs =',
   '',
   '    0.4214',
   ''};

  %========== Slide 26 ==========

  slide(26).code={
   'ss=textread(''ss.dat'');',
   'hist(ss,20)' };
  slide(26).text={
   'How big is ss_obs = .42?  Is this about what we might expect if the null hypothesis is true?  To find out, assume the null hypothesis is true and bootstrap the value of ss.',
   '',
   '>> rt=[rt1;rt2];',
   '>> n=length(rt); m=length(rt1);',
   '>> for i=1:1000,',
   '>>  scramble=randperm(n);',
   '>>  y1=rt(scramble(1:m)); y2=rt(scramble(m+1:n));',
   '>>   ss(i)=(EDF(t,sort(y1))-EDF(t,sort(y2)))''...',
   '>>     *(EDF(t,sort(y1))-EDF(t,sort(y2)));',
   '>> end',
   '>> hist(ss,20)'};

  %========== Slide 27 ==========

  slide(27).code={
   '' };
  slide(27).text={
   'To see what values of the statistic we might observe under the null hypothesis, examine the histogram of ss.',
   '',
   '>> hist(ss,20)',
   '',
   'We need to determine the quantile rank of ss_obs = .42.',
   '',
   '>> q=mean(ss<ss_obs)',
   '',
   'q =',
   '',
   '    0.8000',
   '',
   ''};

  %========== Slide 28 ==========

  slide(28).code={
   'subplot(''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(t,EDF(t,rt1),''b-'',t,EDF(t,rt4),''r-'')',
   'title(''RT1 (blue) and RT4 (red)'')' };
  slide(28).text={
   'Based on all the permutations of rts that we observed until the null hypothesis, the observed statistic ss_obs has quantile rank of .80.  We would reject the null hypothesis if this rank was very high, say, over .95.  Based on this analysis, we retain the null hypothesis.  (In this case, the null hypothesis is true.)',
   '',
   'If you have time, compare rt1 and rt4 in the same way.  They come from different distributions and so the quantile rank of ss_obs should be high.',
   '',
   '>> ss_obs=(EDF(t,sort(rt1))-EDF(t,sort(rt4)))''*...',
   '>>       (EDF(t,sort(rt1))-EDF(t,sort(rt4)));',
   '>> rt=[rt1;rt4];',
   '>> n=length(rt);',
   '>> m=length(rt1);',
   '>> for i=1:1000,',
   '>>   scramble=randperm(n);',
   '>>   y1=rt(scramble(1:m)); y2=rt(scramble(m+1:n));',
   '>>   ss(i)=(EDF(t,sort(y1))-EDF(t,sort(y2)))''... ...',
   '>>      *(EDF(t,sort(y1))-EDF(t,sort(y2)));',
   '>> end',
   '>> mean(ss<ss_obs)',
   ''};

  %========== Slide 29 ==========

  slide(29).code={
   'text(1000,.5,''End of MLE demo'')' };
  slide(29).text={
   'The trick to working through hypotheses with permutations is to select statistics that behave in the appropriate ways.  Similarly, bootstrapping sometimes requires some imagination.',
   '',
   'The importance of these techniques with respect to RT modeling is that frequently the assumptions we would rely on for an asymptotic test are violated, numerical techniques have to be used to recover parameters or density functions, and so numerical methods have to be used to figure out what''s going on.',
   '',
   'The methods I''ve demonstrated are not assumption-free, so use them with caution and read about them before really using them.  I hope this has been helpful.'};
end
