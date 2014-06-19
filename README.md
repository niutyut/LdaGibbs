# LdaGibbs

Implementation of a collapsed Gibbs sampler for LDA.  

## Organization

The collapsed gibbs sampler lives in the Gibbs.R file. 
gibbs_prep.R includes utilities for preparing a directory of text files 
for analysis as a corpus.  

It also has some utilities for running the algorithm on a text corpus of the format given in the CRAN lda package.

The gibbs_output.R file contains functions for reasoning about the output from the collapsed gibbs sampler in Gibbs.R. 


## Todo


* The collapsed gibbs sampler runs very slowly.  
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
If that corpus is organized as a directory, where documents are individual text files, you're in luck.  Simply provide the get_corpus() function in gibbs_prep with the path to that directory, and you will receive a corpus object.  Then pass that corpus object to the get_dtm_matrix() function, and you've got a dtm that's ready to roll with LDA.  You've just got to choose your parameters and pass them to the gibbs.sampler.lda() function, as follows: 

```R
corpus <- get_corpus(path)
dtm <- get_dtm_matrix(corpus)
K <- 10  # number of topics. 
alpha <- 50/K  # Heuristic suggested in Heinrich Paper. 
beta <- 0.01 # same comment as above.
n.sim <- 25 # This implementation is REAL slow.  Let's start small.   

params_est <- gibbs.sampler.lda(dtm, 25, K, alpha, beta) # Meat and Cheese. Runs Gibbs.

```

*params_est* now holds the parameter estimates for the topic-word multinomial distributions and the document-topic mixture proportions.  See Gibbs.R for more detail on that. 

We can make sense of this output with the helper functions in gibbs_output.R.  For instance, let's look at the topic mixtures for document 1, and then let's look at the most probable words for each topic. 

```R
doc1_mix <- get_mixture_proportions(params_est, 1)

top.topic.words <- get_top_k_words(dtm, get_vocabObj(dtm), params_est, 5, 1:K)
top.topic.words
```