testthat::test_that("test timestamp is updated successfully", {
  mock_httr <- function(status) {
    function(...) {
      httr2::response(status_code = status)
    }
  }

  testthat::expect_invisible(
    testthat::with_mocked_bindings(
      req_perform = mock_httr(200),
      .package = "httr2",
      lds_patch_dataset_timestamp(slug = "slug", api_key = "api_key")
    )
  )

  testthat::expect_warning(
    testthat::with_mocked_bindings(
      req_perform = mock_httr(404),
      resp_status = function(...) 404L,
      .package = "httr2",
      lds_patch_dataset_timestamp(slug = "slug", api_key = "api_key")
    ),

    "Failed to update dataset timestamp"
  )
})

testthat::test_that("timestamp is sent as a JSON Patch on updatedAt in UTC", {
  sent <- NULL
  capture_request <- function(req) {
    sent <<- req
    httr2::response(status_code = 200)
  }

  httr2::with_mocked_responses(
    capture_request,
    lds_patch_dataset_timestamp(slug = "abcde", api_key = "api_key")
  )

  testthat::expect_equal(sent$method, "PATCH")
  testthat::expect_equal(sent$url, "https://data.london.gov.uk/api/dataset/abcde")
  testthat::expect_equal(
    httr2::req_get_headers(sent)[["Content-Type"]],
    "application/json-patch+json"
  )

  body <- httr2::req_get_body(sent)
  testthat::expect_length(body, 1)
  testthat::expect_equal(body[[1]]$op, "replace")
  testthat::expect_equal(body[[1]]$path, "/updatedAt")
  testthat::expect_match(
    body[[1]]$value,
    "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$"
  )
})

testthat::test_that("lds_timestamp is the current time in UTC", {
  before <- Sys.time()
  stamp <- lds_timestamp()
  parsed <- as.POSIXct(stamp, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")

  testthat::expect_lt(abs(as.numeric(difftime(parsed, before, units = "secs"))), 5)
})
