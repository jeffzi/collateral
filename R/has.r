#' Filter elements that contain a type of side effect.
#'
#' Returns a logical vector indicating which elements contain a type of side
#' effect. If you have a large data frame or list, you can use this to isolate
#' the element that contain warnings, for example, or messages.s
#'
#' The \code{has_*()} functions power the \code{tally_*()} functions and, in turn,
#' the \code{summary} methods.
#'
#' @param x A \code{safely_mapped} or \code{quietly_mapped} list to tally.
#' @return A logical vector, of the same length as \code{x}, which is \code{TRUE} for
#'   elements that contain a type of side effect and \code{FALSE} otherwise.
#'
#' @examples
#'
#' library(magrittr)
#'
#' list("a", 10, 100) %>% map_safely(log) %>% has_errors()
#' list(5, -12, 103) %>% map_quietly(log) %>% has_warnings()
#'
#' suppressMessages(library(tidyverse))
#'
#' # if you're working with list-columns, the tally functions are useful
#' # in conjunction with dplyr::summarise()
#' mtcars %>%
#'   rownames_to_column(var = "car") %>%
#'   as_data_frame() %>%
#'   select(car, cyl, disp, wt) %>%
#'   # spike some rows in cyl == 4 to make them fail
#'   mutate(wt = dplyr::case_when(
#'     wt < 2 ~ -wt,
#'     TRUE ~ wt)) %>%
#'   # nest and do some operations quietly()
#'   nest(-cyl) %>%
#'   mutate(qlog = map_quietly(data, ~ log(.$wt))) %>%
#'   filter(has_warnings(qlog))
#'
#' @name has
NULL

#' @rdname has
#' @importFrom purrr map_lgl
#' @importFrom methods is
#' @export
has_results = function(x) {
  if(!(is(x, 'safely_mapped') | is(x, 'quietly_mapped'))) {
    stop(paste('Only usable on safely_mapped or',
      'quietly_mapped objects.'))
  }
  map_lgl(x, ~ !is.null(.$result))
}

#' @rdname has
#' @importFrom purrr map_lgl is_empty
#' @importFrom methods is
#' @export
has_errors = function(x) {
  if(!is(x, 'safely_mapped')) {
    stop('Only usable on safely_mapped objects.')
  }
  map_lgl(x, ~ !is.null(.$error) & !is_empty(.$error$message))
}

#' @rdname has
#' @importFrom purrr map_lgl is_empty
#' @importFrom methods is
#' @export
has_warnings = function(x) {
  if(!is(x, 'quietly_mapped')) {
    stop('Only usable on safely_mapped objects.')
  }
  map_lgl(x, ~ !is.null(.$warning) & !is_empty(.$warning))
}

#' @rdname has
#' @importFrom purrr map_lgl is_empty
#' @importFrom methods is
#' @export
has_messages = function(x) {
  if(!is(x, 'quietly_mapped')) {
    stop('Only usable on safely_mapped objects.')
  }
  map_lgl(x, ~ !is.null(.$message) & !is_empty(.$message))
}

#' @rdname has
#' @importFrom purrr map_lgl is_empty
#' @importFrom methods is
#' @export
has_output = function(x) {
  if(!is(x, 'quietly_mapped')) {
    stop('Only usable on safely_mapped objects.')
  }
  map_lgl(x, ~ !is.null(.$output) & !is_empty(.$output))
}
