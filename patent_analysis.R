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
vocabPATENTS <- colnames(dtmPATENTS)

# Remove stopwords.
# The words 'title' and 'abstract' appear in each file.  
stop.words <- c("title", "abstract")
new_objs <- remove.stopwords(dtmPATENTS, vocabPATENTS, stop.words)
dtmPATENTS <- new_objs[[1]]
vocabPATENTS <- new_objs[[2]]

# Set Parameters for the LDA Model
K <- 30
alpha <- 50/K

# Run the LDA code from the 'topicmodels' package. 
paramsPATENTS <- get_params_from_topicmodels(dtmPATENTS, K)

# Let's visualize the results by making plots. 
df <- get_plottable_df(corpusPATENTS, dtmPATENTS, colnames(dtmPATENTS), paramsPATENTS, 10)

plot <- get_primitive_qplot(df, 10)
print(plot)
