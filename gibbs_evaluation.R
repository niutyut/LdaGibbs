# The utilities provided by this file are for evaluating topic models' performance. .
# We will provide implementations of different model comparison metrics.
# It may be best to implement this in c++ as well. 

require(gtools)

# Get dtc, ttc from 'ta', the M * V topic assignments matrix.
# K is the number of topics in the topic model.
taToCounts <- function(ta, K) {
    M <- nrow(ta)
    V <- ncol(ta)
    
    # dtc is "document-topic counts", a M x K matrix.
    dtc <- matrix(rep(0, M*K),nrow = M,ncol = K)
    # ttc is "topic-term-counts", a K x V matrix.
    ttc <- matrix(rep(0, K*V),nrow = K,ncol = V)

    for (m in 1:M) {
        for (t in 1:V) {
            # Entries of 'ta' are topics k in [1,K]
            z <- ta[m, t]
            # Increment count of topic 'z' in document 'm'
            # Increment count of term 't' in topic 'z'.
            dtc[m, z] = dtc[m, z] + 1;
            ttc[z, t] = ttc[z, t] + 1;
        }
    }
    
    out <- list(dtc, ttc)
    names(out) <- c("Doc-Topic-Counts", "Topic-Term-Counts")
    out
}

getDtvfromDtm <- function(dtm, doc) {
    dtv <- dtm[doc, ]
    dtv
}

# Here 'dtv' is a "document-topic vector", representing a single document.
# We use Importance Sampling to get the likelihood of a new document.
# The likelihoods are quite small. Like, REALLY small. 
probNewDoc <- function(dtv, alpha, phi, numSamples) {
    V <- length(dtv)
    K <- nrow(phi)
    alphaVec <- rep(alpha, K)
    prob <- 0
    for (s in 1:numSamples) {
        prod <- 1
        for (n in 1:V) {
            if (dtv[n] > 0) {
                sum <- 0
                for (k in 1:K) {
                    term <- rdirichlet(1, alphaVec)[k] * phi[k,n]
                    sum <- sum + log(term)
                }
                prod <- prod * sum
            }
        } 
    prob <- prob + prod
    }
    prob <- prob/ numSamples
    prob
}

# This takes awhile. Might port it to c++.
ProbNewDocSet <- function(dtm, alpha, phi , numSamples) {
    prod <- 1
    numDocs <- nrow(dtm)
    for (d in 1:numDocs) {
        prod <- prod * probNewDoc(dtm[d,], alpha, phi, numSamples)
    }
    prod
}

    
