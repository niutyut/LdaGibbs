## This file runs the analysis on the 'cora' corpus from the CRAN lda package.  
## 1.  We hope to achieve similar results as 
##     their demo so as test whether or not his implementation of 
##     the Gibbs sampler is correct. 
##
## 2.  It assumes our current directory is the root of this project.  
##     We use the same parameters as are used in the demo(lda) script. 
##
## 3.  You may want to try a few runs with different seeds.  
##     Because the Gibbs sampler is non-deterministic, 
##     And we are doing a relatively samll number of iterations,
##     The initial state of the Markov Chain can have big effects on 
##     the output.  

require(Rcpp)

# Load functions into workspace
source("gibbs_prep.R")
sourceCpp("gibbs.cpp")
source("gibbs_output.R")

# Load cora dataset into the workspace. 
library(lda)
data(cora.documents)
data(cora.vocab)

# Get the dtm for cora. 
dtmCORA <- lda_corpus_to_dtm(cora.documents, cora.vocab)

# Convert the dtm to a tm 'corpus' for pre-processing. 
corpusCORA <- dtm_to_corpus(dtmCORA)
corpusCORA <- process_corpus(corpusCORA)
# corpusCORA <- stem_corpus(corpusCORA)

# Convert back to a dtm.  
dtmCORA <- get_dtm(corpusCORA)
cora.vocab <- colnames(dtmCORA)


# Remove some stop words. Blei mentioned in a video that they did this as well.  
# stop.words <- c("paper", "result", "model", "show", "method", "approach", "base", 
#                "data", "general", "function", "perform", "comput", "present")

# new_corpus_objects <- remove.stopwords(dtmCORA, cora.vocab, stop.words)
# dtmCORA <- new_corpus_objects[[1]]
# cora.vocab <- new_corpus_objects[[2]]

		
# Set Parameters for the Gibbs Sampler, 
n.sim <- 25
K <- 10
alpha <- 0.1
beta <- 0.1

# Run Gibbs Sampler and store results in the variable 'paramsCORA'
paramsCORA <- gibbsC(dtmCORA, n.sim, K, alpha, beta)

# Now let's visualize the results of the model fit with ggplot2. 

numDocs <- 10

# Get a melted dataframe
df <- get_plottable_df_lda(dtmCORA, cora.vocab, paramsCORA, numDocs)

# Plot the results. 
plot <- get_primitive_qplot(df, numDocs)
print(plot)

