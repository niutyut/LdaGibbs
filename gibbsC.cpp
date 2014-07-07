#include <Rcpp.h>
#include <random>
#include <stdexcept>
using namespace Rcpp;

// akin to 'import __ as __' in python. 
typedef std::uniform_int_distribution<> D;
typedef std::minstd_rand G;

double rowSum(NumericMatrix x, int r) {
  int numCols = x.ncol();
  int sum = 0;
  for (int c = 0; c < numCols; ++c) {
    sum += x(r, c);
  }
  return sum;
}

int whichC(NumericVector x, double val) {
  int ind = -1;
  int n = x.size();
  for (int i = 0; i < n; ++i) {
    if (x[i] == val) {
      if (ind == -1) {
	ind = i;
      } else {
	throw std::invalid_argument( "value appears multiple times." );
      }
    } // end if
  } // end for
  if (ind != -1) {
    return ind;
  } else {
    throw std::invalid_argument( "value doesn't appear here!" );
    return -1;
  }
}

// [[Rcpp::export]]
int sampler(NumericMatrix dtm, NumericMatrix dtc, NumericMatrix ttc,
	    int alpha, int beta, int m, int n, int K) {

  int M = dtm.nrow();
  int V = dtm.ncol();
  int newZ = 0;
  
  if (dtm(m, n) > 0) {

    // These will be parameters for a multinomial distribution.
    NumericVector params(K);
    double sum = 0;

    // Set the appropriate values for each entry of 'params'
    for (int k = 0; k < K; ++k) {
      double prob = ttc(k, n) + beta;
      prob = prob * dtc(m, k) + alpha;
      prob = prob / (rowSum(ttc, k) + (beta * V));
      prob = prob / (rowSum(dtc, m) + alpha * K);

      params[k] = prob;
      sum += prob;
    } // end for

    // Normalize so that 'params' sums to 1. 
    for (int k = 0; k < K; ++k) {
      params[k] = params[k] / sum;
    }

    // TODO - figure out why rmultinom ain't workin'. 
    RObject sampled = rmultinom(1, 1, params);
    newZ = whichC(as<NumericVector>(sampled), 1);
    
  } else {
    newZ = 0;
  }
  return newZ;
}

// [[Rcpp::export]]
RObject GibbsC(NumericMatrix dtm, int nSim, int K, int alpha, int beta) {
  
  int M = dtm.nrow();
  int V = dtm.ncol();
  
  //Initialize count matrices.
  NumericMatrix dtc(M, K);
  NumericMatrix ttc(K, V);
  NumericMatrix ta(M, V);
  

  // Populate count matrices.
  // topic assignments first. 
  for (int m = 0; m < M; ++m) {
    for (int n = 0; n < V; ++n) {
      int initZ = 0;
      // Only assign topics if word n occurs in document m. 
      if (dtm(m, n) > 0) {
	// Randomly sample a topic assignment for dtm[m, n]
	G g;
	D d(0, K);
	initZ = d(g);
	ta(m, n) = initZ;
      
	// Increment appropriate counts. 
	dtc(m, initZ) += 1;
	ttc(initZ, n) += 1;

      } else {
	initZ = 0;
      }
    }
  }

  // Perform MCMC Gibbs Sampling
  for (int s = 0; s < nSim; ++s) {
    for (int m = 0; m < M; ++m) {
      for (int n = 0; n < V; ++n) {
	
	int oldZ = dtm(m, n);
	int newZ;

	// Only sample a new topic for dtm[m, n] if
	// word n occurs in document m. 
	if (dtm(m, n) > 0) {
	  
	  // decrement appropriate counts if they are strictly positive.
	  if (dtc(m, oldZ) > 0) {
	    dtc(m, oldZ) -= 1;
	  }
	  
	  if (ttc(oldZ, n) > 0) {
	    ttc(oldZ, n) -= 1;
	  }

	  newZ = sampler(dtm, ttc, dtc, alpha, beta, m, n, K);
	  dtc(m, newZ) += 1;
	  ttc(newZ, n) += 1;
	} else {
	  newZ = oldZ;
	} // end else
      } // end for over V
    } // end for over M 
  } // end for over nSim

  NumericMatrix phi(K, V);
  NumericMatrix theta(M, K);

  // Calculate parameter estimates. 
  for (int k = 0; k < K; ++k) {
    for (int t = 0; t < V; ++t) {
      phi(k, t) = ttc(k, t) + beta;
      phi(k, t) = phi(k, t) / (rowSum(ttc, k) + (beta * V));
    }
  }

  for (int m = 0; m < M; ++m) {
    for (int k = 0; k < K; ++k) {
      theta(m, k) = dtc(m, k) + alpha;
      theta(m, k) = theta(m, k) / (rowSum(ttc, m) + (alpha * K));
    }
  }

  RObject out = Rcpp::List::create(Rcpp::Named("Phi") = phi, 
				   Rcpp::Named("Theta") = theta);
 
  return out;

  
} // end GibbsC. 
