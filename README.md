# LdaGibbs

Implementation of a collapsed Gibbs sampler for LDA.  

## Organization

The collapsed gibbs sampler lives in the Gibbs.R file. 
gibbs_prep.R includes utilities for preparing a directory of text files 
for analysis as a corpus.  

It also has some utilities for running the algorithm on a text corpus of the format given in the CRAN lda package.

The gibbs_output.R file contains functions for reasoning about the output from the collapsed gibbs sampler in Gibbs.R. 


## Todo


* The collapsed gibbs sampler runs very slowly.  More on this later. 
* It also may have some errors because the word distributions weren't super intuitive.
* Maybe we should work with logs as in the Met-Hastings code.  
* Write some functions that plot the output with ggplot2. 
* Put in a gitignore. 


## Use

cd into the home directory for this project, and import the functions.  

```R
source("gibbs_prep.R")
source("Gibbs.R")
source("gibbs_output.R")
```

Now we need to get whatever corpus we have into a Document-Term-Matrix. 
If that corpus is organized as a directory, where documents are individual text files, you're in luck.  Simply provide the get_corpus() function in gibbs_prep with the path to that directory, and you will receive a corpus object.  Then pass that corpus object to the get_dtm_matrix() function, and you've got a dtm that's ready to roll with LDA.  

```R
corpus <- get_corpus(path)
dtm <- get_dtm_matrix(corpus)
```

Alternatively, we can use data from the CRAN lda package, using the helper functions that convert these objects into a tdm usable by this gibbs sampler. We can do that as follows: 

``` R
library(lda)
data(cora.documents)
data(cora.vocab)
dtmCORA <- lda_corpus_to_dtm(cora.documents, cora.vocab)
```

You've just got to choose your parameters and pass them to the gibbs.sampler.lda() function, as follows: 

```R
K <- 10  # number of topics. 
alpha <- 50/K  # Heuristic suggested in Heinrich Paper. 
beta <- 0.01 # same comment as above.
n.sim <- 25 # This implementation is REAL slow.  Let's start small.   

params_est <- gibbs.sampler.lda(dtm, 25, K, alpha, beta) # Meat and Cheese. Runs Gibbs.

```

*params_est* now holds the parameter estimates for the topic-word multinomial distributions and the document-topic mixture proportions.  See Gibbs.R for more detail on that. 

Note: alpha is a K-dimensional vector, the parameter for the dirichlet prior on theta. If we pass *gibbs.sampler.lda* a scalar rather than a K-vector, it assumes that the distribution is symmetric.  Same for beta, except in V dimensions, the length of the vocabulary. 

We can make sense of this output with the helper functions in gibbs_output.R.  For instance, let's look at the topic mixtures for document 1, and then let's look at the most probable words for each topic. 



```R
doc1_mix <- get_mixture_proportions(params_est, 1)

top.topic.words <- get_top_k_words(dtm, get_vocabObj(dtm), params_est, 5, 1:K)
top.topic.words
```

Todo: Write utilities that display these results in ggplot2.  


## Sanity Check

Unfortunately, I'm not capable of sanity checking the CORA corpus from the CRAN lda package.  We can, however, sanity check corpuses of our own of the first type mentioned in the docs, i.e. a corpus that is a directory containing .txt files which represent individual documents.  

This is pretty janky, but it does the trick.  We can figure out which row index of the dtm (and therefore, the output parameters) corresponds to which document (by filename) with the following helper functions, from gibbs_prep.R: 

```R
keys <- get_doc_keys(corpus) # This returns a vector s.t. keys[i] is the filename of document i.  We can sanity check by going into the .txt file and making sure that the wordsfrom the topic assignments do indeed appear frequently.  

```

## Runtime of Gibbs. 

The runtime of this Gibbs sampler is O(n.sim*M*V*K), where 
* M is the number of documents
* V is the number of words in the vocabulary
* K is the number of topics.  
* n.sim is the number of iterations of MCMC.  

This is due to the triply nested for loop (over n.sim, M, and V) in Gibbs.R, and the fact that *sample.from.conditional()* has a for loop that runs K times.  

This may well be extremely inefficient, even as far as Gibbs samplers are concerned, which have a reputation for being slower than other approximate inference methods.  A paper from Blei at all shows that Variational Bayes is faster, and Online Variational Bayes is faster still.  Will footnote these soon. 
