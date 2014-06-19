## This file has some functions that you should use with the output
## from the gibbs sampler given in Gibbs.R
##
## The output is the list (Phi, Theta).
## Phi is a K*V matrix whose kth row 
##   is a vector of multinomial parameters for topic k. 
##
##   I.e. the (k-v)th entry of Phi is the probability that a word is v
##   given the topic is k. 
##
## Theta is a M*K matrix whose mth row 
##   is a vector giving the topic mixture proportions for document m.   

source("gibbs_prep.R")

get_mixture_proportions <- function(params, doc_index) {
  theta <- params[[2]]
  mixture_props <- theta[doc_index, ]
  mixture_props
}

get_top_k_words <- function(dtm, vocab, params, top_k, topic_index) {
  # given a dtm, gibbs output, and a topic index, 
  # get the top k words in the topic, as strings. 
		
  phi <- params[[1]]
  word.probs <- phi[topic_index,]
  ord <- order(word.probs, decreasing = T)
  top_k_indices <- ord[1:top_k]
  top_k_words <- vocab[top_k_indices]
  top_k_words
}

sample_doc_indices <- function(corpus, n) {
    # n is the number of document indices to sample
		   
    dtm_matrix <- get_dtm_matrix(corpus)
    num_docs <- nrow(dtm_matrix)
    pool <- 1:num_docs
    indices <- sample(pool, n, rep=F)
}