#include <Rcpp.h>
#include <random>
using namespace Rcpp;

// [[Rcpp::export]]
double vector_sum(NumericVector x) {
	double out = 0;
	for (int i = 0; i < x.size(); ++i) {
		out += x[i];
	}
	return out;
}

// [[Rcpp::export]]
NumericVector oneDirichlet(NumericVector alpha) {
	int k = alpha.size();
	NumericVector gammaz(k);
	NumericVector sample(k);
	// random number generator
	std::random_device rd;
	double gamSum = 0;
	for (int i = 0; i < k; ++i) {
		std::gamma_distribution<double> gamma(alpha[i], 1);
		gammaz[i] = gamma(rd);
		gamSum += gammaz[i];
	}
	for (int i = 0; i < k; ++i) {
		sample[i] = gammaz[i]/gamSum;
	}
	return sample;
}

// [[Rcpp::export]]
double lDocProbC(NumericVector dtv, double alpha, NumericMatrix phi, int numSamples) {
	int K = phi.nrow();
	int V = phi.ncol();
	NumericVector alphaVec(K);
	for (int i = 0; i < K; i++) {
		alphaVec[i] = alpha;
	}
	double out = 0;
	for (int s = 0; s < numSamples; ++s) {
		double prod = 1;
		for (int n = 0; n < V; ++n) {
			if (dtv[n] > 0) {
				double sum = 0;
				for (int k = 0; k < K; ++k) {
					double term = oneDirichlet(alphaVec)[k] * phi(k, n);
					sum += term;
				}
				prod = prod * sum;
			}
		}
		out += prod;
	}
	out = out/numSamples;
	return log(out);
}

// [[Rcpp::export]]
RObject lCorpusProbC(NumericMatrix dtm, double alpha, NumericMatrix phi, int numSamples) {
	IntegerVector errors;
	int M = dtm.nrow();
	double out = 0;
	for (int d = 0; d < M; d++) {
		double newProb = lDocProbC(dtm.row(d), alpha, phi, numSamples);
		if (newProb > -DBL_MAX) {
			out += newProb;
		}
		else {
			errors.insert(errors.size(), d);
		}
	}
	RObject ret = Rcpp::List::create(Rcpp::Named("CorpusProb") = out,
																	 Rcpp::Named("error indices") = errors);
	return ret;
}

// [[Rcpp::export]]
RObject perplexityC(NumericMatrix dtm, double alpha, NumericMatrix phi, int numSamples) {
	IntegerVector errors;
	double sum = 0;
	int M = dtm.nrow();
	int V = dtm.ncol();
	int K = phi.nrow();
	double entropy = 0;
	int totalWordCount = 0;
	for (int d = 0; d < M; ++d) {
		NumericVector dtv = dtm.row(d);
		double newProb = lDocProbC(dtv, alpha, phi, numSamples);
		if (newProb > -DBL_MAX) {
			entropy += newProb;
		}
		else {
			errors.insert(errors.size(),d);
		}
		totalWordCount += vector_sum(dtv);
	}
	double perplexity = exp(-1*entropy/totalWordCount);
	RObject out = Rcpp::List::create(Rcpp::Named("Perplexity") = perplexity,
																	 Rcpp::Named("error indices") = errors);

	return out;
}

// [[Rcpp::export]]
double dotProduct(NumericVector x, NumericVector y) {
	int xLen = x.size();
	int yLen = y.size();
	if (xLen != yLen) {
		std::cout << "Error. x and y must have the same length to take dot prod.";
	}
	double sum = 0;
	for (int i = 0; i < xLen; ++i) {
		sum += x[i]*y[i];
	}
	return sum;
}

// [[Rcpp::export]]
int chooseC(int n, int k) {
	return Rf_choose(n, k);
}

// [[Rcpp::export]]
double norm(NumericVector x) {
	return sqrt(dotProduct(x, x));
}

// [[Rcpp::export]]
NumericVector normalize(NumericVector x) {
	double nmX = norm(x);
	int xLen = x.size();
	NumericVector out(xLen);
	for (int i = 0; i < xLen; ++i) {
		out[i] = x[i]/nmX;
	}
	return out;
}

// [[Rcpp::export]]
double similarity(NumericVector x, NumericVector y) {
	int xLen = x.size();
	int yLen = y.size();
	if (xLen == yLen) {
		return dotProduct(x, y)/(norm(x) * norm(y));
	}
	else {
		std::cout << "Error.  Vectors must have same length to take similarity." << std::endl;
		return -1;
	}
}

// [[Rcpp::export]]
double MatSimi(NumericMatrix x) {
	int K = x.nrow();
	double simi = 0;
	for (int i = 0; i < K; ++i) {
		for (int j = 0; j < K; ++j) {
			if (i != j) {
				simi += similarity(x.row(i), x.row(j));
			}
		}
	}
	return simi;
}

double AvgMatSimi(NumericMatrix x) {
	int K = x.nrow();
	double simi = 0;
	for (int i = 0; i < K; ++i) {
		for (int j = 0; j < K; ++j) {
			if (i != j) {
				simi += similarity(x.row(i), x.row(j));
			}
		}
	}
	return simi/(chooseC(K, 2));
}



// [[Rcpp::export]]
double lg(double x) {
	return log(x)/log(2);
}

double log10(double x) {
	return log(x)/log(10);
}

// vectorEntropy assumes the vector is a probability vector. 
// i.e. entries sum to one. 

// [[Rcpp::export]]
double vectorEntropy(NumericVector x) {
	int xLen = x.size();
	double ent = 0;
	for (int i = 0; i < xLen; ++i) {
		ent += x[i] * lg(x[i]);
	}
	return ent;
}

// By 'Matrix Entropy', 
// I just mean the sum of the entropy of the rows.

// [[Rcpp::export]]
double MatEntropy(NumericMatrix x) {
	int numRows = x.nrow();
	double totEnt = 0;
	for (int i = 0; i < numRows; ++i) {
		totEnt += vectorEntropy(x.row(i));
	}
	return -1*totEnt;
}

// [[Rcpp::export]]
double jMetric(NumericMatrix phi, int K) {
	if (K == 1) {
		return 3*MatSimi(phi) + MatEntropy(phi);
	}
	else {
		return 3*MatSimi(phi)/(chooseC(K, 2)) + MatEntropy(phi)/K + log10(K);
	}
}


