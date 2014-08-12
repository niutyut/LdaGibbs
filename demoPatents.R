## This file is for running LDA on a corpus of patent abstracts
## obtained from the USPTO. 
## Thanks be to Drew Blount for his XMLParser.  

## Be sure before running this script that the current working directory 
## in R is the directory containing this file. 
home <- getwd()
require(Rcpp)

# Load functions into workspace
source("gibbs_prep.R")
source("gibbs_output.R")
sourceCpp("gibbs.cpp")

# Store the path to the corpus as a string. 
path_to_patents <- paste(home,"text_corpuses/patents_jan07", sep="/")

# Get corpus and dtm from .txt files
corpusPATENTS <- get_corpus(path_to_patents)
corpusPATENTS <- sample(corpusPATENTS, 500)
dtmPATENTS <- get_dtm(corpusPATENTS)
vocabPATENTS <- colnames(dtmPATENTS)

# Remove additional stopwords.  
stop.words <- c("title", "abstract", "method", "apparatus", "include", "includes", "provided", "methods", "present", "system", "based", "device", "invention", "providing", "disposed", "end", "thereof", "lower", "upper")
new_objs <- remove.stopwords(dtmPATENTS, vocabPATENTS, stop.words)
dtmPATENTS <- new_objs[[1]]
vocabPATENTS <- new_objs[[2]]

# Set Parameters for the LDA Model
nsim <- 40
alpha <- 0.01
beta <- 0.01

# This is not the optimal setting for K for this corpus 
# But I've set it to 20 in the interest of a quick demo.
# A better setting would probably be 50 to 100 topics. 
K <- 20

# Fit the LDA model.  
paramsPATENTS <- gibbsC(dtmPATENTS, nsim, K, alpha, beta, verbose=F)

# Visualize the results for a random sample of ten documents
numDocs <- 10  
df <- get_plottable_df(corpusPATENTS, dtmPATENTS, vocabPATENTS, paramsPATENTS, numDocs)
plot <- get.qplot(df, numDocs)
plot

# We can save the topics as a matrix so that we can output to csv. 
numTerms <- 5
topicsMat <- getTopicOutputMatrix(vocabPATENTS, paramsPATENTS, numTerms)

setwd(home)
# To write the output to csv, uncomment the next line and designate
# a destination directory.  
# write.table(topicsMat, paste(getwd(), "yourDirectory/test.csv", sep="/"), col.names = F)

