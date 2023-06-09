% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interactive.R
\name{orderly_interactive_set_search_options}
\alias{orderly_interactive_set_search_options}
\title{Set search options for interactive use}
\usage{
orderly_interactive_set_search_options(
  options = NULL,
  root = NULL,
  locate = TRUE
)
}
\arguments{
\item{options}{Optional control over locations, when used
with \link{orderly_dependency}; see of Details section of
\link{orderly_run}.}

\item{root}{The path to an orderly root directory, or \code{NULL}
(the default) to search for one from the current working
directory if \code{locate} is \code{TRUE}.}

\item{locate}{Logical, indicating if the configuration should be
searched for.  If \code{TRUE} and \code{config} is not given,
then orderly looks in the working directory and up through its
parents until it finds an \code{.outpack} directory}
}
\value{
Nothing, called for its side effects
}
\description{
Set search options for interactive use of orderly; see
\link{orderly_dependency} and \link{orderly_run} for
details. This may be either an \link{outpack_search_options}
object, or a list that will be coerced into one at the point of
use (or \code{NULL}). This applies only for the current session, but
applies to all interactive uses of orderly functions that might
have recieved a copy of \code{search_options} via
\link{orderly_run}
}
