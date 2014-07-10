# This script analyzes the C++ code I for the Gibbs Sampler. 
# Be sure to setwd() to the dir containing this script. 

require(Rcpp)
require(microbenchmark)

sourceCpp("devGibbs.cpp")
source("gibbs_prep.R")


# Section 1: BENCHMARKS


# Benchmark my multinomial sampling code against R's multinomial sampling code.
probs <- c(.1, .05, .15, .3, .4)
n.test <- 1000

testOMC <- function(n.test, probs) {
	s <- length(probs)
	out <- rep(0, s)
	for (i in 1:n.test) {
		vector.sampled <- oneMultinomC(probs)
		index <- whichC(vector.sampled, 1)
		out[index + 1] = out[index + 1] + 1
	}
	out <- out / n.test
	rbind(out, probs)
}

testOMR <- function(n.test, probs) {
	s <- length(probs)
	out <- rep(0, s)
	for (i in 1:n.test) {
		vector.sampled <- rmultinom(1, 1, probs)
		index <- which(vector.sampled == 1)
		out[index] <- out[index] + 1
	}
	out <- out / n.test
	rbind(out, probs)
}

microbenchmark(
  testOMC(n.test, probs),
  testOMR(n.test, probs))

# Benchmark my uniform sampling code against R's uniform sampling code. 
b <- 10

testUnifC <- function(n.test, b) {
	for (i in 1:n.test) {
      unif <- cUnifTest(b)		
    }
}

testUnifR <- function(n.test, b) {
	for (i in 1:n.test) {
      unif <- round(runif(1, 1, b))
    }
}

microbenchmark(
  testUnifC(n.test, b),
  testUnifR(n.test, b))
  

# Section 2: TEST GIBBS SAMPLER


path_to_reuters <- "text_corpuses/reuters001"
reuters001 <- get_corpus(path_to_reuters)
dtm001 <- get_dtm_matrix(reuters001)

K <- 10
alpha <- 50/K
beta <- 0.01
nsim <- 1

M <- nrow(dtm001)
V <- ncol(dtm001)

# See the output in R for the problems.
# Note - I haven't included the code for the parameter estimates yet. 
#      - This is only a very little bit of code compared to getting gibbsC working. 
matrices <- gibbsC(dtm001, 1, K, alpha, beta, verbose = F)

# Okay, we see some errors. Let's investigate. 

count.matrices.init <- initializeGibbs(dtm001, K)

dtc.init <- count.matrices.init[[1]]
ttc.init <- count.matrices.init[[2]]
ta.init <- count.matrices.init[[3]]

# Are these counts tabulated correctly? Let's have a look at document zero. 
# Get the vocab terms that occur in document zero (have greater than one count in dtm)
doczero <- which(dtm001[1,] > 0)

# Okay, so we can see which words occur in document 0 by having a look at 'doczero'. 
# One such word is '38' if we index at zero (or '39' if we index at 1)
# Let's see what topic it was assigned in the initialization step. 

topiczero.38 <- ta.init[1, 39]

# Okay, this was random, so it will be different for me and you.  For me it's 3. 

# We see from the output that there is an error sampling a new topic for document 0, word 38. Let's try to do it manually: 

newZ <- sampler(dtm001, dtc.init, ttc.init, alpha, beta, 0, 38, K)

# Okay. That worked fine.  Weird.  What if we try to go even deeper and 
# run the code in 'sampler' that generates thep probabilities manually as well? 

# Let's do this for doc 1, word 39 (doc 0, word 38 w/ zero indexing)
m <- 1
n <- 39

params.test <- rep(0, K)
sum <- 0

for (k in 1:K) {
	prob.test <- ttc.init[k, n] + beta
	prob.test <- prob.test * (dtc.init[m, k] + alpha)
	prob.test <- prob.test / (rowSum(ttc.init, (k - 1) ) + (beta * V))
	prob.test <- prob.test / (rowSum(dtc.init, (m - 1) ) + (alpha * K))
	
	sum = sum + prob.test
	params.test[k] <- prob.test
}

params.test

# Okay, so this works too, but as we can see, the params are really small.
# Let's normalize. 

params.test <- params.test / sum

# And then pass these as probs to 'cmultinom'
cmultinom(params.test, (m - 1), (n -1))

# Damn. This is working here, too! Why??? I suspect rounding issues due to small numbers.  There must be different rounding behavior in C++ than in R. 











