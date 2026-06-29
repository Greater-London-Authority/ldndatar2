# ---- Input validation: slug ----
#
# Tests that exercise the HTTP layer are wrapped in
# `httptest2::without_internet()` so they don't make real API calls (which would
# burn through the rate limit). The assertion is the same in spirit: validation
# passed and the function reached the HTTP layer.

test_that("slug must be a string", {
  expect_error(
    lds_download_metadata(slug = 123),
    "slug"
  )

  expect_error(
    lds_download_metadata(slug = NULL),
    "slug"
  )

  expect_error(
    lds_download_metadata(slug = c("a", "b")),
    "slug"
  )

  expect_error(
    lds_download_metadata(slug = TRUE),
    "slug"
  )
})

test_that("slug rejects NA", {
  expect_error(
    lds_download_metadata(slug = NA_character_),
    "slug"
  )
})

# ---- Input validation: api_key ----

test_that("api_key must be NULL or a string", {
  expect_error(
    lds_download_metadata(slug = "test-dataset", api_key = 123),
    "api_key"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", api_key = TRUE),
    "api_key"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", api_key = c("a", "b")),
    "api_key"
  )
})

# ---- Input validation: inc_tables ----

test_that("inc_tables must be logical", {
  expect_error(
    lds_download_metadata(slug = "test-dataset", inc_tables = "yes"),
    "inc_tables"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", inc_tables = 1),
    "inc_tables"
  )

  expect_error(
    lds_download_metadata(slug = "test-dataset", inc_tables = NULL),
    "inc_tables"
  )
})

# ---- Valid inputs pass validation ----

test_that("valid inputs pass validation and reach the HTTP layer", {
  httptest2::without_internet({
    expect_error(
      lds_download_metadata(slug = "nonexistent-slug-xyz-999"),
      class = "httptest2_request"
    )
  })
})

# ---- Happy path against a mocked response ----
#
# Exercises the post-fetch parsing pipeline: resources flattening, full_join,
# and date coercion. Fixture lives at
# tests/testthat/data.london.gov.uk/api/dataset/test-dataset.json

httptest2::with_mock_api({
  test_that("returns a tibble with top-level + per-resource rows", {
    result <- lds_download_metadata(slug = "test-dataset")

    expect_s3_class(result, "tbl_df")
    # One row per resource in the fixture (2 resources)
    expect_equal(nrow(result), 2)

    # Top-level fields preserved
    expect_equal(unique(result$id), "test-dataset")
    expect_equal(unique(result$title), "Mock Test Dataset")
    expect_equal(unique(result$sharing), "public")

    # tags / topics collapsed to a comma-separated string
    expect_equal(unique(result$tags), "transport, buses")
    expect_equal(unique(result$topics), "transport")

    # Resource fields prefixed where they collide with top-level names
    expect_true("resource_id" %in% names(result))
    expect_true("resource_title" %in% names(result))
    expect_setequal(result$resource_id, c("res-abc-1", "res-abc-2"))

    # Date fields coerced to POSIXct
    expect_s3_class(result$createdAt, "POSIXct")
    expect_s3_class(result$updatedAt, "POSIXct")

    # check_http_status / check_size coerced to integer
    expect_type(result$check_http_status, "integer")
    expect_type(result$check_size, "integer")
  })
})


testthat::test_that("error in http response", {
  mock_http_error <- function(status) {
    function(...) {
      httr2::response(status_code = status)
    }
  }

  testthat::expect_error(
    testthat::with_mocked_bindings(
      req_perform = mock_http_error(404),
      .package = "httr2",
      lds_download_metadata(slug = "slug", api_key = "api_key"),
    ),
    "This dataset does not exist"
  )

  testthat::expect_error(
    testthat::with_mocked_bindings(
      req_perform = mock_http_error(403),
      .package = "httr2",
      lds_download_metadata(slug = "slug", api_key = "api_key"),
    ),
    "You do not have permission to see this dataset"
  )

  testthat::expect_error(
    testthat::with_mocked_bindings(
      req_perform = mock_http_error(403),
      .package = "httr2",
      lds_download_metadata(slug = "slug", api_key = NULL),
    ),
    "This is a private dataset, please provide an API key"
  )
})
