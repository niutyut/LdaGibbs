## This file is for running LDA on a corpus of patent abstracts
## obtained from the USPTO. 
## Thanks to Drew Blount for his XMLParser.  
## 
## The program assumes our current directory is the root of this project.  

# Load functions into workspace
source("gibbs_prep.R")
source("Gibbs.R")
source("gibbs_output.R")

# Store the path to the reuters001 corpus as a string. 
path_to_patents <- "/Users/jacobmenick/Desktop/Summer_2014_Research/r_scripts/LdaGibbs/text_corpuses/patents_jan07"

# Get corpus and dtm.
corpusPATENTS <- get_corpus(path_to_patents)
dtmPATENTS <- get_dtm_matrix(corpusPATENTS)

# Set Parameters for the Gibbs Sampler
n.sim <- 25
K <- 30
alpha <- 50/K
beta <- 0.01

# Run Gibbs Sampler and store results in the variable 'params001'
params001 <- gibbs.sampler.lda(dtm001, n.sim, K, alpha, beta)

# Let's visualize the results by making plots. 
df <- get_plottable_df(reuters001, dtm001, vocab001, params001, 10)

plot <- get_primitive_qplot(df, 10)
print(plot)
