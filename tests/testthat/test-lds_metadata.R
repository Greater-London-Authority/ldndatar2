# ---- Input validation: type ----

test_that("type must be one of the allowed choices", {
  expect_error(
    lds_metadata(type = "organisations"),
    "type"
  )

  expect_error(
    lds_metadata(type = "orgs"),
    "type"
  )

  expect_error(
    lds_metadata(type = "tables"),
    "type"
  )
})

test_that("type rejects non-string inputs", {
  expect_error(
    lds_metadata(type = 123),
    "type"
  )

  expect_error(
    lds_metadata(type = TRUE),
    "type"
  )

  expect_error(
    lds_metadata(type = NULL),
    "type"
  )

  expect_error(
    lds_metadata(type = NA_character_),
    "type"
  )
})

test_that("type rejects vectors with more than one element", {
  expect_error(
    lds_metadata(type = c("resources", "datasets")),
    "type"
  )
})

test_that("type rejects empty string", {
  expect_error(
    lds_metadata(type = ""),
    "type"
  )
})

test_that("default type is 'resources'", {
  expect_equal(formals(lds_metadata)$type, "resources")
})

# ---- Mocked API responses (teams / topics) ----
#
# These types route through fetch_all_api_metadata() which uses httr2, so
# httptest2::with_mock_api() can intercept the request and serve the fixture at
# tests/testthat/data.london.gov.uk/api/v3/datasets/export.json.

httptest2::with_mock_api({
  test_that("type 'teams' returns a data frame from mocked response", {
    result <- lds_metadata(type = "teams")

    expect_s3_class(result, "data.frame")
    expect_gt(nrow(result), 0)
    expect_setequal(names(result), c("id", "title"))
  })

  test_that("type 'topics' returns a data frame from mocked response", {
    result <- lds_metadata(type = "topics")

    expect_s3_class(result, "data.frame")
    expect_gt(nrow(result), 0)
    expect_setequal(names(result), c("id", "title"))
  })
})

# ---- Live-API tests (resources / datasets) ----
#
# `fetch_tabular_metadata()` uses `readr::read_csv(url)` directly, which
# httptest2 can't intercept (it only mocks httr2). Until we refactor that
# function to use httr2, these tests are gated behind an env var so they don't
# fire in normal local / CI runs and burn through the API rate limit.
# Run them with: Sys.setenv(LDS_RUN_LIVE_TESTS = "true"); devtools::test()

skip_unless_live <- function() {
  testthat::skip_if_not(
    identical(Sys.getenv("LDS_RUN_LIVE_TESTS"), "true"),
    "live API tests are opt-in (set LDS_RUN_LIVE_TESTS=true)"
  )
}

test_that("type 'resources' is accepted and returns a tibble", {
  skip_unless_live()

  result <- lds_metadata(type = "resources")

  expect_s3_class(result, "tbl_df")
  expect_gt(nrow(result), 0)
})

test_that("type 'datasets' is accepted and returns a tibble", {
  skip_unless_live()

  result <- lds_metadata(type = "datasets")

  expect_s3_class(result, "tbl_df")
  expect_gt(nrow(result), 0)
})

# ---- Column expectations ----

test_that("resources metadata contains expected columns", {
  skip_unless_live()

  result <- lds_metadata(type = "resources")

  # Column names should be snake_case (via janitor::clean_names)
  col_names <- names(result)
  expect_true(all(col_names == tolower(col_names)))
  expect_true(all(!grepl("\\s", col_names)))
})

test_that("datasets metadata contains expected columns", {
  skip_unless_live()

  result <- lds_metadata(type = "datasets")

  col_names <- names(result)
  expect_true(all(col_names == tolower(col_names)))
  expect_true(all(!grepl("\\s", col_names)))
})
