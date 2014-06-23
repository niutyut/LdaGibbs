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

require(ggplot2)
require(reshape)

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

get_plottable_df <- function(params, numdocs) {

  theta <- params[[2]]
  M <- dim(theta)[1]
  K <- dim(theta)[2]
  colnames(theta) <- paste("topic", seq(1:K))

  random_doc_indices <- sample(1:M, numdocs)
  theta.sample <- theta[random_doc_indices,]
  
  theta.sample.m <- melt(theta.sample)
  theta.sample.m.df <- data.frame(theta.sample.m)
  names(theta.sample.m.df) <- c("Document", "Topic", "Proportion")
  output <- list(theta.sample.m.df, random_doc_indices)
  names(output) <- c("Theta.Sample.M.DF", "Random Doc Indices")
  output

}

get_primitive_qplot <- function(df, numdocs) {
  # TODO - put top.topic.words on plot labels.  

  plot <- qplot(Topic, Proportion, fill=factor(Document), data = df, geom="bar") + 
          coord_flip() + facet_wrap( ~ Document, ncol = numdocs/2)

  plot
		    
}