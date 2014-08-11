# Tests functionality for building corpus from another corpus.
# We wish to use this to create corpuses buily from highly topical
# subsets of another corpus. 
# Again, we will use the CORA corpus
# as a case study for this method. 

#import relevant libraries.
require(Rcpp)
require(lda)
source("gibbs_prep.R")
sourceCpp("gibbs.cpp")
source("dev.R")

# grab CORA corpus and Process. 
library(lda)
data(cora.documents)
data(cora.vocab)
dtmCORA <- lda_corpus_to_dtm(cora.documents, cora.vocab)
corpusCORA <- dtm_to_corpus(dtmCORA)
corpusCORA <- process_corpus(corpusCORA)
dtmCORA <- get_dtm(corpusCORA)
cora.vocab <- colnames(dtmCORA)

# Fit an LDA model on the whole dataset. 
nsim <- 40
K <- 10
alpha <- 0.01
beta <- 0.01
paramsCORA <- gibbsC(dtmCORA, nsim, K, alpha, beta)
phi <- paramsCORA[[1]]

# Visualize this model.  
full.df <- get_plottable_df_lda(dtmCORA, colnames(dtmCORA), paramsCORA, 10)
full.plot <- get_primitive_qplot(full.df, 10)
full.plot

# Make a new corpus with one topic, sample randomly from the old corpus. 
newCorp <- build.K.Topic.Corpus(dtmCORA, paramsCORA, K, 1, .3)
newCorp <- newCorp[,-ncol(newCorp)]
class(newCorp) <- "numeric"

# Fit LDA on this new corpus, choosing 1, 2, 5, 10, and 20 topics.
one.topic.params <- gibbsC(newCorp, nsim, 1, 50/1, beta)
two.topic.params <- gibbsC(newCorp, nsim, 2, 50/2, beta)
five.topic.params <- gibbsC(newCorp, nsim, 5, 50/5, beta)
ten.topic.params <- gibbsC(newCorp, nsim, 10, 50/10, beta)
twty.topic.params <- gibbsC(newCorp, nsim, 20, 50/20, beta)





