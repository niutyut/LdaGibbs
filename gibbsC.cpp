#include <Rcpp.h>
#include <random>
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

// [[Rcpp::export]]
RObject GibbsC(NumericMatrix dtm, int nSim, int K, int alpha, int beta, Function sample) {
  
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

	  newZ = as<int>(sample(dtm, ttc, dtc, alpha, beta, m, n, K));
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
