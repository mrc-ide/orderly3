##' Declare that a file, or group of files, are an orderly
##' resource. By explicitly declaring files as resources orderly will
##' mark the files as immutable inputs and validate that your analysis
##' does not modify them when run with [orderly_run()]
##'
##' @title Declare orderly resources
##'
##' @param files Any number of names of files
##'
##' @return Undefined
##'
##' @export
orderly_resource <- function(files) {
  ## TODO: an error here needs to throw a condition that we can easily
  ## handle and or defer; that's not too hard to do though - convert
  ## the error into something with a special class, perhaps make it a
  ## warning in normal R and then register a handler for it in the
  ## main run.
  assert_character(files)
  assert_file_exists(files)

  p <- get_active_packet()
  if (!is.null(p) && length(files) > 0L) {
    outpack::outpack_packet_file_mark(files, "immutable", packet = p)
    p$orderly3$resources <- c(p$orderly3$resources, files)
  }

  invisible()
}


static_orderly_resource <- function(files) {
  list(files = static_character_vector(files))
}


##' Declare an artefact. By doing this you turn on a number of orderly
##' features; see Details below. You can have multiple calls to this
##' function within your orderly script.
##'
##' (1) files matching this will *not* be copied over from the src
##' directory to the draft directory unless they are also listed as a
##' resource with [orderly_resource()]. This feature is only enabled
##' if you call this function from the top level of the orderly script
##' and if it contains only string literals (no variables).
##'
##' (2) if your script fails to produce these files, then
##' [orderly_run()] will fail, guaranteeing that your task does really
##' produce the things you need it to.
##'
##' (3) within the final metadata, your artefacts will have additional
##' metadata; the description that you provide and a grouping
##'
##' @title Declare orderly artefacts
##'
##' @param description The name of the artefact
##'
##' @param files The files within this artefact
##'
##' @return Undefined
##'
##' @export
orderly_artefact <- function(description, files) {
  assert_scalar_character(description)
  assert_character(files) # also check length >0 ?

  p <- get_active_packet()
  if (!is.null(p)) {
    artefact <- list(description = description, files = files)
    p$orderly3$artefacts <- c(p$orderly3$artefacts, list(artefact))
  }

  invisible()
}


static_orderly_artefact <- function(description, files) {
  list(description = static_character_vector(description),
       files = static_character_vector(files))
}


static_character_vector <- function(x) {
  if (is.character(x)) {
    x
  } else if (is_call(x, "c")) {
    x <- lapply(x[-1], static_character_vector)
    x <- if (all(vlapply(x, is.character))) unlist(x, FALSE, FALSE) else NULL
  } else {
    x <- NULL
  }
  x
}


static_eval <- function(fn, call) {
  expr <- match.call(fn, call)
  expr[[1]] <- fn
  eval(expr)
}


current <- new.env(parent = emptyenv())

get_active_packet <- function() {
  current[[getwd()]]
}