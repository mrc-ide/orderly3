##' Run a report.  This will create a new directory in
##' `drafts/<reportname>`, copy your declared resources there, run
##' your script and check that all expected artefacts were created.
##'
##' @title Run a report
##'
##' @param name Name of the report to run
##'
##' @param parameters Parameters passed to the report. A named list of
##'   parameters declared in the `orderly.yml`.  Each parameter
##'   must be a scalar character, numeric, integer or logical.
##'
##' @param envir The environment that will be used to evaluate the
##'   report script; by default we use the global environment, which
##'   may not always be what is wanted.
##'
##' @param root The path to an orderly root directory, or `NULL`
##'   (the default) to search for one from the current working
##'   directory if `locate` is `TRUE`.
##'
##' @param locate Logical, indicating if the configuration should be
##'   searched for.  If `TRUE` and `config` is not given,
##'   then orderly looks in the working directory and up through its
##'   parents until it finds an `.outpack` directory
##'
##' @return The id of the created report (a string)
##'
##' @export
orderly_run <- function(name, parameters = NULL, envir = NULL,
                        root = NULL, locate = TRUE) {
  root <- orderly_root(root, locate)
  src <- file.path(root$path, "src", name)

  envir <- envir %||% .GlobalEnv
  assert_is(envir, "environment")

  dat <- orderly_read(src)

  orderly_validate(dat, src)

  id <- outpack::outpack_id()

  stopifnot(fs::is_absolute_path(root$path))
  path <- file.path(root$path, "draft", name, id)
  fs::dir_create(path)
  ## Slightly peculiar formulation here; we're going to use 'path' as
  ## the key for storing the active packet and look it up later with
  ## getwd(); this means we definitely will match. Quite possibly path
  ## normalisation would do the same fix. This will likely change in
  ## future if we need to support working within subdirectories of
  ## path too, in which case we use something from fs.
  path <- withr::with_dir(path, getwd())

  ## For now, let's just copy *everything* over. Later we'll get more
  ## clever about this and avoid copying over artefacts and
  ## dependencies.
  all_files <- dir_ls_local(src, all = TRUE)
  if (length(dat) == 0) {
    fs::file_copy(file.path(src, all_files), path)
  } else {
    ## This will require some care in the case where we declare
    ## directory artefacts, not totally sure what we'll want to do
    ## there, but it probably means that we need to write a dir walker
    ## - let's ignore that detail for now and come up with some
    ## adverserial cases later.
    exclude <- unlist(lapply(dat$artefacts, "[[", "files"), TRUE, FALSE)
    to_copy <- union(dat$resources, setdiff(all_files, exclude))
    fs::file_copy(file.path(src, to_copy), path)
  }

  withCallingHandlers({
    p <- outpack::outpack_packet_start(path, name, parameters = parameters,
                                       id = id, root = root$outpack,
                                       local = TRUE)
    p$orderly3 <- list()
    current[[path]] <- p
    stopifnot(is.null(parameters)) # next PR perhaps

    if (length(dat$resources) > 0) { # outpack should cope with this...
      outpack::outpack_packet_file_mark(dat$resources, "immutable", packet = p)
    }
    outpack::outpack_packet_run("orderly.R", envir, packet = p)
    check_produced_artefacts(path, p$orderly3$artefacts)
    custom_metadata_json <- to_json(custom_metadata(p$orderly3))
    outpack::outpack_packet_add_custom("orderly", custom_metadata_json,
                                       custom_metadata_schema(), packet = p)
    outpack::outpack_packet_end(p)
    unlink(path, recursive = TRUE)
  }, error = function(e) {
    ## Eventually fail nicely here with mrc-3379
    outpack::outpack_packet_cancel(p)
    current[[path]] <- NULL
  })

  id
}


custom_metadata <- function(dat) {
  role <- data_frame(
    path = dat$resources, role = rep_along("resource", dat$resources))
  artefacts <- lapply(dat$artefacts, function(x) {
    list(description = scalar(x$description),
         paths = x$files)
  })
  list(artefacts = artefacts,
       role = role,
       displayname = NULL,
       description = NULL,
       custom =  NULL,
       global = list(),
       packages = character(0))
}


check_produced_artefacts <- function(path, artefacts) {
  if (is.null(artefacts)) {
    return()
  }
  expected <- unlist(lapply(artefacts, "[[", "files"), FALSE, FALSE)
  found <- file_exists(expected, workdir = path)
  if (any(!found)) {
    stop("Script did not produce expected artefacts: ",
         paste(squote(expected[!found]), collapse = ", "))
  }
}