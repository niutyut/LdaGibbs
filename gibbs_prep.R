# Get a directory of .txt files ready for analysis with LDA. 
require("tm")
require("SnowballC")

# Give this function a path to the directory containing your .txt file documents.  
get_corpus <- function(path) {
  old_directory <- getwd()
  new_directory <- as.character(path) # Making sure it's a string
  setwd(new_directory)
  corpus <- Corpus(DirSource(getwd()), readerControl = list(language="english"))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
#  corpus <- tm_map(corpus, stemDocument, language="english")
  corpus
}

# Given a corpus object defined by the tm package, get a "vocab" of the format accepted by the LDA package. 

get_vocabObj <- function(corpus) {
  dtm <- DocumentTermMatrix(corpus)
  dtm_matrix <- as.matrix(inspect(dtm))
  vocab <- colnames(dtm_matrix)
  vocab
}

# Get a dtm as an R matrix given a corpus. 
get_dtm <- function(corpus) {
  dtm <- DocumentTermMatrix(corpus)
  dtm_matrix <- as.matrix(dtm)
  dtm_matrix 
}


# Get a tm 'corpus' object from a dtm (with vocab terms attached
#     to column names.)
dtm_to_corpus <- function(dtm) {
  dtm2list <- apply(dtm, 1, function(x) {
    paste(rep(names(x), x), collapse = ' ')
  })
  corp <- VCorpus(VectorSource(dtm2list))
  corp
}

# Process a manually created corpus as if we imported it with get_corpus
process_corpus <- function(corpus) {
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
#  corpus <- tm_map(corpus, stemDocument, language="english")
  corpus
}

stem_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stemDocument, language = "english")
  corpus
}


remove.stopwords <- function(dtm, vocab, stop.words) {
  stop.word.indices <- rep(0, length(stop.words))
  for (i in 1:length(stop.words)) {
    stop.word.indices[i] <- which(vocab == stop.words[i])
  }
  keepers <- setdiff(1:length(vocab), stop.word.indices)
  vocab <- vocab[keepers]
  dtm <- dtm[,keepers]
  output <- list(dtm, vocab)
  output
}

stemmify <- function(dtm, vocab) {

  stemmed.vocab <- stemDocument(vocab, language="english")
  first.unique.indices <- seq_along(stemmed.vocab)[!duplicated(stemmed.vocab)]
  for (master.index in first.unique.indices) {
    other.matches <- which(stemmed.vocab == stemmed.vocab[master.index])
    if (length(other.matches) > 1) {
      to.reduce <- other.matches[-1]
      for (index in to.reduce) {
        dtm[, master.index] <- dtm[, master.index] + dtm[, index]
      }
    }
  }
  stemmed.vocab <- stemmed.vocab[first.unique.indices]
  dtm <- dtm[,first.unique.indices]
  new_corpus_objects <- list(dtm, stemmed.vocab)
  new_corpus_objects
}

inspect.frequent.words <- function(dtm, vocab, how.many) {
  M <- dim(dtm)[1]
  V <- dim(dtm)[2]
  total.word.counts <- rep(0,V)
  for (m in 1:M) {
    for (t in 1:V) {
      total.word.counts[t] <- total.word.counts[t] + dtm[m,t]
    }
  }		       
  
  top.word.indices <- order(total.word.counts, decreasing = T)[1:how.many]
  most.common <- vocab[top.word.indices]
  most.common
}



get_doc_keys <- function(corpus) {
    dtm <- DocumentTermMatrix(corpus)
    dtm_matrix <- as.matrix(dtm)
    doc_order <- names(dtm_matrix[,1])
    doc_order
}

doc_index_to_filename <- function(corpus, index) {
    doc_keys <- get_doc_keys(corpus)
    filename = doc_keys[index]
    filename
}

get_filenames_from_indices <- function(corpus, indices) {
    doc_keys <- get_doc_keys(corpus)
    filenames <- doc_keys[indices]
    filenames
}

#get_bag_of_words(dtm, document) {
#}

lda_corpus_to_dtm <- function(docs, vocab) {
  # Convert a document and vocab set from the lda package
  # to a 'dtm' for use with my implementation of the gibbs sampler.

  M <- length(docs)
  V <- length(vocab)
  dtm <- matrix(rep(0, M*V), nrow = M, ncol = V)
  
  for (m in 1:M) {
  	row <- rep(0,V)
  	indices <- docs[[m]][1,] + 1
  	row[indices] <- docs[[m]][2,]
  	dtm[m, ] <- row
  }
  colnames(dtm) <- vocab
  dtm
} 