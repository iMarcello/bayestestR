#' @export
print.bayesfactor_inclusion <- function(x, digits = 2, log = FALSE, ...) {
  BFE <- x
  colnames(BFE) <- c('Pr(prior)', 'Pr(posterior)','log(Inclusion.BF)')
  if (!log) {
    colnames(BFE)[3] <- 'Inclusion.BF'
    BFE[,3] <- exp(BFE[,3])
  }


  print.data.frame(BFE, digits = digits)

  if (attr(BFE,'matched')) {
    cat('---\nInclusion BFs compared among matched models only.')
  } else {
    cat('---\nInclusion BFs compared among all models.')
  }

  if (!is.null(attr(BFE,'priorOdds')))
    cat('\nPriors based on custom prior-odds.')
  invisible(x)
}
