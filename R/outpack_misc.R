## Some constants:
local <- "local"
orphan <- "orphan"
location_reserved_name <- c(local, orphan)
location_types <- c(local, orphan, "path", "http")
re_id <- "^([0-9]{8}-[0-9]{6}-[[:xdigit:]]{8})$"


##' Generate a new outpack id
##'
##' @title Generate outpack id
##'
##' @return A new outpack id (a string)
##'
##' @export
outpack_id <- function() {
  time <- Sys.time()
  sprintf("%s-%s%s",
          iso_time_str(time),
          val_to_bytes(as.numeric(time), 2),
          paste(as.character(openssl::rand_bytes(2)), collapse = ""))
}


validate_outpack_id <- function(id) {
  assert_scalar_character(id)
  if (!grepl(re_id, id)) {
    stop(sprintf("Malformed id '%s'", id), call. = FALSE)
  }
}


not_found_error <- function(message, data) {
  structure(list(message = message, data = data),
            class = c("not_found_error", "error", "condition"))
}


## In orderly we also add the result of git status --porcelain here,
## but we've never really used this and it's quite slow for big
## repos. More problematic, the format looks hard to replicate with
## gert (which provides a really nice data frame of status
## information) and I imagine we'd have similar issues with a python
## client. Most of the time when these things are run on a controlled
## server we only need the hash really.
##
## Also note that there might be 0, 1, or more urls depending on the
## way that the repo is configured; this feels ok really.
git_info <- function(path) {
  repo <- tryCatch(gert::git_open(path), error = function(e) NULL)
  if (is.null(repo)) {
    return(NULL)
  }
  list(sha = gert::git_commit_id(repo = repo),
       branch = gert::git_branch(repo = repo),
       url = gert::git_remote_list(repo = repo)$url)
}


## Almost certainly this will get expanded, but this should work fine
## for our initial needs.
find_all_dependencies <- function(id, metadata) {
  ret <- unique(id)
  while (length(id) > 0) {
    id_new <- unlist(lapply(metadata[id], function(x) x$depends$packet),
                     FALSE, FALSE)
    id <- setdiff(id_new, ret)
    ret <- c(id, ret)
  }
  sort(ret)
}


validate_parameters <- function(parameters) {
  if (is.null(parameters) || length(parameters) == 0) {
    return()
  }
  assert_is(parameters, "list")
  assert_named(parameters, unique = TRUE)
  ## NOTE: technically this allows raw and complex through, which is a
  ## bit undesirable but unlikely
  ok <- vlapply(parameters, function(x) {
    length(x) == 1 && is.atomic(x) && !is.na(x)
  })
  if (!all(ok)) {
    stop(sprintf("All parameters must be scalar atomics: error for %s",
                 paste(squote(names(parameters)[!ok]), collapse = ", ")))
  }
}
