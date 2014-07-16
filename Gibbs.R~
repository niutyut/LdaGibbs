require("tm")
require(Rcpp)







gibbs.sampler.lda <- function(dtm, n.sim, K, alpha, beta) {
  # This gibbs sampler takes the following inputs: 
  #    'dtm' or Document-Term-Matrix representing a corpus
  #    'n.sim', the number of iterations for the simulation
  #    'K', the number of topics
  #    'alpha' and 'beta', the hyperparameters;
  #       They are vectors of length K and V respectively,
  #       Where V is the number of terms in the vocabulary.   
  #       
  # 
  # It assumes that the type of DTM is the one built with the tm package
  # but converted to a matrix.  
  # It outputs the parameter estimates: 
  # 
  #     'Phi', a K*V matrix whose rows are multinomial parameters
  #       for each topic's word distribution.
  #     'Theta', a M*K matrix whose rows are the topic mixture proportions.

  M = nrow(dtm)
  V = ncol(dtm)
  
  if (length(alpha) == 1) {
  	alpha <- rep(alpha, K)
  }
  
  if (length(beta) == 1) {
  	beta <- rep(beta, V)
  }

  ## Create Count Matrices

  doc.topic.counts <- matrix(rep(0, M * K), nrow = M, ncol = K)
  # The rows are documents, and the columns are the topics. 
  # (m-k)th entry is the number of times topic k occurred in document m.  

  topic.term.counts <- matrix(rep(0, K * V), nrow = K, ncol = V)
  # The rows are the topics, and the columns are the terms.  
  # (k-t)th entry is the number of times term t occurred with topic k. 

  topic.assignments <- matrix(rep(0, M * V), nrow = M, ncol = V)
  # Note that words that don't occur in document M still have a column.
  # I think this is the right call as it is much more 
  # fluid to work with a matrix rather than a list of vectors. 
  
    ## Helper Functions

  sample.from.conditional <- function(dtm, topic.term.counts, doc.topic.counts, 
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
  ## Initialize 

  # Pick the initial topic assignments randomly,
  # by sampling from a symmetric multinomial distribution, where each topic has 
  # probability 1/K. 
  sym.multinom.params <- rep(1/K, K)
  
  for (m in 1:M) {
  	for (n in 1:V) {
  		if (dtm[m,n] > 0) {
  			# If word 'n' is present in document 'm', randomly sample
  			# a topic assignment for that word.  
  			
  			sample <- rmultinom(1, 1, sym.multinom.params)
  			z.init <- which(sample == 1)
  			topic.assignments[m,n] <- z.init
  			
  			# Increment appropriate counts.
  			doc.topic.counts[m,z.init] <- doc.topic.counts[m,z.init] + 1
  			topic.term.counts[z.init, n] <- topic.term.counts[z.init, n] + 1
  			
  		}
  		
  		else {
  			z.init <- 0
  		}
  	}
  }

  ## Gibbs Sampling
  
  for (c in 1:n.sim) {
  	for (m in 1:M) {
  		for (n in 1:V) {
  			if (dtm[m,n] > 0) {
  				# Remove word(m,n) from its current topic assignment.
  				# Also, decrement appropriate counts. 
  				z.old <- topic.assignments[m,n]
  				
  				# No danger of going negative, but maybe we should check for that later on. 
  				
  				if (doc.topic.counts[m,z.old] > 0) {
  					doc.topic.counts[m, z.old] <- doc.topic.counts[m, z.old] - 1
  				}
  				
  				if (topic.term.counts[z.old, n] > 0) {
  					topic.term.counts[z.old, n] <- topic.term.counts[z.old, n] - 1
  				}
  				
  				# Sample a new topic for word(m,n) from the full conditional distribution.
  				# Then increment appropriate counts.
  				z.new <- sample.from.conditional(dtm, topic.term.counts, doc.topic.counts,
  				                                 alpha, beta, m, n, K)
  				doc.topic.counts[m, z.new] = doc.topic.counts[m, z.new] + 1
  				topic.term.counts[z.new, n] = topic.term.counts[z.new, n] + 1
  				
  			} else {
  			  # Do nothing. Term n does not occur in document m.  	
  			}
  		}
  	}
  }

  ## Parameter Estimation
  
  Phi <- matrix(rep(0, K*V), nrow = K, ncol = V)
  Theta <- matrix(rep(0, M*K), nrow = M, ncol = K)
  
  # Calculate parameter estimates for Phi
  for (k in 1:K) {
  	for (t in 1:V) {
  		Phi[k,t] <- topic.term.counts[k,t] + beta[t]
  		Phi[k,t] <- Phi[k,t] / (sum(topic.term.counts[k,]) + sum(beta))
  	}
  }
  
  # Calculate parameter estimates for Theta
  for (m in 1:M) {
  	for (k in 1:K) {
  		Theta[m,k] <- doc.topic.counts[m,k] + alpha[k]
  		Theta[m,k] <- Theta[m,k] / (sum(doc.topic.counts[m,]) + sum(alpha))
  	}
  }

  ## Output 
  
  output <- list(Phi, Theta, topic.assignments)
  names(output) <- c("Phi", "Theta", "Topic Assignments")
  output
 
}

gibbs.c.wrapper <- function(dtm, n.sim, K, alpha, beta) {
  GibbsC(dtm, n.sim, K, alpha, beta, sample.from.conditional)		  		
}

