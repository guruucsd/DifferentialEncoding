ABOUT FILES IN THIS DIRECTORY
====================================================

GLOSSARY

pattern or pat: A collection of all Gabor filter responses (2D pixels*freq*orient) for one image.

FUNCTIONS

readpat              ----- reads gabor filter responses from a pat file
drawpat              ----- plots a gabor filter responses read from a pat file
gfCalcFilterParams   ----- creates a set of filter params that evenly spaces the filter space
gfCreateFilter       ----- creates a normalized 2D Gabor filter in the spatial domain.    
gfFilterFolder       ----- applies gabor filter on images listed in a file
gfFilterImage        ----- filters an image by a filter created with gfCreateFilter
gfFilterImages       ----- applies filters on multiple images
gf240                ----- a script that processes 240 faces with gabor fitering and PCA
pca                  ----- a pca function

COMMENTS

The most convenient way to run gabor filters on a set of images is to use the function gfFilterFolder. 
It will take filter parameters (number of orientations ans scales), and generate gabor responses for these 
filters. It will call other support files automatically.

PS. The paths in gf240 may need to be changed.