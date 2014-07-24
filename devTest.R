require(Rcpp)

# Load functions into workspace
source("gibbs_prep.R")
sourceCpp("gibbs.cpp")
source("gibbs_output.R")
source("dev.R")
source("gibbs_evaluation.R")

# Load cora dataset into the workspace. 
library(lda)
data(cora.documents)
data(cora.vocab)

# Get the dtm for cora. 
dtmCORA <- lda_corpus_to_dtm(cora.documents, cora.vocab)

# Convert the dtm to a tm 'corpus' for pre-processing. 
corpusCORA <- dtm_to_corpus(dtmCORA)
corpusCORA <- process_corpus(corpusCORA)
# corpusCORA <- stem_corpus(corpusCORA)

# Convert back to a dtm.  
dtmCORA <- get_dtm(corpusCORA)
cora.vocab <- colnames(dtmCORA)

#Holdout a portion of the data for testing. 
split.corpus <- holdOut(dtmCORA, .2)
trainingCORA <- split.corpus[[1]]
testCORA <- split.corpus[[2]]

		
# Set Parameters for the Gibbs Sampler, 
nsim <- 25
K <- 10
alpha <- K / 50
beta <- 0.01

# Run Gibbs Sampler and store results in the variable 'paramsCORA'
paramsTrainingSet <- gibbsC(trainingCORA, nsim, K, alpha, beta)
phi <- paramsTrainingSet[[1]]

docSampled <- testCORA[sample(1:nrow(testCORA), 1),]
docProb <- probNewDoc(docSampled, alpha, phi, 10)


# This is a corpus created with docs that strongly exhibit
# two particular topics from the old corpus. 
newCorpus <- build.K.Topic.Corpus(dtmCORA, paramsCORA, K, 2, .5)
#dtmNew <- newCorpus[,-ncol(newCorpus)]
#paramsNew <- gibbsC(dtmNew, n.sim, 2, alpha, beta, verbose = F)


# Now let's visualize the results of the model fit with ggplot2. 

#numDocs <- 10

# Get a melted dataframe
#df <- get_plottable_df_lda(dtmCORA, cora.vocab, paramsCORA, numDocs)

# Plot the results. 
#plot <- get_primitive_qplot(df, numDocs)
#print(plot)

