#include <Rcpp.h>
#include <random>
#include <stdexcept>
#include <iostream>
using namespace Rcpp;

// cUnifTest
// Samples from a uniform integer distribution.  
// Isolated for testing/benchmarking. 

// [[Rcpp::export]]
int cUnifTest(int K) {
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<> unif(1, K);
  return unif(gen);
}


// rowSum
//
// Sums the elements of the matrix 'x' in row 'r'. 
// Note, it is zero-based, where R matrices are 1-based. 
 
// [[Rcpp::export]]
double rowSum(NumericMatrix x, int r) {
  double sum = 0;
  int numRows = x.nrow();
  int numCols = x.ncol();
  if (r > (numRows - 1)) {
    Rprintf("r cannot be greater than (numRows - 1), but r = %d", r);
  } else {
    for (int j = 0; j < numCols; ++j) {
      sum += x(r, j);
    }
  }
  return sum;
}

// whichC
//
// Gives the index of the element in the vector 'x' equal to 'val'. 
// C++ implementation of the 'which()' function in R. 
// Note - the vector is zero-based in C++. 
// Also note - this only works if 'val' appears only once in 'x'. 
 
// [[Rcpp::export]]
int whichC(NumericVector x, double val) {
  int index = -1;
  int n = x.size();

  for (int i = 0; i < n; ++i) {
    if (x[i] == val) {
      if (index == -1) {
	index = i;
      } else {
	Rcpp::Rcout << "The value appears multiple times!" << std::endl;
      }
    }
  }

  // If the element appears, return the index. 
  if (index == -1) { Rcpp::Rcout << "The value does not appear in this vector!" << std::endl;}
  return index;
}

// whichOne
//
// Gives the index of the element in an IntegerCector 'x' equal to 1. 
// Note - the vector is zero-based in C++. 
 // [[Rcpp::export]]
int whichOne(IntegerVector x) {
  int index = -1;
  int n = x.size();
  for (int i = 0; i < n; ++i) {
    if (x[i] == 1) {
      if (index == -1) {
	index = i;
      } else {
	Rcpp::Rcout << "There's more than one 1. Check multinom functions." << std::endl;
      }
    }
  }

  // If The Element Appears, return the index. 
  if (index == -1) { Rcpp::Rcout << "error: There is no one here. Vector is " << x << std::endl;}
  return index;
}


// oneMultinomcC
// 
// Samples a single vector from a single draw of the Multinomial 
// distribution with parameters specified by 'probs'. 

// [[Rcpp::export]]
IntegerVector oneMultinomC(NumericVector probs) {
  int k = probs.size();
  IntegerVector ans(k);
  rmultinom(1, probs.begin(), k, ans.begin());
  return(ans);
}

// cmultinom
//
// Returns the index of the sampled multinomial vector which is 1. 
// Note - this is zero-indexed. 

// [[Rcpp::export]]
int cmultinom(NumericVector probs, int m = 0, int n = 0) {
  int K = probs.size();
  int out = -1;
  IntegerVector vec = oneMultinomC(probs);
  out = whichOne(vec);
  if (out == -1) { 
    Rcpp::Rcout << "Error: Internal error. " 
		<< "(Doc, word) is (" 
		<< m << ", " << n << ")"<< std::endl;

    Rcpp::Rcout << "Probabilities vector: (";
    for (int i = 0; i < (K - 1); ++i) {
      Rcpp::Rcout << probs[i] << ", ";
    }
    Rcpp::Rcout << probs[(K-1)] << ")" << std::endl;
      

  }
  return out;
}

// initializeGibbs
//
// 1. Creates M x K matrix, dtc ('document-topic-counts' matrix), 
//         K x V matrix, ttc ('topic-term-counts' matrix),
//     and M X V matrix, ta  ('topic-assignment' matrix). 
// 
// 2.  Randomly assigns a topic to each word in the M x V matrix, dtm,
//     via discrete uniform from [0, K - 1], where K = numTopics. 
// 
// 3.  Increments the correct summs in dtc and ttc. 
//
// Initialize gibbs returns an R list containing 'dtc' and 'ttc'. 
// 
// This is the first section of the full gibbsC algorithm. 
// It is only in this separate function for testing purposes.  

// [[Rcpp::export]]
RObject initializeGibbs(NumericMatrix dtm, int K) {

  // import some shit from the std library. 
  // to enable random sampling from a uniform int distribution.
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<int> unif(1, K);
  

  // The rows of the document-term matrix are 'documents' of which there are M.
  // The columns correspond to terms in the vocab, of which there are V. 
  int M = dtm.nrow();
  int V = dtm.ncol();

  // Initialize the count matrices. 
  // dtc is (M x K), ttc is (K x V), ta is (M x V)
  NumericMatrix dtc(M, K);
  NumericMatrix ttc(K, V);
  NumericMatrix ta(M, V);

  // Randomly assign topics to each word in each document. 
  // After assigning a topic to a word, increment the counts 
  // for the number of times the topic appears in the document, 
  // and the number of times the word appears with the topic. 

  // Loop over documents (zero-indexed)
  for (int m = 0; m < M; ++m) {
    // Loop over words in document. 
    for (int n = 0; n < V; ++n) {

      // Uh oh. It looks like we should re-index the topics at 1-based.
      // We calculate some shit assuming 0 indicates no topic assignment. 
      // That way, when we sum, unassigned topics don't contribute to counts.
      //
      // This means that we will have to add 1 somewhere.
      // I will carefully document this. 
      // *FROM NOW ON, TOPICS ARE INDEXED 1-K
      int initZ = 0;

      // Only assign non-zero topic to word 'n' if it appears in doc 'm'. 
      if (dtm(m, n) > 0) {

	// initZ is now a random integer between 1 and K.
	initZ = unif(gen);

	// Assign initZ to the topic of word 'n' in document 'm'. 
	ta(m, n) = initZ;

	// Increment the count of initZ in dtc and ttc. 
        // SUBTRACT 1 BECAUSE THESE MATRICES INDEX TOPIC at [0, K-1]
	dtc(m, (initZ - 1) ) += 1;
	ttc( (initZ - 1), n) += 1;
	
      } else {}
    } // end loop over words
  } // end loop over documents.

  
  // Return ta (topic-assignemnts), dtc (doc-topic counts), and ttc (topic-term-counts)
  RObject out = Rcpp::List::create(Rcpp::Named("DTC") = dtc,
				   Rcpp::Named("TTC") = ttc,
				   Rcpp::Named("TA") = ta);
  return out;
}

// sampler
//
// Defines a multinomial distribution over topics, where
// the parameters are determined by the 'full conditional probability' 
// of topic k for word n in doc m, 
// given the rest of the topics, and the topic assignments for the rest
// of the words. 
//
// We then sample a topic index for word 'n' in document 'm'
// from this multinomial distribution and return the index as 'newZ'. 
// This topic will be indexed by [1, K]. 
// So we will have to subtract one from the index when we update the counts
// for dtc and ttc (as topic is index from [0, K-1] in those matrices. 
// 
// Let's remember to check if the index is -1 in that function as well 
// and return an error if so. 

// [[Rcpp::export]]
int sampler(NumericMatrix dtm, NumericMatrix dtcm, NumericMatrix ttcm,
	    double alpha, double beta, int m, int n, int K, bool verbose = false) {
  
  int M = dtm.nrow();
  int V = dtm.ncol();				
  int newZ = 0;

  // Only assign a new topic to word 'n' if it occurs in document 'm'. 
  if (dtm(m, n) > 0) {

    // 'params' will hold the parameters for the multinomial distribution. 
    // It is zero-indexed. 
    NumericVector params(K);
    
    // 'sum' will hold the sum of the params so that we can normalize 
    // the multinomial probabilities to sum to 1. 
    double sum = 0;

    // prob indexed by k is the 'full conditional distribution' 
    // of topic k, as defined by equation (77) in the Heinrich paper (see link).
    // Link to Heinrich paper below. 
    // [http://faculty.cs.byu.edu/~ringger/CS601R/papers/Heinrich-GibbsLDA.pdf]

    // What happens if we multiply by 10000? I think it should be fine because
    // it keeps everything proportional.  That way maybe avoid some issues with REALLY
    // small numbers being rounded to zero? 
    // And it should work out because everything is normalized to 1 anyway. 

    for (int k = 0; k < K; ++k) {
      double prob = ttcm(k, n) + beta;
      prob = prob * (dtcm(m, k) + alpha);
      prob = prob / (rowSum(ttcm, k) + (beta * V));
      prob = prob / (rowSum(dtcm, m) + (alpha * K));

      params[k] = prob;
      sum += prob;
    }

    if (verbose) {
      Rcpp::Rcout << "Params: (";
      for (int i = 0; i < (K - 1); i++) {
	Rcpp::Rcout << params[i] << ", ";
      }
      Rcpp::Rcout << params[K - 1] << ")" << std::endl;
      
    }

    // Normalize params so that the probabilities sum to 1. 
    for (int k = 0; k < K; ++k) {
      params[k] = params[k] / sum;
    }
    // TODO - FIGURE OUT HOW TO PRINT A VECTOR.
    // I NEED TO KNOW WHY THERE ARE NO ONES SOMETIMES.
    // Rcpp::Rcout << "Params: " <<  params << std::endl;
    // Now params is a NumericVector that can be passed to cmultinom.
    // Receive a zero-indexed topic from cmultinom and add 1 to it. 
    newZ = cmultinom(params, m, n) + 1; 
  }
  // RETURN 1-indexed topic. If it is zero, then NO TOPIC WAS ASSIGNED.
  return newZ;
}

// gibbsC
// 
// TODO - there are bugz. Errors arise with doc 0. 
//
// This is the gibbs sampler for LDA. 
// We hand this funciton a 'document-term-matrix', dtm,
// the number of topics, 'K',
// the hyperparameters 'alpha' and 'beta',
// and the number of iterations for MCMC, 'nsim'. 
// 
// We receive an R List object containing two matrices corresponding
// to the estimated parameters of the model. 
// PHI is the K * V matrix with the multinomial probabilities for terms,
//   given the topic. 
// THETA is the M * K matrix with the mixture proportions. 

// [[Rcpp::export]]
RObject gibbsC(NumericMatrix dtm, int nsim, int K, double alpha, double beta, bool verbose = false) {


  // SECTION 1: Initialize. 


  // import some shit from the std library. 
  // to enable random sampling from a uniform int distribution.
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<int> unif(1, K);
  

  // The rows of the document-term matrix are 'documents' of which there are M.
  // The columns correspond to terms in the vocab, of which there are V. 
  int M = dtm.nrow();
  int V = dtm.ncol();

  // Initialize the count matrices. 
  // dtc is (M x K), ttc is (K x V), ta is (M x V)
  NumericMatrix dtc(M, K);
  NumericMatrix ttc(K, V);
  NumericMatrix ta(M, V);

  // Randomly assign topics to each word in each document. 
  // After assigning a topic to a word, increment the counts 
  // for the number of times the topic appears in the document, 
  // and the number of times the word appears with the topic. 

  // Loop over documents (zero-indexed)
  for (int m = 0; m < M; ++m) {
    // Loop over words in document. 
    for (int n = 0; n < V; ++n) {

      // Uh oh. It looks like we should re-index the topics at 1-based.
      // We calculate some shit assuming 0 indicates no topic assignment. 
      // That way, when we sum, unassigned topics don't contribute to counts.
      //
      // This means that we will have to add 1 somewhere.
      // I will carefully document this. 
      // *FROM NOW ON, TOPICS ARE INDEXED 1-K
      int initZ = 0;

      // Only assign non-zero topic to word 'n' if it appears in doc 'm'. 
      if (dtm(m, n) > 0) {

	// initZ is now a random integer between 1 and K.
	initZ = unif(gen);

	// Assign initZ to the topic of word 'n' in document 'm'. 
	ta(m, n) = initZ;

	// Increment the count of initZ in dtc and ttc. 
        // SUBTRACT BY 1 BECAUSE THESE MATRICES INDEX TOPIC at [0, K-1]
	dtc(m, (initZ - 1) ) += 1;
	ttc( (initZ - 1), n) += 1;
	
	if (verbose) {
	  Rcpp::Rcout << "Initialized topic of word " << n << " in doc " 
		      << m << " as " << initZ << ". " << std::endl << std::endl;
	}
	
      } else {}
    } // end loop over words
  } // end loop over documents.

  // SECTION 2: Run MCMC and iteratively update our guess
  // at the topic assignments. 

  // Run the gibbs sampler 'nsim' times: 
  for (int s = 0; s < nsim; ++s){
    // Loop over documents
    for (int m = 0; m < M; ++m) {
      // Loop over words.
      for (int n = 0; n < V; ++n) {

	// Grab the old topic assignment for word 'n' in document 'm'. 
	// Recall that topics in 'ta' are indexed in [1, K]. 
	int oldZ = ta(m, n);
	int newZ;

	// Only update the topic for word 'n' in document 'm' if it occurs. 
	if (dtm(m, n) > 0) {
	  if (oldZ == 0) { 
	    Rcpp::Rcout << "error. Should have been assigned. (" 
			<< m << ", " << n << ")" << std::endl;
	  }

	  // Decrement the counts for oldZ, because we are removing this 
	  //   topic label and choosing a new one. 
	  // When we reference the topic in the count matrices, 
	  // we have to SUBTRACT 1, because they are zero-indexed there.

	  // decrement document-topic count for old topic.
	  if ( dtc(m, (oldZ - 1) ) > 0) {
	    dtc(m, (oldZ - 1) ) -= 1;
	  } else { Rcpp::Rcout << "error: dtc should have been at least one.";}

	  // decrement topic-term count for old topic. 
	  if ( ttc( (oldZ - 1), n) > 0 ) {
	    ttc( (oldZ - 1), n) -= 1;
	  } else { Rcpp::Rcout << "error: ttc should have been at least one.";}

	  // Pick a new topic for word 'n' in doc 'm' and increment appropriate
	  //   counts, observing as before the index conventions. 

	  newZ = sampler(dtm, dtc, ttc, alpha, beta, m , n, K);

	  ta(m, n) = newZ;
	  dtc(m, (newZ - 1)) += 1;
	  ttc( (newZ - 1), n) += 1;

	  if (verbose) {
	    Rcpp::Rcout << "Iteration: " << s << std::endl;
	    Rcpp::Rcout << "(Document, Word): (" << m << ", "
			<< n << ")" << std::endl
			<< "Old Topic: " << oldZ << std::endl
			<< "New topic: " << newZ << std::endl << std::endl;
	  }

	  
	} else { newZ = oldZ; }
       
      } // end loop over words in document 'm'
    } // end loop over documents. 
  } // end loop over nsim.


  // SECTION 3: Estimate parameters and return them as an R List. 
  NumericMatrix phi(K, V);
  NumericMatrix theta(M, K);

  // Estimate Phi first. 
  // This is the mode of the posterior distribution for Phi. 
  
  // loop over topics (rows)
  for (int k = 0; k < K; ++k) {
    // loop over terms in vocab (columns)
    for (int t = 0; t < V; ++t) {
      phi(k, t) = ttc(k, t) + beta;
      phi(k, t) = phi(k, t) / ( rowSum(ttc, k) + (beta * V) );
    }
  }

  // Now estimate Theta.
  // Row i of the Theta is the topic mixture-proportions for doc i. 

  // loop over docs (rows)
  for (int m = 0; m < M; ++m) {
    // loop over topics (columns)
    for (int k = 0; k < K; ++k) {
      theta(m, k) = dtc(m, k) + alpha;
      theta(m, k) = theta(m, k) / ( rowSum(dtc, m) + (alpha * K) );
    }
  }

  // Return an R List containing Phi and Theta. 

  RObject out = Rcpp::List::create(Rcpp::Named("Phi") = phi,
				   Rcpp::Named("Theta") = theta,
				   Rcpp::Named("Topic Assignments") = ta);

  return out;
}



