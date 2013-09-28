% we want to run the same model with different delays, similar to Lewis &
% Elman's setup.
%
% Let's replicate their setup to start.

delay = @(hc, cv, age) (hc(age)./pi./cv(age));
age = -9:3:48;
age_idx = 1:length(age);
hc_typical = 12*log(age + 1 - min(age));
hc_autism = log(age/min(age));
cv_typical = 0.3+0.004*[1:length(age)];

for ai=1:length(age)
  inter_delay = delay(hc_typical, cv_typical, ai);
  intra_delay = 3/8 * inter_delay;
  fprintf('%f %f %f\n', hc_typical(ai), inter_delay, intra_delay);
end;

figure;
hold on;
%plot(hc_typical)
plot(delay(hc_typical, cv_typical, age_idx));
