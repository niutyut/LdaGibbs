## This file is for running LDA on a corpus of patent abstracts
## obtained from the USPTO. 
## Thanks to Drew Blount for his XMLParser.  
## 
home <- getwd()
require(Rcpp)

# Load functions into workspace
source("gibbs_prep.R")
source("gibbs_output.R")
sourceCpp("gibbs.cpp")
sourceCpp("evaluation.cpp")

# Store the path to the reuters001 corpus as a string. 
path_to_patents <- paste(getwd(),"text_corpuses/patents_jan07", sep="/")

# Get corpus and dtm.
corpusPATENTS <- get_corpus(path_to_patents)
corpusPATENTS <- sample(corpusPATENTS, 500)
dtmPATENTS <- get_dtm(corpusPATENTS)
vocabPATENTS <- colnames(dtmPATENTS)

# Remove stopwords.
# Here are some really uninformative words in this corpus. 
stop.words <- c("title", "abstract", "method", "apparatus", "include", "includes", "provided", "methods", "present", "system", "based", "device", "invention", "providing", "disposed", "end", "high", "including", "comprise", "comprises", "comprising", "formed", "form", "made", "plurality", "part", "portion", "plurality", "unit", "andor", "relates", "thereof", "set", "provide", "provides", "attached", "attach", "substantially", "defining", "define", "defines")
new_objs <- remove.stopwords(dtmPATENTS, vocabPATENTS, stop.words)
dtmPATENTS <- new_objs[[1]]
vocabPATENTS <- new_objs[[2]]

# Set Parameters for the LDA Model
nsim <- 40
alpha <- 0.01
beta <- 0.01

K0 <- 5
K1 <- 20
K2 <- 50
K3 <- 100
K4 <- 200


# Run the LDA code from the 'topicmodels' package. 
paramsPATENTS0 <- gibbsC(dtmPATENTS, nsim, K0, alpha, beta, verbose=F)
paramsPATENTS1 <- gibbsC(dtmPATENTS, nsim, K1, alpha, beta, verbose=F)
paramsPATENTS2 <- gibbsC(dtmPATENTS, nsim, K2, alpha, beta, verbose=F)
paramsPATENTS3 <- gibbsC(dtmPATENTS, nsim, K3, alpha, beta, verbose=F)
paramsPATENTS4 <- gibbsC(dtmPATENTS, nsim, K4, alpha, beta, verbose=F)

# Let's visualize the results by making topic matrices 
numTerms <- 5
topics0 <- getTopicOutputMatrix(vocabPATENTS, paramsPATENTS0, numTerms)
topics1 <- getTopicOutputMatrix(vocabPATENTS, paramsPATENTS1, numTerms)
topics2 <- getTopicOutputMatrix(vocabPATENTS, paramsPATENTS2, numTerms)
topics3 <- getTopicOutputMatrix(vocabPATENTS, paramsPATENTS3, numTerms)
topics4 <- getTopicOutputMatrix(vocabPATENTS, paramsPATENTS4, numTerms)

# Get a ggplot of the results 
numDocs <- 10  
df <- get_plottable_df(corpusPATENTS, dtmPATENTS, vocabPATENTS, paramsPATENTS1, numDocs)
plot <- get.qplot(df, numDocs)

# Test the metric with both weights set to one. 
jMetric(phi0, K0)
jMetric(phi1, K1)
jMetric(phi2, K2)
jMetric(phi3, K3)
jMetric(phi4, K4)


