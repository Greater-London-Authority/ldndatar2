httptest2::with_mock_api({
  mock_metadata <- function(...) {
    data.frame(
      id = "vd4q4",
      resource_id = "cxm",
      resource_title = "text.txt",
      stringsAsFactors = FALSE
    )
  }

  testthat::test_that("makes a PATCH request to the correct URL", {
    httptest2::expect_PATCH(
      testthat::with_mocked_bindings(
        readline = function(...) "1",
        lds_download_metadata = mock_metadata,
        lds_patch_dataset_timestamp = function(...) invisible(NULL),
        lds_delete_resource(
          slug = "vd4q4",
          resource_name = "text.txt",
          resource_id = "cxm",
          api_key = "api_key"
        )
      ),
      "https://data.london.gov.uk/api/dataset/vd4q4"
    )
  })

  testthat::test_that("aborts when user declines confirmation", {
    testthat::expect_error(
      testthat::with_mocked_bindings(
        readline = function(...) "2",
        lds_download_metadata = mock_metadata,
        lds_delete_resource(
          slug = "vd4q4",
          resource_name = "text.txt",
          resource_id = "cxm",
          api_key = "api_key"
        )
      ),
      "Deletion aborted."
    )
  })

  testthat::test_that("errors when resource is not found", {
    testthat::expect_error(
      testthat::with_mocked_bindings(
        lds_download_metadata = function(...) {
          data.frame(
            id = "vd4q4",
            resource_id = "other",
            resource_title = "text.txt",
            stringsAsFactors = FALSE
          )
        },
        lds_delete_resource(
          slug = "vd4q4",
          resource_name = "text.txt",
          resource_id = "cxm",
          api_key = "api_key"
        )
      ),
      "Resource not found."
    )
  })

  testthat::test_that("errors on invalid confirmation input", {
    testthat::expect_error(
      testthat::with_mocked_bindings(
        readline = function(...) "99",
        lds_download_metadata = mock_metadata,
        lds_delete_resource(
          slug = "vd4q4",
          resource_name = "text.txt",
          resource_id = "cxm",
          api_key = "api_key"
        )
      ),
      "Invalid option."
    )
  })
})

testthat::test_that("looks the resource up on the dataset with the api key", {
  called_with <- NULL

  testthat::expect_error(
    testthat::with_mocked_bindings(
      readline = function(...) "2",
      lds_download_metadata = function(slug, api_key, ...) {
        called_with <<- list(slug = slug, api_key = api_key)
        data.frame(
          id = "vd4q4",
          sharing = "private",
          resource_id = "cxm",
          resource_title = "text.txt",
          stringsAsFactors = FALSE
        )
      },
      lds_delete_resource(
        slug = "vd4q4",
        resource_name = "text.txt",
        resource_id = "cxm",
        api_key = "api_key"
      )
    ),
    "Deletion aborted."
  )

  testthat::expect_equal(called_with, list(slug = "vd4q4", api_key = "api_key"))
})

testthat::test_that("errors when the dataset has no resources", {
  testthat::expect_error(
    testthat::with_mocked_bindings(
      lds_download_metadata = function(...) {
        data.frame(id = "vd4q4", title = "Empty", stringsAsFactors = FALSE)
      },
      lds_delete_resource(
        slug = "vd4q4",
        resource_name = "text.txt",
        resource_id = "cxm",
        api_key = "api_key"
      )
    ),
    "Resource not found."
  )
})
