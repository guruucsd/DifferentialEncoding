Adding a new experiment
====================

This file outlines how to add a new experiment to the codebase. Rather than
describing every step in full, as well as datastructures needed,
this file will recommend copying code from relevant places and
referencing relevant functions / docstrings.

### Learn via an example.

Let's say you'd like to use the Differential Encoding model to model
a behavioral task from Okubo & Michimata (2002). This paper contains
a number of related experiments, each which contains a task (defined by
a set of images, each with a corresponding "correct" behavioral response)
and human behavioral data.

To see how the model performs on a behavioral task, you need to:

1. Create code that returns the appropriate data for running the task (input images and expected behavioral results).
2. Create "experiment" files that run the desired experiment with appropriate model parameters.

To compare the model to the human behavioral data (or run other, experiment-specific analyses):

3. Create code that does the analysis.

Sound easy? Let's do it.


#### 1. Define the task data.

1a. Create a file `code/_expts/okubo_michimata_2002/de_StimCreate.m` (copy from the `sergent_1982` directory for the proper function declaration)

When you run the experiment later, you'll pass `okubo_michimata_2002` as your experiment ID. The code will know to call `de_StimCreate` from that directory.

1b. For each stimulus type (`dots` and `dots-cb` for the two image types defined in their Figure 1) and task (`categorical` and `coordinate`)
Define your input images (in code, or elsewhere and simply load in code) and corresponding task outputs.

1c. Return all data in the documented variables (train, test)
* `train.X` - [pixels x examples] e.g. 850x16
* `train.XLAB` - [1 x examples] a text label for each image (used for display or filtering purposes)
* `train.T` - [n_outputs x examples] expected outputs based on the task
* `train.TLAB` - [1 x examples] a text label for each expected output (used for display or filtering purposes)



#### 2. Make scripts to run.

2a. Create files `experiments/34x25/okubo_michimata_2002/{uber_okubo_args.m, uber_okubo_dots_categorical.m} (copy from elsewhere)

* `uber_okubo_args.m` will define the parameters for training all images and tasks (they should share as much as possible!)
* `uber_okubo_dots_categorical.m` will call the appropriate functions to execute the desired task (categorical) on the desired images (dots)

2b. Tweak variables and function parameters in `uber_okubo_dots_categorical.m` to run the desired experiment.

* `stats` variable defines which statistics to analyze after training.
* `plts` variable defines which plots to show after training.
* Calling `uber_okubo_args` creates a parameter list that overrides the defaults defined in `uber_okubo_args` with the values passed as arguments to the function.
* de_SimulatorUber takes two parameters:
    * image set for training the autoencoder (`vanhateren/250` is 250 patches from the vanhateren "natural images" dataset)
    * image and task for the perceptron (`okubo_michimata_2002/dots/categorical` is appropriate here)


#### 3. Add analysis code.

3a. Add file `code/_expts/okubo_michimata_2002/de_Analyze.m` (copy from `code/_expts/vanhateren/de_Analyze.m`).
3b. Add any specific code into that file (or call functions from there).


#### (optional) 4. Analyzing all experiments at once.

These instructions get you up and running to analyze a single experiment. However, the main result of this paper is a comparison across all four experiments (Figure 2). To do this:

4a. Add a new script (`experiments/68x50/okubo_michimata_2002/uber_okubo_all.m`) that calls into all four experiments, and saves the output from each call.
4b. Add new code into that script (or better, into `code/_expts/okubo_michimata_2002/analysis/`) to analyze the results across all 4 experiments and plot a figure similar to figure 4.
 
