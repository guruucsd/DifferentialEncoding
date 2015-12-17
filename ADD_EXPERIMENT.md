Adding a new experiment
====================

This file outlines how to add a new experiment to the codebase. 

### Our example: contrast balancing (Okubo & Michimata, 2002)

Let's say you'd like to model the Okubo & Michimata (2002). 

##### Stimuli:
Subjects are shown five dots, all in a horizontal row, and then two dots
either above or below. The dots can be monochrome (white), or
"contrast balanced"--surrounded by a think black outline that removes
low spatial frequency information.

A second line of two dots appears either above or below the line
of five dots, at variable distances.

##### Task:
There are two tasks:

1. Categorical: subjects respond whether the line of two dots is "above" or "below" the line of five dots.
2. Coordinate: subjects respond whether the line of two dots is "near" or "far" from the line of five dots.

##### So to summarize, there are 4 experiments:

1. monochrome dots, categorical task
2. contrast-balanced dots, coordinate task.
3. monochrome dots, categorical task
4. contrast-balanced dots, coordinate task.

##### To model this, there are three steps:

1. Create "datasets" that define the inputs (stimuli) and expected outputs (task) for all 4 experiments.
2. (optional) Create experiment-specific analysis & plotting code.
3. Create "experiment" files that train the models, run them through the analyses, and save the results.
4. Gather data from across all four experiments, and write analyses / scripts to compare/contrast results.


#### 1. Create "datasets" that define the stimuli and tasks.

1. Create a directory for experiment-specific code: `code/_expts/okubo_michimata_2002/`
2. In that directory, create a `de_StimCreate.m` file.
3. Add the required function header: `function [train,test] = de_StimCreate(stimSet, taskType, opt)`
   * `stimSet` - string specifying which stimulus set to create inputs for (let's say, 'dots' or 'dots-cb')
   * `taskType` - string specifying which task to create expected outputs for (let's say, 'categorical' or 'coordinate')
   * `opts` - cell array containing experiment-specific options. Could be the distances between dots, or some other optional metric.
   * `train`, `test` - structures containing data and metadata for the stimuli/task experiment combo:
      * `train.X` - [pixels x examples (e.g. 850x16)] - input images
      * `train.XLAB` - [1 x examples] a text label for each image (used for display or filtering purposes)
      * `train.T` - [n_outputs x examples] expected outputs based on the task
      * `train.TLAB` - [1 x examples] a text label for each expected output (used for display or filtering purposes)
     * any other metadata that you'd like to have for your analysis code.

4. Write the function(s) that creates the actual stimuli (i.e. each image in the form of an array) for that experiment, e.g., a create_dots function. The parameters should allow for various types of stimuli to be created, e.g. a "distance" variable for the distance between dots. The function(s) will be called by the main body of the de_StimCreate.m code.

5. Write the code that creates the appropriate variables (see the parameters in the header) to be assigned to train and test. This will require calls to the functions that actually create the stimuli images, and creating and setting the appropriate labels.


#### 2. (optional) Add analysis code.

1. Add file `code/_expts/okubo_michimata_2002/de_Analyzer.m` (copy from `code/_expts/vanhateren/de_Analyze.m`).
* `function [stats, figs]  = de_Analyzer(mSets, mss)`
  * `mSets` - struct containing model settings applied to each model run (many instances are trained and averaged)
  * `mss` - cell matrix containing each model run, including: model settings, model connection and weights, etc.
  * `stats` - struct containing statistical analyses that were run (as requested in the experiment file below)
  * `figs` - struct containing figure handles for plots generated (as requested in the experiment file below)
2. Add any specific code into that file (or call functions from there).

This code likely will include calls to some sort of staticizer (running statistical analyses) and figurizer (making plots) which will handle the desired analysis.

#### 3. Create "experiment" files to train models.

`Uber` is my tag for training an autoencoder with natural images, then using the autoencoder to get hidden unit encodings on task-related images. So when you see it... it's just an old notational thing.

1. Create a directory (`experiments/68x50/okubo_michimata/2002`) to run the experiments at the input image size desired (68x50 pixels in this example)
2. In that directory, create a script file to define arguments shared across experiments for creating the model and training it (`uber_okubo_args.m`); copy settings from another model (e.g. `experiments/68x50/sergent_1982/uber_sergent_args.m`)
3. In that directory, create a script file for each experiment to run (`uber_okubo_dots_categorical.m`, etc); copy code from another script (e.g. `experiments/68x50/sergent/uber_sergent_sergent.m`)
4. Tweak parameters in `uber_okubo_dots_categorical.m` to run the desired experiment with the desired analyses and plots:
    * `stats` variable defines which statistics to analyze after training.
    * `plts` variable defines which plots to show after training.
    * Calling `uber_okubo_args` creates a parameter list that overrides the defaults defined in `uber_okubo_args` with the values passed as arguments to the function.
    * de_SimulatorUber takes two parameters:
        * image set for training the autoencoder (`vanhateren/250` is 250 patches from the vanhateren "natural images" dataset)
        * image and task for the perceptron (`okubo_michimata_2002/dots/categorical` is appropriate here)


#### (optional) 4. Analyzing all experiments at once.

These instructions get you up and running to analyze a single experiment. However, the main result of this paper is a comparison across all four experiments (Figure 2). To do this:

1. Add a new script (`experiments/68x50/okubo_michimata_2002/uber_okubo_all.m`) that calls into all four experiments, and saves the output from each call.
2. Add new code into that script (or better, into `code/_expts/okubo_michimata_2002/analysis/`) to analyze the results across all 4 experiments and plot a figure similar to figure 4.
 
