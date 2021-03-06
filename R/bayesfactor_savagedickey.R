#' Savage-Dickey density ratio Bayes factor
#'
#' This method computes the ratio between the density of a single value (typically the null)
#' in two distributions, typically the posterior vs. the prior distributions.
#'
#' This method is used to examine if the hypothesis value is less or more likely given the observed data.
#'
#' @param posterior Vector representing a posterior distribution.
#' @param prior Vector representing a prior distribution. If a prior is not provided, will sample from \code{~Cauchy(location = hypothesis, scale = sd(posterior))} (but this should be avoided).
#' @param direction Test type. One of \code{0}, \code{"two-sided"} (defult; two tailed),
#' \code{-1}, \code{"left"} (left tailed), \code{1}, \code{"right"} (right tailed).
#' @param hypothesis Value to be tested against (usually \code{0} in the context of null hypothesis testing).
#'
#' @return A data frame of class \code{BFsd} which contains the Bayes factor representing by how
#' much \emph{less} the null is likely under the posterior compared to the prior (larger than 1
#' can be interpereted as evidence against the null).
#'
#' @examples
#' library(bayestestR)
#'
#' prior <- rnorm_perfect(1000, mean = 0, sd = 1)
#' posterior <- rnorm_perfect(1000, mean = .5, sd = .3)
#'
#' bayesfactor_savagedickey(posterior, prior)
#'
#' @references
#' Wagenmakers, E. J., Lodewyckx, T., Kuriyal, H., & Grasman, R. (2010). Bayesian
#' hypothesis testing for psychologists: A tutorial on the Savage-Dickey method.
#' Cognitive psychology, 60(3), 158-189.
#'
#' @author Mattan S. Ben-Shachar
#'
#' @export
bayesfactor_savagedickey <- function(posterior,prior,direction = "two-sided", hypothesis = 0) {
  UseMethod("bayesfactor_savagedickey")
}


#' @rdname bayesfactor_savagedickey
#' @export
#' @importFrom insight print_color
#' @importFrom stats rcauchy sd
bayesfactor_savagedickey.numeric <- function(posterior,prior,direction = "two-sided", hypothesis = 0){
  if (missing(prior)) {
    prior <- stats::rcauchy(
      n        = length(posterior),
      location = hypothesis,
      scale    = stats::sd(posterior)
    )
    warning("Prior not specified!\n",
            "Used Cauchy prior with location = ", hypothesis, " and scale = ", round(stats::sd(posterior)), ".\n",
            "It is recommended to explicitly define the prior!")
  }

  # find direction
  direction.opts <- data.frame(
    String = c("left","right","two-sided","<",">","=","-1","0","1","+1"),
    Value = c(-1, 1, 0, -1, 1, 0, -1, 0, 1, 1)
  )
  direction <- direction.opts$Value[pmatch(direction, direction.opts$String, 2)[1]]


  if (requireNamespace("logspline")) {
    f_post <- suppressWarnings(logspline::logspline(posterior))
    f_prior <- suppressWarnings(logspline::logspline(prior))

    d_post <- logspline::dlogspline(hypothesis, f_post)
    d_prior <- logspline::dlogspline(hypothesis, f_prior)

    norm_post <- norm_prior <- 1
    if (direction < 0) {
      norm_post <- logspline::plogspline(hypothesis, f_post)
      norm_prior <- logspline::plogspline(hypothesis, f_prior)
    } else if (direction > 0) {
      norm_post <- 1 - logspline::plogspline(hypothesis, f_post)
      norm_prior <- 1 - logspline::plogspline(hypothesis, f_prior)
    }
  } else {
    insight::print_color("Consider installing the \"logspline\" package for a more robust estimate.\n", "red")
    d_post <- density_at(posterior, hypothesis)
    d_prior <- density_at(prior, hypothesis)

    norm_post <- norm_prior <- 1
    if (direction < 0) {
      norm_post <- mean(posterior < hypothesis)
      norm_prior <- mean(prior < hypothesis)
    } else if (direction > 0) {
      norm_post <- 1 - mean(posterior < 0)
      norm_prior <- 1 - mean(prior < hypothesis)
    }
  }

  bf_val <- data.frame(BFsd = (d_prior / norm_prior) / (d_post / norm_post))
  class(bf_val) <- c("bayesfactor_savagedickey", class(bf_val))
  attr(bf_val, "hypothesis") <- hypothesis

  bf_val
}
