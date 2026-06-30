#' @title Download dataset metadata
#'
#' @description
#' Adapted from the original ldndatar pkg.
#' This updated function downloads the metadata of a given page slug.
#' i.e. will let you know the metadata about a given page on the London Datastore.
#'
#' @param slug a URL slug of the dataset - https://data.london.gov.uk/dataset/slug
#' @param api_key London Datastore API key, needed for private datasets, Default: NULL
#' @param inc_tables whether to include data on any tables in the dataset, Default: FALSE
#' @return A tibble of metadata
#' @export
#' @import dplyr
#' @importFrom checkmate assert_string assert_logical
#' @importFrom glue glue
#' @importFrom rlang is_empty
#' @importFrom httr2 request req_headers req_perform resp_status resp_body_json
#' @importFrom purrr list_flatten
lds_download_metadata <- function(slug, api_key = NULL, inc_tables = FALSE) {
  # Checkmate type checks
  checkmate::assert_string(slug, n.chars = 5L)
  checkmate::assert_string(api_key, null.ok = TRUE)
  checkmate::assert_logical(inc_tables)

  dataset_url <- glue::glue("{lds_url_api}dataset/{slug}")

  req <- httr2::request(dataset_url)

  if (!is.null(api_key)) {
    req <- req |>
      httr2::req_headers(Authorization = api_key)
  }

  response <- httr2::req_perform(req)

  resp_status <- httr2::resp_status(response)

  if (resp_status == 200) {
    content <- httr2::resp_body_json(response)
  } else if (resp_status == 403) {
    if (is.null(api_key)) {
      stop("This is a private dataset, please provide an API key")
    } else {
      stop("You do not have permission to see this dataset")
    }
  } else if (resp_status == 404) {
    stop("This dataset does not exist")
  }

  for (sublist in c("resources", "shares", "readonly")) {
    assign(sublist, content[[sublist]])
    content[sublist] <- NULL
  }

  for (sublist in c("tags", "topics")) {
    content[sublist] <- paste(content[[sublist]], collapse = ", ")
  }

  for (item in names(content)) {
    if (is.null(content[[item]])) {
      content[[item]] <- NULL
    }
  }
  content <- purrr::list_flatten(content)

  meta_data <- content |>
    as.data.frame(stringsAsFactors = FALSE) |>
    dplyr::mutate(join = 1)

  resources_df <- data.frame()
  tables <- list()
  if (length(resources) > 0) {
    resource_ids <- names(resources)

    for (res in resource_ids) {
      resources[[res]] <- remove_null_list(resources[[res]])
      if ("tables" %in% names(resources[[res]])) {
        tables[res] <- resources[[res]]["tables"]
        resources[[res]][["tables"]] <- NULL
      }
      resources_df <- resources[[res]] |>
        as.data.frame(stringsAsFactors = FALSE) |>
        dplyr::mutate(resource_id = res) |>
        dplyr::bind_rows(resources_df)
    }

    common_columns <- base::intersect(
      names(meta_data),
      names(resources_df)
    )

    for (column in common_columns) {
      resources_df <- resources_df |>
        stats::setNames(
          gsub(
            paste0("^", column, "$"),
            paste0("resource_", column),
            names(resources_df)
          )
        )
    }

    resources_df <- resources_df |>
      dplyr::mutate(join = 1)

    meta_data <- dplyr::full_join(meta_data, resources_df, by = "join")
  }

  ######  Build the meta data dataframe.

  meta_data <- meta_data |>
    dplyr::select(-"join") |>
    dplyr::mutate_if(
      is.character,
      ~ ifelse(. == "" | . == "null" | . == "[]", NA, .)
    ) |>
    dplyr::mutate_at(
      dplyr::vars(
        dplyr::ends_with("At", ignore.case = FALSE),
        dplyr::contains("time")
      ),
      lubridate::ymd_hms
    ) |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::matches("^check_http_status$|^check_size$|^order$")),
      as.integer
    )
  if (inc_tables) {
    tables_df <- data.frame()
    for (res in names(tables)) {
      for (tab in names(tables[[res]])) {
        table_df <- data.frame(
          list(
            resource_id = res,
            table_id = tab,
            table_title = tables[[res]][[tab]]$title
          ),
          stringsAsFactors = FALSE
        )
        tables_df <- tables_df |>
          dplyr::bind_rows(table_df)
      }
    }
    if (nrow(tables_df) > 0) {
      meta_data <- dplyr::full_join(meta_data, tables_df, by = "resource_id")
    }
  }

  return(dplyr::as_tibble(meta_data))
}

### Utility functions for the lds_metadatset function.

remove_null_list <- function(l) {
  for (item in names(l)) {
    if (is.null(l[[item]]) || rlang::is_empty(l[[item]])) {
      l[[item]] <- NULL
    }
  }
  return(l)
}
