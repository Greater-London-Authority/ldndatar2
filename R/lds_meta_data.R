#' @title lds_meta_data
#' @description Fetch all available meta data
#'
#'
#' @param type <character> The type of meta data to be returned "resources", "orgs", "datasets" or "topics"
#' @example example_function()
#' @import pkg
#' @import pkg
#' @importFrom checkmate assert_choice
#' @importFrom glue glue
#' @export
lds_meta_data <- function(type = "resources") {
  checkmate::assert_choice(type, c("resources", "orgs", "datasets", "topics"))
  user_selection <- type
  glue::glue("The user has selected: {user_selection}")

}
