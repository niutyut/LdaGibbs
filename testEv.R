# tests evaluation functionality. 
# Assumes we are in the home directory of the project. 


#import required libraries
require(Rcpp)
require(lda)
source("gibbs_prep.R")
sourceCpp("gibbs.cpp")
sourceCpp("evaluation.cpp")

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
nsim <- 25
K <- 10
alpha <- K / 50
beta <- 0.01
paramsCORA <- gibbsC(dtmCORA, nsim, K, alpha, beta)
phi <- paramsCORA[[1]]

# Run evaluation metrics. 
numSamples <- 10
perp <- perplexityC(dtmCORA, alpha, phi, numSamples)[[1]]
phiSimi <- MatSimi(phi)
phiEntro <- MatEntropy(phi)

# Initial proposed Metric: mkScore(wish to minimize):
mkScore <- phiEntro + phiSimi + perplexity/log(K) + K



