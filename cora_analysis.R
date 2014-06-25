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

# Stemify the corpus. 
new_corpus_objects <- stemmify(dtmCORA, cora.vocab)
dtmCORA <- new_corpus_objects[[1]]
cora.vocab <- new_corpus_objects[[2]]

# I realize the list operations are probably counterintuitive. 
# I couldn't think of a better way to return multiple objects.
# The remove.stopwords function affects both the dtm and the vocab, though. 

# Remove some stop words. 
stop.words <- c("paper", "result", "model", "show", "method", "approach")

new_corpus_objects <- remove.stopwords(dtmCORA, cora.vocab, stop.words)
dtmCORA <- new_corpus_objects[[1]]
cora.vocab <- new_corpus_objects[[2]]

		
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
plot <- get_primitive_qplot(df, numDocs)
print(plot)

