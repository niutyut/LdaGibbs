# LdaGibbs

R Implementation of a collapsed Gibbs sampler for approximate inference in the Latent Dirichlet Allocation (LDA) model [1]. Parameter estimation is done in C++ for faster inference, interfacing with R via Rcpp [2]. LDA is a topic modeling algorithm for a corpus of text datasets.  Includes interface for preprocessing data and 'post-processing' the output of the algorithm (visualization, etc.)

## TODO

* Clean up the pre-processing and output code for streamlined use.
* Think up new ways to present the results. 
* Implement Online Variational Learning [3].

## Depends

* Rcpp - for interface to C++ code
* tm - for preprocessing
* SnowballC - for stemming (in pre-processing). 
* reshape and ggplot2 - for visualizing output.  

## Use

You can see a full demo in the file *reuters_analysis.R*.

## References

[1] http://machinelearning.wustl.edu/mlpapers/paper_files/BleiNJ03.pdf

[2] http://cran.r-project.org/web/packages/Rcpp/index.html

[3] https://www.cs.princeton.edu/~blei/papers/HoffmanBleiBach2010b.pdf