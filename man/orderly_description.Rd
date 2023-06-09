% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/metadata.R
\name{orderly_description}
\alias{orderly_description}
\title{Describe the current packet}
\usage{
orderly_description(display = NULL, long = NULL, custom = NULL)
}
\arguments{
\item{display}{A friendly name for the report; this will be
displayed in some locations of the web interface, packit. If
given, it must be a scalar character.}

\item{long}{A longer description of the report. If given,
it must be a scalar character.}

\item{custom}{Any additional metadata. If given, it must be a named
list, with all elements being scalar atomics (character, number,
logical).}
}
\value{
Undefined
}
\description{
Describe the current packet
}
