####################### URL for the London Datastore API #######################
#' @title lds_patch_description
#' @description Updates description page of an existing dataset on the London Datastore/.
#' @param slug url slug of the dataset - https://data.london.gov.uk/dataset/<slug>
#' @param patch A character vector, output of `lds_description_render()`
#' @param api_key London Datastore API key - needed to amend a dataset.
#' @return A [response()](https://httr.r-lib.org/reference/response.html) object
#' @examples
#' new_description <- lds_description_render(
#' "datastore_description.Rmd",
#' include_title = FALSE,
#' save_html = FALSE)
#' lds_patch_description(slug = "2o8xw", patch = new_description, api_key = Sys.getenv("LDS_API_KEY"))
#' @rdname lds_patch_description
#' @export
#' @import checkmate
lds_patch_description <- function(slug, patch, api_key) {
  checkmate::check_character(slug)
  checkmate::check_character(api_key)
  checkmate::check_character(patch)

  patch <- list(description = patch)
  patch[["updatedAt"]] <- Sys.time()

  url <- paste0(lds_api_url, "dataset/", slug)
  patches <- names(patch)

  for (item in patches) {
    patch_string <- paste0(
      '[{"op": "replace", "path":"/',
      item,
      '", "value": "',
      patch[[item]],
      '"}]'
    )
    resp <- httr2::request(url) |>
      httr2::req_method("PATCH") |>
      httr2::req_headers(
        "Content-Type" = "application/json",
        Authorization = api_key
      ) |>
      httr2::req_body_raw(
        patch_string,
        type = "application/json"
      ) |>
      httr2::req_perform()

    httr2::resp_check_status(resp)
  }
}
