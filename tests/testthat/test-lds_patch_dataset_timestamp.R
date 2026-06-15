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
