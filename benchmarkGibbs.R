# Run the analysis on a reuters corpus. 

require(Rcpp)
require(topicmodels)
require(lda)
require(microbenchmark)

# Load the functions for the package into the namespace.
source("gibbs_prep.R")
source("Gibbs.R")
sourceCpp("gibbs.cpp")
source("gibbs_output.R")

# Get the reuters corpus from the text files. 
path_to_reuters <- "text_corpuses/reuters001"
reuters001 <- get_corpus(path_to_reuters)
dtm001 <- get_dtm(reuters001)

# Set model parameters. 
K <- 10
alpha <- 10 / K
beta <- 0.01
# 10 is a good nsim. The benchmark takes about 5-10 minutes in this case. 
nsim <- 1

microbenchmark(
	gibbsC(dtm001, nsim, K, alpha, beta, verbose = F),
	get_params_from_topicmodels(dtm001, K),
	gibbs.sampler.lda(dtm001, nsim, K, alpha, beta), times = 10)
	
# Spoiler alert - gibbsC is about 35 times faster than gibbs.sampler.lda
# the topicmodels code is deterministic (via variational bayes), so the 
# nsim parameter is not relevant to its work.  Its runtime is faster than 
# a MCMC inference algorithm with an nsim of 10














