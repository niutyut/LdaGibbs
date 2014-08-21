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
require(reshape2)

source("gibbs_prep.R")

get_top_k_words <- function(vocab, params, top_k, topic_index) {
  # given a dtm, gibbs output, and a topic index, 
  # get the top k words in the topic, as strings. 
		
  phi <- params[[1]]
  word.probs <- phi[topic_index,]
  ord <- order(word.probs, decreasing = T)
  top_k_indices <- ord[1:top_k]
  top_k_words <- vocab[top_k_indices]
  top_k_words
}

# Result is a matrix. 
getTopicOutputMatrix <- function(vocab, params, numTerms) {
    phi <- params[[1]]
    K <- nrow(phi)
    out <- 0
    for (i in 1:K) {
        indices <- order(phi[i,], decreasing = T)[1:numTerms]
        words <- vocab[indices]
        if (i == 1) {
            out <- words
        }
        else {
            out <- rbind(out, words)
        }
    }
    rownames(out) <- paste(rep("topic ", K), seq(1, K), rep(": ", K))
    out
}

writeMatToCSV <- function(matrix, path, filename) {
    outFileName <- paste(path, filename, sep="/")
    
}

nameFunc <- function(row, dtm) {
    names(row) <- colnames(dtm)
}

sortFunc <- function(row) {
    row <- sort(row, decreasing=T)
}

get_plottable_df_lda <- function(dtm, vocab, params, numdocs) {

  theta <- params[[2]]
  M <- dim(theta)[1]
  K <- dim(theta)[2]
  colnames <- rep(0, K)
  for (i in 1:K) {
    colnames[i] <- paste(get_top_k_words(vocab, params, 5, i), collapse=", ")
  }

  colnames(theta) <- colnames
  random_doc_indices <- sample(1:M, numdocs)
  theta.sample <- theta[random_doc_indices,]
  
  theta.sample.m <- melt(theta.sample)
  theta.sample.m.df <- data.frame(theta.sample.m)
  names(theta.sample.m.df) <- c("Document", "Topic", "Proportion")
  df <- theta.sample.m.df
  df 
}

cleanFilename <- function(text) {
    text <- sub("patent", "", text)
    text <- sub(".txt", "", text)
    text
}

get_plottable_df <- function(corpus, dtm, vocab, params, numdocs, givenIndices = 0) {
    
  theta <- params[[2]]
  M <- dim(theta)[1]
  K <- dim(theta)[2]

  # Set colnames to be top topic words
  colnames <- rep(0, K)
  for (i in 1:K) {
    colnames[i] <- paste(get_top_k_words(vocab, params, 5, i), collapse=", ")
  }

  colnames(theta) <- colnames

  # Set row names to be document filenames. 
  filenames <- get_filenames_from_indices(corpus, 1:M)
  filenames <- sapply(filenames, cleanFilename)
  filenames <- unname(filenames)
  rownames(theta) <- filenames

  
  random_doc_indices <- sample(1:M, numdocs)
  if (givenIndices == 0) {
      theta.sample <- theta[random_doc_indices,]
  }
  else {
      theta.sample <- theta[givenIndices,]
  }
  
  theta.sample.m <- melt(theta.sample)
  theta.sample.m.df <- data.frame(theta.sample.m)
  names(theta.sample.m.df) <- c("Document", "Topic", "Proportion")
  df <- theta.sample.m.df
  df
}

# Would like to have the word appear in the bag according to count.  
getBagOfWords <- function(dtm, doc) {
    out <- 0
    vocab <- colnames(dtm)
    wordIndices <- which(dtm[doc,] > 0)
    words <- vocab[wordIndices]
    for (i in 1:length(words)) {
        addition <- rep(words[i], dtm[doc, wordIndices[i]])
        if (length(out) == 1 && out == 0) {
            out <- addition
        }
        else {
            out <- append(out, addition)
        }
    }
    out
}

queryByTopicStrength <- function(params, dtm, topic, strength) {
    # theta is M*K
    theta <- params[[2]]
    indices <- which(theta[,topic] > strength)
    # return indices of dtm for which topic exceeds strength.
    indices
}

get.qplot <- function(df, numdocs) {
  plot <- qplot(Topic, Proportion, fill=rev(factor(Topic)), data = df, geom="bar",stat="identity") + 
          theme(axis.text.y = element_blank()) +
          coord_flip() + facet_wrap( ~ Document, ncol = numdocs/2)

  plot
}
