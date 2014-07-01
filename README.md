# LdaGibbs

R Implementation of a collapsed Gibbs sampler for approximate inference in the Latent Dirichlet Allocation (LDA) model [1]. LDA is a topic modeling algorithm for a corpus of text datasets.  Includes interface for preprocessing data and 'post-processing' the output of the algorithm (visualization, etc.)

## Todo

* The collapsed gibbs sampler runs very slowly.  More on this later. 
* It also may have some errors because the word distributions weren't super intuitive.
* Maybe we should work with logs as in the Met-Hastings code.  

## Use

You can see a full demo in the file *reuters_analysis.R*.

## Runtime of Gibbs. 

The runtime of this Gibbs sampler is O(n.sim*M*V*K), where 
* M is the number of documents
* V is the number of words in the vocabulary
* K is the number of topics.  
* n.sim is the number of iterations of MCMC.  

This is due to the triply nested for loop (over n.sim, M, and V) in Gibbs.R, and the fact that *sample.from.conditional()* has a for loop that runs K times.  

This may well be extremely inefficient, even as far as Gibbs samplers are concerned, which have a reputation for being slower than other approximate inference methods.  A paper from Blei et.al [3] shows that Variational Bayes is faster, and Online Variational Bayes is faster still. 

Regardless, there is work to do in this implementation, as far as optimizing speed is concerned.  Looking into Rcpp.  

[1] http://machinelearning.wustl.edu/mlpapers/paper_files/BleiNJ03.pdf

[2] http://faculty.cs.byu.edu/~ringger/CS601R/papers/Heinrich-GibbsLDA.pdf

[3] https://www.cs.princeton.edu/~blei/papers/HoffmanBleiBach2010b.pdf