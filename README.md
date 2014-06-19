# LdaGibbs

Implementation of a collapsed Gibbs sampler for LDA.  

## Organization

The collapsed gibbs sampler lives in the Gibbs.R file. 
gibbs_prep.R includes utilities for preparing a directory of text files 
for analysis as a corpus.  

It also has some utilities for running the algorithm on a text corpus of the format given in the CRAN lda package.

The gibbs_output.R file contains functions for reasoning about the output from the collapsed gibbs sampler in Gibbs.R. 

## TODO

* The collapsed gibbs sampler runs very slowly.  
* It also may have some errors because the word distributions weren't super intuitive.
* Maybe we should work with logs as in the Met-Hastings code.  
* Write some functions that plot the output with ggplot2. 
* Put in a gitignore. 



