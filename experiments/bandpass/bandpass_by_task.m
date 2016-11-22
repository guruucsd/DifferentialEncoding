function bandpass_by_task(args_path, task_info, varargin)
%
%
%    if (strcmp(tst.mSets.expt, 'slotnick_etal_2001'))
%      trial_types = {'easy', 'hard'};
%    elseif (strcmp(tst.mSets.expt, 'sergent_1982'))
%        trial_types = {'L-S+', 'L+S-'};
%    end
%

  fn_args = guru_stampProps([{ ...
    'n_steps', 10, 'window_steps', 2, ...
    'trial_types', {}, ...
    'opts', {}, 'args', {}, ...
    }, varargin ...
  ]);
  n_steps = fn_args.n_steps;
  window_steps = fn_args.window_steps;
  trial_types = fn_args.trial_types;

  % Get args & opts from function
  [dir_name, file_name] = fileparts(args_path);
  addpath(dir_name);
  args_fn = str2func(file_name);
  [args, opts] = args_fn();
  args = [args, fn_args.args];
  opts = [opts, fn_args.opts];

  % Pre-train the autoencoder on full-fidelity. This will get us the image size.
  [trn] = de_SimulatorUber('vanhateren/250', '', opts, args);
  max_freq = max(trn.mSets.nInput / 2);
  bandpass_step =  max_freq / n_steps;
  window_size = bandpass_step * window_steps;

  % Train the classifier on the bandpass-filtered stimuli.
  tmp = linspace(0, max_freq, n_steps + 2);
  center_freqs = tmp(2:end-1);
  low_freqs = max(0, center_freqs - window_size/2);
  high_freqs = min(max_freq, center_freqs + window_size/2);

  means = zeros(length(trn.mSets.sigma), length(center_freqs));
  stderrs = zeros(size(means));

  for si=1:n_steps
    % Train the model
    cur_opts = struct( ...
        'uber', {opts}, ...
        'task', {[opts, 'bandpass', [low_freqs(si), high_freqs(si)]]} ...
    );
    [~, tst] = de_SimulatorUber('vanhateren/250', task_info, cur_opts, args);
    close all;

    % Store mean performance
    means(:, si) = cellfun(@(x) mean(x), tst.stats.rej.p.err.vals);
    stderrs(:, si) = cellfun(@(x) std(x), tst.stats.rej.p.err.vals) / sqrt(tst.mSets.runs);
end

figure;
errorbar(repmat(center_freqs, [2, 1])', (means'), (stderrs'), 'LineWidth', 2.0);
set(gca, 'FontSize', 14);
legend(guru_csprintf('%.2f', num2cell(trn.mSets.sigma)), 'FontSize', 12);
xlabel('Center Frequency (cycles/ img)', 'FontSize', 14);
ylabel('Sum Squared Error', 'FontSize', 14);
title(sprintf('SSE vs Frequency; Bandpass Step=%.2f, Width=%.2f', bandpass_step, window_size), 'FontSize', 16);
