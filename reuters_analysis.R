## This file runs the analysis on the reuters001 corpus.  
## It assumes our current directory is the root of this project.  

# Load functions into workspace
source("gibbs_prep.R")
source("Gibbs.R")
source("gibbs_output.R")

# Store the path to the reuters001 corpus as a string. 
path_to_reuters001 <- "text_corpuses/reuters001"

# Get corpus and dtm.
reuters001 <- get_corpus(path_to_reuters001)
dtm001 <- get_dtm_matrix(reuters001)

# Get vocabulary object. 
vocab001 <- get_vocabObj(reuters001)

# Set Parameters for the Gibbs Sampler
n.sim <- 25
K <- 10
alpha <- 50/K
beta <- 0.01

# Run Gibbs Sampler and store results in the variable 'params001'
params001 <- gibbs.sampler.lda(dtm001, n.sim, K, alpha, beta)

# Let's get the top 5 words for each topic.  
# let's store them in a Kxk matrix where rows correspond to topics. 
k <- 5
top_5_words <- matrix(rep(0, k*K), nrow = K, ncol = k)

for (i in 1:K) {
  top_5_words[i, ] <- get_top_k_words(dtm001, vocab001, params001, k, i)
}

top_5_words
