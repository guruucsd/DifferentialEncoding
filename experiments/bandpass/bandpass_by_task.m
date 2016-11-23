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

  n_runs = trn.mSets.runs;
  n_sigmas = length(trn.mSets.sigma);
  n_plots = 1 + length(trial_types);
  means = zeros(n_sigmas, length(center_freqs), n_plots);
  stderrs = zeros(size(means));
  task1_means = zeros(size(means));
  task2_means = zeros(size(means));
  task1_ste = zeros(size(means));
  task2_ste = zeros(size(means));


  for si=1:n_steps
    % Train the model
    cur_opts = guru_stampProps( ...
        'uber', opts, ...
        'task', [opts, 'bandpass', [low_freqs(si), high_freqs(si)]] ...
    );
    [~, tst] = de_SimulatorUber('vanhateren/250', task_info, cur_opts, args);
    close all;


    % Grab the raw output
    n_trials = numel(tst.mSets.data.test.TLAB);
    p = [tst.models.p];
    o = [p.output];
    err = de_calcPErr( vertcat(o.test), tst.mSets.data.test.T, tst.mSets.p.errorType);
    err = reshape(err, [n_runs, n_sigmas, n_trials]);
    err = permute(err, [1, 3, 2]);  % n_sigmas at the end

    % Store mean performance
    for ti = 0:length(trial_types)  % 0 = all trials.
      cur_err = err;
      if ti > 0
        good_trial_idx = strcmp(trial_types{ti}, tst.mSets.data.test.TLAB);
        cur_err = cur_err(:, good_trial_idx, :);
      end;
      cur_err = reshape(cur_err, [n_runs * size(cur_err, 2), n_sigmas]);
      means(:, si, ti + 1) = mean(cur_err, 1);
      stderrs(:, si, ti + 1) = std(cur_err, [], 1) / sqrt(n_runs);
    end;
  end

  titles = guru_csprintf( ...
      sprintf( ...
        'SSE vs Frequency (%%s)\nBandpass Step=%.2f, Width=%.2f', ...
        bandpass_step, window_size ...
      ), ...
      [{'All'}, trial_types] ...
  );

  % Draw figure; once for log(mean) in case error is wacky
  draw_figure(center_freqs, means, stderrs, titles, trn.mSets.sigma);
  draw_figure(center_freqs, log(means), log(stderrs), titles, trn.mSets.sigma);


function draw_figure(freqs, means, stderrs, titles, sigmas)

  % Output the figures
  figure('Position', [0, 0, 1200 600]);
  for ti=1:length(titles)  % will output each type, plus all.

    subplot(1, length(titles), ti);
    errorbar( ...
      repmat(freqs, [2, 1])', ...
      means(:, :, ti)', stderrs(:, :, ti)', ...
      'LineWidth', 2.0 ...
    );
    set(gca, 'FontSize', 14);
    legend(guru_csprintf('%.2f', num2cell(sigmas)), 'FontSize', 12);
    title(titles{ti}, 'FontSize', 12);
    xlabel('Center Frequency (cycles/ img)', 'FontSize', 14);
    if ti == 0
      ylabel('Sum Squared Error', 'FontSize', 14);
    end;
  end;
