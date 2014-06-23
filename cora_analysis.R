## This file runs the analysis on the 'cora' corpus from the CRAN lda package.  
## We hope to achieve similar results as their demo so as test whether or not 
## this implementation of the Gibbs sampler is correct. 
##
## It assumes our current directory is the root of this project.  
## We use the same parameters as are used in the demo(lda) script. 

# Load functions into workspace
source("gibbs_prep.R")
source("Gibbs.R")
source("gibbs_output.R")

# Load cora dataset into the workspace. 
library(lda)
data(cora.documents)
data(cora.vocab)

# Get the dtm for cora. 
dtmCORA <- lda_corpus_to_dtm(cora.documents, cora.vocab)

# Set Parameters for the Gibbs Sampler, 
n.sim <- 25
K <- 10
alpha <- 0.1
beta <- 0.1

# Run Gibbs Sampler and store results in the variable 'paramsCORA'
paramsCORA <- gibbs.sampler.lda(dtmCORA, n.sim, K, alpha, beta)

# Let's get the top 5 words for each topic.  
# let's store them in a Kxk matrix where rows correspond to topics. 
k <- 5
top_5_words <- matrix(rep(0, k*K), nrow = K, ncol = k)

for (i in 1:K) {
  top_5_words[i, ] <- get_top_k_words(dtmCORA, cora.vocab, paramsCORA, k, i)
}

top_5_words
