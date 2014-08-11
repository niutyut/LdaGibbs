# This file will hold utilities for developing new features.
# Currently, the feature we wish to develop is a model scoring
# metric with regard to the number of topics.

# I'm aware that models like the
# "Hierarchical Dirichlet process" enable the number of topics to be learned, but
# this inquiry seeks to operate within the unextended LDA model.

require(Rcpp)

source("gibbs_output.R")
sourceCpp("evaluation.cpp")

build.K.Topic.Corpus <- function(dtm, params, kOriginal, kNew, strength) {
    # kNew is the number of topics we'd like in this handpicked corpus.
    # We will randomly pick kNew topics from
    oldKs <- seq(1, kOriginal)
    newKs <- sample(oldKs, kNew, replace = F)
    newCorpus <- 0
    for (i in 1:kNew) {
        topic <- newKs[i]
        newIndices <- queryByTopicStrength(params, dtm, topic, strength)
        newRows <- dtm[newIndices, ]
        # Append original topic top.5. words as last column.
        top.words <- paste(get_top_k_words(dtm, colnames(dtm), params, 5, topic), collapse = ", ")
        tmv <- rep(top.words, nrow(newRows))
        newRows <- cbind(newRows, tmv)
        if (length(newCorpus) == 1 && newCorpus == 0) {
            newCorpus <- newRows
        }
        else {
            newCorpus <- rbind(newCorpus, newRows)
        }
    }
    # The new corpus is the subset of the old corpus, which has topic strength
    # greater than 'strength' for the random new topics (of which there are 'kNew').
    newCorpus
}

evalParams <- function(dtm, params, alpha, numSamples, K) {
    phi <- params[[1]]
    perp <- perplexityC(dtm, alpha, phi, numSamples)[[1]]
    phiSimi <- MatSimi(phi)
    phiEntro <- MatEntropy(phi)
    mkScore <- phiEntro + phiSimi + perp/log(K) + K
    mkScore
}




