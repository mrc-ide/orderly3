% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/metadata.R
\name{orderly_global_resource}
\alias{orderly_global_resource}
\title{Copy global resources into a packet directory}
\usage{
orderly_global_resource(...)
}
\arguments{
\item{...}{Named arguments corresponding to global resources to
copy. The name will be the destination filename, while the value
is the filename within the global resource directory.}
}
\value{
Undefined
}
\description{
Copy global resources into a packet directory. You can use this to
share common resources (data or code) between multiple packets.
Additional metadata will be added to keep track of where the files
came from.  Using this function requires that the orderly
repository has global resources enabled, with a
\verb{global_resources:} section in the \code{orderly_config.yml}; an error
will be raised if this is not configured.
}
