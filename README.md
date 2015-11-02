Differential Encoding model
====================

[![Join the chat at https://gitter.im/guruucsd/DifferentialEncoding](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/guruucsd/DifferentialEncoding?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### Journal publications:

    Hsiao, Janet H., Cipollini, Ben, and Cottrell, Garrison W. (2013) Hemispheric asymmetry in perception: A differential encoding account. Journal of Cognitive Neuroscience 25(7):998-1007.

### Conference publications:

    Cipollini, B. and Cottrell, G.W. (submitted) A Developmental Model of Hemispheric Asymmetries of Spatial Frequencies. In Proceedings of the 36th Annual Conference of the Cognitive Science Society. Austin, TX: Cognitive Science Society.

    Cipollini, B. and Cottrell, G.W. (2013) Sparse connectivity asymmetry in an autoencoder can explain visual hemispheric asymmetries in local/global, face, and spatial frequency processing. In Proceedings of the 13th Annual Neural Computation and Psychology Workshop (NCPW). San Sebastian, Spain.

    Cipollini, B., Hsiao, J.H-W., and Cottrell, G.W. (2012) Connectivity asymmetry can explain visual hemispheric asymmetries in local/global, face, and spatial frequency processing. In N. Miyake, D. Peebles, & R. P. Cooper (Eds.), Proceedings of the 34th Annual Conference of the Cognitive Science Society. Austin, TX: Cognitive Science Society.


This code base contains code for running 3 major types of simulations; further details can be found in the Github wiki:

**experiments/34x25** - differential encoding model, as published in Cipollini, Hsiao & Cottrell (2013) and Hsiao, Cipollini & Cottrell (2013).  Trains left and right hemisphere autoencoders on one image set, then extracts hidden unit encodings, then trains a classifier network on some behavioral task.

**experiments/prunetrain** - Pruning model of Cipollini & Cottrell (2014).  Trains left and right hemisphere autoencoders on an image set, removing the weakest connections during training. Left and right hemisphere networks differ only in the spatial frequency filtering of the training images, to simulate maturation under differing stages of visual acuity.

**experiments/recfield** - Unpublished (rejected from COSYNE for 2012 - 2014) 2D model showing the effects on a single neuron of different connection patterns.


### Octave compatibility:

This code runs under octave, with the following setup steps:

1. Download and install Octave.
2. Install and import the following packages: `general`, `control`, `image`, 
3. Set `more off` to make sure you get timely outputs :)
