require("tm")
require(Rcpp)

# Grab the cpp gibbs sampler. 
sourceCpp("gibbsC.cpp")

sampler <- function(dtm, topic.term.counts, doc.topic.counts, 
  									  alpha, beta, m, n, K) {
    # m is the document index, and n is the term index. 
    # As output, we get a sample from the full conditional distribution
    # If word n does not occur in document m, then the topic is left as zero.
    # This is cool, because the topics are indexed from 1 to K.  
	
	if (dtm[m,n] > 0) { 
		# Only sample a topic for the word if it occurs in document m.  
		
    	multinom.params <- rep(0, K)
    	for (k in 1:K) {
    		# 'prob' is the full conditional distribution. 
    		# Calculations broken up into several lines. 
    	
      		prob <- (topic.term.counts[k,n] + beta[n]) 
      		prob <- prob * (doc.topic.counts[m,k] + alpha[k])
      		prob <- prob / (sum(topic.term.counts[k,]) + sum(beta))
		prob <- prob / (sum(doc.topic.counts[m,]) + sum(alpha))
      	
      		multinom.params[k] <- prob
    	}
    	
    	# normalize so that the parameters sum to 1
    	sum = sum(multinom.params)
    	multinom.params <- multinom.params / sum
    	
    	# 'sample' is a k-dimensional vector
    	sample <- rmultinom(1, 1, multinom.params)
    	
    	# z.new is the topic assignment.
    	z.new <- which(sample == 1)
    	
	} else{
		# If the word does not occur, it still is not assigned a topic.  
		z.new <- 0
	}
	
	# return the new topic assignment for word(m,n).  
	z.new
}	
  

