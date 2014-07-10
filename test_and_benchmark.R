# This script analyzes the C++ code I for the Gibbs Sampler. 

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

# See the output in R for the problems.
# Note - I haven't included the code for the parameter estimates yet. 
#      - This is only a very little bit of code compared to getting gibbsC working. 
matrices <- gibbsC(dtm001, 1, K, alpha, beta, verbose = F), times = 5)


