# Run the analysis on a reuters corpus. 

require(Rcpp)

# Load the functions for the package into the namespace.
source("gibbs_prep.R")
sourceCpp("devGibbs.cpp")
source("gibbs_output.R")

# Get the reuters corpus from the text files. 
path_to_reuters <- "text_corpuses/reuters001"
reuters001 <- get_corpus(path_to_reuters)
dtm001 <- get_dtm(reuters001)

# Set model parameters. 
K <- 10
alpha <- 50/K
beta <- 0.01
nsim <- 50

# Run the model to get parameter estimate for phi and theta. 
params <- gibbsC(dtm001, 1, K, alpha, beta, verbose = F)

# Plot the results with ggplot2.
df <- get_plottable_df_lda(dtm001, colnames(dtm001), params, 10)
plot <- get_primitive_qplot(df, 10)
print(plot)













