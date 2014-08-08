## This file is for running LDA on a corpus of patent abstracts
## obtained from the USPTO. 
## Thanks to Drew Blount for his XMLParser.  
## 

require(Rcpp)

# Load functions into workspace
source("gibbs_prep.R")
source("gibbs_output.R")
sourceCpp("gibbs.cpp")

# Store the path to the reuters001 corpus as a string. 
path_to_patents <- "/Users/jacobmenick/Desktop/Summer_2014_Research/r_scripts/LdaGibbs/text_corpuses/patents_jan07"

# Get corpus and dtm.
corpusPATENTS <- get_corpus(path_to_patents)
corpusPATENTS <- sample(corpusPATENTS, 1000)
dtmPATENTS <- get_dtm(corpusPATENTS)
vocabPATENTS <- colnames(dtmPATENTS)

# Remove stopwords.
# The words 'title' and 'abstract' appear in each file.  
stop.words <- c("title", "abstract")
new_objs <- remove.stopwords(dtmPATENTS, vocabPATENTS, stop.words)
dtmPATENTS <- new_objs[[1]]
vocabPATENTS <- new_objs[[2]]

# Set Parameters for the LDA Model
nsim <- 25
K <- 30
alpha <- 50/K
beta <- 0.01

# Run the LDA code from the 'topicmodels' package. 
paramsPATENTS <- gibbsC(dtmPATENTS, nsim, K, alpha, beta, verbose=F)

# Let's visualize the results by making plots. 
df <- get_plottable_df(corpusPATENTS, dtmPATENTS, colnames(dtmPATENTS), paramsPATENTS, 10)

plot <- get_primitive_qplot(df, 10)
print(plot)
