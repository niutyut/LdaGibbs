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
source("gibbs_output.R")
sourceCpp("gibbs.cpp")
sourceCpp("evaluation.cpp")

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

stop.words <- c("paper", "papers", "results", "show", "methods", "method")
new_obj <- remove.stopwords(dtmCORA, cora.vocab, stop.words)
dtmCORA <- new_obj[[1]]
cora.vocab <- new_obj[[2]]



# Remove some stop words. Blei mentioned in a video that they did this as well.  
# stop.words <- c("paper", "result", "model", "show", "method", "approach", "base", 
#                "data", "general", "function", "perform", "comput", "present")

# new_corpus_objects <- remove.stopwords(dtmCORA, cora.vocab, stop.words)
# dtmCORA <- new_corpus_objects[[1]]
# cora.vocab <- new_corpus_objects[[2]]

		
# Set Parameters for the Gibbs Sampler, 
n.sim <- 25
alpha <- 0.1
beta <- 0.01

K1 <- 1
K2 <- 3
K3 <- 5
K4 <- 10
K5 <- 20
K6 <- 30

# Run Gibbs Sampler and store results in the variable 'paramsCORA'
params1 <- gibbsC(dtmCORA, n.sim, K1, alpha, beta)
params2 <- gibbsC(dtmCORA, n.sim, K2, alpha, beta)
params3 <- gibbsC(dtmCORA, n.sim, K3, alpha, beta)
params4 <- gibbsC(dtmCORA, n.sim, K4, alpha, beta)
params5 <- gibbsC(dtmCORA, n.sim, K5, alpha, beta)
params6 <- gibbsC(dtmCORA, n.sim, K6, alpha, beta)
phi1 <- params1[[1]]
phi2 <- params2[[1]]
phi3 <- params3[[1]]
phi4 <- params4[[1]]
phi5 <- params5[[1]]
phi6 <- params6[[1]]

jMetric(phi1, K1)
jMetric(phi2, K2)
jMetric(phi3, K3)
jMetric(phi4, K4)
jMetric(phi5, K5)
jMetric(phi6, K6)


numDocs <- 10
df1 <- get_plottable_df_lda(dtmCORA, cora.vocab, params1, numDocs)
df2 <- get_plottable_df_lda(dtmCORA, cora.vocab, params2, numDocs)
df3 <- get_plottable_df_lda(dtmCORA, cora.vocab, params3, numDocs)
df4 <- get_plottable_df_lda(dtmCORA, cora.vocab, params4, numDocs)
df5 <- get_plottable_df_lda(dtmCORA, cora.vocab, params5, numDocs)
df6 <- get_plottable_df_lda(dtmCORA, cora.vocab, params6, numDocs)

plot1 <- get_primitive_qplot(df1, numDocs)
plot2 <- get_primitive_qplot(df2, numDocs)
plot3 <- get_primitive_qplot(df3, numDocs)
plot4 <- get_primitive_qplot(df4, numDocs)
plot5 <- get_primitive_qplot(df5, numDocs)
plot6 <- get_primitive_qplot(df6, numDocs)

