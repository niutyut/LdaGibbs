## This file runs the analysis on the reuters001 corpus.  
## It assumes our current directory is the root of this project.  
require(Rcpp)

# Load functions into workspace
source("gibbs_prep.R")
source("gibbs_output.R")
sourceCpp("gibbsC.cpp")

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
params001 <- GibbsC(dtm001, n.sim, K, alpha, beta)

# Let's visualize the results by making plots. 
df <- get_plottable_df(reuters001, dtm001, vocab001, params001, 10)

plot <- get_primitive_qplot(df, 10)
print(plot)
