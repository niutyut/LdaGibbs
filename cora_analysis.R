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

# Now let's visualize the results of the model fit with ggplot2. 

numDocs <- 10

# Get a melted dataframe
df <- get_plottable_df_lda(dtmCORA, cora.vocab, paramsCORA, numDocs)

# Plot the results. 
plot <- get_primitive_plot(df, numDocs)

